clc; close('all'); clear; %fecha todos os programas

%Lê o arquivo
%vozes patológicas
[x,fs] = audiovread('edema1.wav');

%Plotagem do sinal de voz
%transformar estereo em mono

% Converte o sinal stereo em mono, se necessario
x = x(:,1);

% tempo do sinal original
t = (1:length(x))./fs;

% Plota o sinal original
figure(1);
subplot(2,1,1); plot(t,x,'k-'); grid on;
title('Sinal');
xlabel('Tempo (s)'); ylabel('Amplitude');

%filtragem passa baixo
% returns the order N of the lowest 
%order digital Butterworth filter that loses no more than Rp dB in 
%the passband and has at least Rs dB of attenuation in the stopband.  
%Wp and Ws are the passband and stopband edge frequencies, normalized 
%from 0 to 1 (where 1 corresponds to pi radians/sample). Wp = 0.1 e Ws = 0.2(lowpass)
%Para os dados amostrados a 1000 Hz, conceber um filtro passa-baixo com não 
%mais do que 3 dB de ondulação na banda de passagem um de 0 a 40 Hz, e pelo 
%menos 60 dB de atenuação na faixa de rejeição. Localizar a ordem do filtro e 
%frequência de corte. Rp = 3dB e Rs = 60dB
 [N, Wn] = buttord(0.1, 0.2, 3, 60);
 [b,a]=butter(N,Wn); %determina os parâmetros do filtro (n (), wn(normaliza a fred de corte))
 x=filter(b,a,x);

%Etapa de pré-processamento do sinal
%Definido variaveis
tamsegmento = 0.020; % Tamanho da janela

% Valor da sobreposição
sobreposicao_da_janela = 50;

% Aplica a pré-enfâse com a funçao Hp(z) = 1 - a_p * z^-1, a_p típico = 0,95
for i = 2:length(x)
    x(i) = x(i) - 0.95 * x(i - 1);
end
x = x - mean(x);                                      % Equaliza o sinal
x = (1 - (-1))/(max(x)-min(x))*(x-min(x)) + (-1);     % Renivela o sinal deixando de 1 à -1

% Plota o sinal com pre-enfase
figure(1);
subplot(2,1,2); plot(t,x,'r-'); grid on;
title('Sinal com Pré-ênfase');
xlabel('Tempo (s)'); ylabel('Amplitude');

%Realiza o janelamento
N_APF = floor(fs * tamsegmento); % Descobre o número de amostras por segmentos
% Cálculo do passo de deslocamento onde haverá sobreposição
deslocamento = floor(N_APF * (100-sobreposicao_da_janela) / 100);
janela = hamming(N_APF); % Janela de Hamming

% Determina o número de frames que o sinal terá quando segmentado
% COM sobreposicao
Nsegmento = floor(length(x) * 100 / (N_APF * (100-sobreposicao_da_janela)));

% Prealoca o espaço de cada frame (COM sobreposicao)
frames = zeros(Nsegmento,N_APF);

% Segmenta o sinal em frames com sobreposição;
numero_do_frame = 1; % Contabiliza qual é o frame
final = (Nsegmento*deslocamento-deslocamento);
for indice = 1:deslocamento:final
% Calcula e salva o valor do segmento e multiplica pela janela
frames(numero_do_frame,:) = janela .* x(indice:(indice+N_APF-1));

% Atualiza o número do segmento
numero_do_frame = numero_do_frame + 1;
end

%% Método AMDF
% Calcula a Função Diferença de Magnitude média do sinal
% Prealoca o sinal
valoresAMDF = ones(Nsegmento,1) * Inf;
deslocamentosAMDF = zeros(Nsegmento,1);

% Este limiar define a partir de qual valor de tal
% se observará a correlação. Isto previne a autocorrelação
% com o sinal para mesmos instantes de tempo.
limiarAMDF = 0.22; % 0.1 = 10%, 0.2 = 20%...
limiarAmostras = floor(N_APF * limiarAMDF);

% Procura em todos os frames a mínima AMDF
for i = 1:Nsegmento

    %    figure(5);                              % REMOVER
    for k = limiarAmostras:round(N_APF/2)

    % Desloca o frame em k elementos
    aux1 = [frames(i,1+k:N_APF),frames(i,1:k)];

    % Subtrai os sinais, tira o absoluto e soma tudo.
    %aux2 = frames(i,:) - aux1;
    %subplot(311);plot(aux1);subplot(312);plot(frames(i,:));subplot(313);plot(aux2);drawnow;pause;
    aux2 = sum(abs(frames(i,:) - aux1));

    % Verifica se encontrou um fator da AMDF menor;
        if (valoresAMDF(i) > aux2)
        % Guarda este valor de autocorrelação e sua posição
        valoresAMDF(i) = aux2;
        deslocamentosAMDF(i) = k;
        end

    end

end

% Exclui os ultimos elementos
valoresAMDF(end) = [];
deslocamentosAMDF(end) = [];

% Frequência Fundamental
disp(['Frequência Fundamental pela AMDF: ', ...
num2str(fs/mean(deslocamentosAMDF)),' Hz']);

% periodo de pitch
disp(['Pitch pela AMDF: ', ...
num2str(mean(deslocamentosAMDF)/fs),' s']);

% plota a Frequência Fundamental com a AMDF
figure(2);
plot(fs./deslocamentosAMDF,'k.');
title('Frequência fundamental com AMDF');
ylabel('Frequência Fundamental (Hz)');
xlabel('Frame 20 ms / 50% de sobreposição');
grid minor;

% Plota a AMDF
figure(3)
plot(deslocamentosAMDF,'color',[0.3,0.3,0.3],'LineWidth',1.5);
title('Menores valores da AMDF');
ylabel('AMDF_{Min}');
xlabel('Frame 20 ms / 50% de sobreposição');
axis([0 300 0 250])
grid on;

%encontra os 2 maiores picos
 [psor,lsor] = findpeaks(valoresAMDF,'SortStr','descend','Annotate','extents','MinPeakDistance',30,'MinPeakProminence',10);
 text(lsor+.02,psor,num2str((1:numel(psor))'));
 fprintf('Posição\t|\tValor do Pico\r');
 for i = 1:length(psor)
     fprintf('%3d\t\t\t\t%.2f\r',lsor(i),psor(i));
 end

figure(4)
plot(deslocamentosAMDF,'color',[0.3,0.3,0.3],'LineWidth',0.6);
title('Menores valores da AMDF');
ylabel('AMDF_{Min}');axis([0 300 0 250]);
xlabel('Frame 20 ms / 50% de sobreposição');
grid on;

%procura os picos (minpeakdistance = distância mínima entre os picos e 
%MinPeakProminence = alguns dos picos são muito próximos uns dos outros. 
%Serve para filtrar esses picos, onde voce determina a distância. )
[Maxima,MaxIdx] = findpeaks(deslocamentosAMDF,  'MinPeakDistance',5, 'MinPeakProminence', 10);

%inverte o sinal para encontrar os vales
DataInv = 1.01*max(deslocamentosAMDF) - deslocamentosAMDF;

%encontra os vales
[Minima, MinIdx] = findpeaks(DataInv, 'MinPeakDistance',0.5,'MinPeakProminence', 10);
Minima = deslocamentosAMDF(MinIdx);
text(MaxIdx+.02,Maxima,num2str((1:numel(Maxima))'));
 fprintf('Posição\t|\tValor do Pico maior\r');
 for i = 1:length(Maxima)
     fprintf('%3d\t\t\t\t%.2f\r',MaxIdx(i),Maxima(i));
 end
 text(MinIdx+.02,Minima,num2str((1:numel(Minima))'));
 fprintf('Posição\t|\tValor do Pico menor\r');
 for i = 1:length(Minima)
     fprintf('%3d\t\t\t\t%.2f\r',MinIdx(i),Minima(i));
 end
 
figure (5);
hold on; plot(deslocamentosAMDF,'k-');
plot(MaxIdx,deslocamentosAMDF(MaxIdx),'rv','MarkerFaceColor','r');
plot(MinIdx,deslocamentosAMDF(MinIdx),'rs','MarkerFaceColor','b');
axis([0 300 0 250]); grid on;
legend('AMDF','Picos','Vales');
ylabel('AMDF_{Min}');
xlabel('Frame 20 ms / 50% de sobreposição');

figure (6); 
hold on;
plot( MaxIdx,fs./deslocamentosAMDF(MaxIdx),'ko');
plot( MinIdx,fs./deslocamentosAMDF(MinIdx),'ro');
axis([0 300 0 200]); grid on;
legend('Frequência fundamental com os Picos','Frequência fundamental com os Vales');
title('Frequência fundamental com os picos e vales da AMDF');
ylabel('Frequência Fundamental (Hz)');
xlabel('Frame 20 ms / 50% de sobreposição');
grid minor;

%Frequência fundamental com os Picos
f1 = fs/mean(deslocamentosAMDF(MaxIdx));
p1 = mean(deslocamentosAMDF(MaxIdx))/fs;
disp(['Frequência Fundamental com os picos AMDF: ', ...
num2str(f1),' Hz']);
% periodo de pitch com os picos AMDF
disp(['Pitch  com os picos AMDF: ', ...
num2str(p1),' s']);

%Frequência fundamental com os Vales
f2 = fs/mean(deslocamentosAMDF(MinIdx));
p2 = mean(deslocamentosAMDF(MinIdx))/fs;
disp(['Frequência Fundamental com os vales AMDF: ', ...
num2str(f2),' Hz']);

% periodo de pitch com os picos AMDF
disp(['Pitch  com os vales AMDF: ', ...
num2str(p2),' s']);

