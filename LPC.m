clc; close('all'); clear; %fecha todos os programas
 
%Lê o arquivo
%vozes patológicas
[x,fs] = audioread('normal15.wav');

%Pre-processamentodosinal
tamsegmento = 0.020; % Tempo em s

% Valor de sobreposicao em porcentgem
sobreposicao = 50; % 50 é eq. a 50%.

% Converte o sinal stereo em mono, se necessario
x = x(:,1);

%Elimina 0.2 segundos no início e no fim
%  for  i=5000:20000
%      j = i;
%      x1(j) = x(i);
%  end  
x1 = x;

% Calcula os valores de tempo do sinal original em segundos. tamanho do
t = (1:length(x1))./fs;

% Aplicando o filtro de pre-enfase
x1=filter([1,-0.95],1,x1);

% Retira o nível DC extra%
x1 = x1 - mean(x1);

% Renivela o sinal
x1 = x1./max(x1);

%Segmentação e Janelamento
% Descobre o número de amostras por segmentos
N_APF = floor(fs * tamsegmento); 

% Cálculo do passo de deslocamento (método com sobreposição)
passo_de_deslocamento = floor(N_APF * (100-sobreposicao) / 100);
 
% Janela de Hamming
janela = hamming(N_APF); 
 
% Determina o número de frames que o sinal terá quando segmentado
Nsegmento = floor(length(x1) / passo_de_deslocamento - 1);

% Prealoca o espaço de cada frame
frames = zeros(Nsegmento,N_APF);

% Segmenta o sinal em frames com sobreposição;
numero_do_frame = 1;            % Contabilizará qual é o frame
final = (Nsegmento*passo_de_deslocamento-passo_de_deslocamento);
 
for i = 1:Nsegmento
    indice_inicial = (i-1) * passo_de_deslocamento + 1;
    indice_final = indice_inicial + N_APF - 1;
    frames(i,:) = x1(indice_inicial:indice_final);
    frames(i,:) = frames(i,:) .* janela';
end
 
% Plota o sinal com pré-enfase e janelamento
figure (1);
plot(t, x1, 'r'); grid on;
title('Sinal de Voz');
xlabel 'Segmentos (20 ms)', ylabel 'Amplitude'
axis square;
  
%Variáveirs
N_coef_LPC = round((fs/1000) + 2);
 a1 = zeros(Nsegmento,N_coef_LPC+1);
g1 = zeros(Nsegmento,1);
rts1 = zeros(Nsegmento,N_coef_LPC+1);
angz1 = zeros(Nsegmento,N_coef_LPC+1);
 
%Calcula os coeficientes LPC para cada segmento
for numero_do_frame = 1:Nsegmento    
    [a1(numero_do_frame,:),g1(numero_do_frame)] = lpc(frames(numero_do_frame,:),N_coef_LPC);
    rts1 = roots(a1(numero_do_frame,:));
    rts1 = rts1(imag(rts1)>=0);
    angz1 = atan2(imag(rts1),real(rts1));
end
 
%matriz com os coeficientes
coef_LPC = a1;
 
%Plota os coeficientes completos do LPC
figure(2);
plot (a1)
grid on;
title('Coeficientes LPC');

%tamanho dos coeficientes para calcular a fft
L = length(a1);
dim = 2; %dimensão para calcular a fft pq é uma matriz
n = 2^nextpow2(L); %determina quantidadede pontos

%calcula a fft
Y = fft(a1,n,dim);
P2= 10*log10(abs(1./Y));%espectro de dupla face do sinal
P1 = P2(:,1:n/2+1); % espectro de um único lado de cada sinal.
P1(:,2:end-1) = 2*P1(:,2:end-1);
f = fs*(0:(n/2))/n; %normaliza a frequencia

% Calcula os picos para cada segmento
P1_Picos_Posicao = [];
P1_Picos_Valores = [];

%procura os 4 primeiros picos e armazena (formantes)
for i = 1:L
    [aux1, aux2] = findpeaks(P1(i,:),'NPeaks',4);
    P1_Picos_Posicao(i,:) = f(aux2);
    P1_Picos_Valores(i,:) = aux1;   
end

%  nn = 1;
% for kk = 1:length(f(aux2))
%      if (P1_Picos_Posicao(kk) > 90 && bw(kk) <400)
%          P1_Picos_Posicao(nn) = P1_Picos_Posicao(kk);
%          nn = nn+1;
%      end
%  end
%  formants = P1_Picos_Posicao

%calcula os formantes médios
Formantes_media = mean(P1_Picos_Posicao);
Formantes_media1 = sum(P1_Picos_Posicao)/L;

%4 formantes aproximados (escolhe o que mais aparece para os segmentos)
P1_Picos_Posicao1 = f(aux2);

%Armazena que são o max valor e o min valor encontrado para cada formante
%(percorre todos os segmentos para encontrar)
 P1_Picos_Posicao_max = [];
 P1_Picos_Posicao_min = [];
 P1_Picos_Posicao_max = max(P1_Picos_Posicao(:,:));
 P1_Picos_Posicao_min = min(P1_Picos_Posicao(:,:));
 

 %calcula o desvio padrao
 DP = P1_Picos_Posicao_max - P1_Picos_Posicao_min;
 DP1 = std(P1_Picos_Posicao(:,:));
 
%plota na tela os 4 primeiros formantes
 text(P1_Picos_Posicao1+.02,aux1,num2str((1:numel(aux1))'));
 fprintf('Formante\tHz|\tValor do Pico maior\r');
 for i = 1:length(aux1)
     fprintf('%3d\t\t\t\t%.2f\r',P1_Picos_Posicao1(i),aux1(i));
 end

 %plota os valores dos formantes 
 disp(['Média Formantes: ', ...
    num2str(Formantes_media),' Hz']);
disp(['Max Formantes: ', ...
    num2str(P1_Picos_Posicao_max),' Hz']);
disp(['Min Formantes: ', ...
    num2str(P1_Picos_Posicao_min),' Hz']);

figure (6);
hold on; grid on;
plot(f,P1,'k-');
plot(f(aux2),P1(aux2),'rv','MarkerFaceColor','r');
%axis([0 1850 -1.1 1.1]); grid on;
legend('AMDF','Picos','Vales');
ylabel('AMDF_{Min}');
xlabel('Frame 20 ms / 50% de sobreposição');


%plota os formantes para cada segmento
figure(3);
plot(f,P1,'k-'); grid on;
xlabel 'Frequencia (Hz)', ylabel 'Amplitude (dB)'
title 'Resposta em frequência dos coeficienttes LPC: Formantes para cada segmento'
legend('Formantes matriz');


% Para calcular os formantes que utilizam a media dos coeficientes LPC
coef = sum ((a1)/(Nsegmento));

%Calcula os formantes usando a media dos LPC
[H, F2] = freqz(coef);
F2 = F2.*fs/(2*pi);
Z1 = 10*log10(abs(1./H));

%Plota o formantes com a matriz e a média
figure(4);
hold on;
plot(f,P1,'r-'); grid on;
xlabel 'Frequencia (Hz)', ylabel 'Amplitude (dB)'
title 'Resposta em frequência dos coeficienttes LPC: Formantes'
plot(F2,Z1,'k-', 'LineWidth',2.0); grid on;
xlabel 'Frequencia (Hz)', ylabel 'Amplitude (dB)'
title 'Resposta em frequência dos coeficienttes LPC (media): Formantes'
set(gcf,'color','w');
legend( 'Formantes média','Formantes matriz');

[z, h] = max(P1);
figure (5); plot(f, z,'k', 'LineWidth',2.0);hold on;
xlabel 'Frequencia (Hz)', ylabel 'Amplitude (dB)'
title 'Resposta em frequência dos coeficienttes LPC: Formantes'
plot(f,P1,'r-'); grid on; 
legend('Formantes (max)','Formantes matriz');

Coef_LPC_dados = a1;
 save('Coeficientes.mat','Coef_LPC_dados');

