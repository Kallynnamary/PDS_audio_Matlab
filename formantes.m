clc; close('all'); clear; %fecha todos os programas

%Lê o arquivo
[x,fs] = audioread('edema1.wav');

tamsegmento = 0.020; % Tempo em s

% Valor de sobreposicao em porcentgem
sobreposicao = 50; % 50 é eq. a 50%.

% Converte o sinal stereo em mono, se necessario
x = x(:,1);

% Calcula os valores de tempo do sinal original em segundos
t = (1:length(x))./fs;


% Aplicando o filtro de pre-enfase
x=filter([1,-0.95],1,x);

% Retira o nível DC extra%
x = x - mean(x);

% Renivela o sinal
x = x ./ max(x);

% Descobre o número de amostras por segmentos
N_APF = floor(fs * tamsegmento);

% Cálculo do passo de deslocamento (método com sobreposição)
passo_de_deslocamento = floor(N_APF * (100-sobreposicao) / 100);

% Janela de Hamming
janela = hamming(N_APF); 

% Determina o número de frames que o sinal terá quando segmentado
Nsegmento = floor(length(x) / passo_de_deslocamento - 1);

% Prealoca o espaço de cada frame
frames = zeros(Nsegmento,N_APF);
 
% Segmenta o sinal em frames com sobreposição;
numero_do_frame = 1;            % Contabilizará qual é o frame
final = (Nsegmento*passo_de_deslocamento-passo_de_deslocamento);

for i = 1:Nsegmento
    indice_inicial = (i-1) * passo_de_deslocamento + 1;
    indice_final = indice_inicial + N_APF - 1;
    frames(i,:) = x(indice_inicial:indice_final);
    frames(i,:) = frames(i,:) .* janela';
end

% Plota o sinal com pré-enfase e janelamento
figure (1);
plot(x(:,1), 'm'); grid on;
title('Vogal');
xlabel 'Segmentos (20 ms)', ylabel 'Amplitude'
axis square;


%Calcula LPC para cada segmento
%LPC segmental
N_coef_LPC = 40;
%N_coef_LPC = 80;
%N_coef_LPC = round((fs/1000) + 2);

a1 = zeros(Nsegmento,N_coef_LPC+1);
g1 = zeros(Nsegmento,1);
rts1 = zeros(Nsegmento,N_coef_LPC+1);
angz1 = zeros(Nsegmento,N_coef_LPC+1);

for numero_do_frame = 1:Nsegmento    
    [a1(numero_do_frame,:),g1(numero_do_frame)] = lpc(frames(numero_do_frame,:),N_coef_LPC);
    rts1 = roots(a1(numero_do_frame,:));
    rts1 = rts1(imag(rts1)>=0);
    angz1 = atan2(imag(rts1),real(rts1));
end

coef_LPC = sum ((a1)/(Nsegmento));
disp(['Coeficientes LPC (media de cada segmento)', ...
    num2str(coef_LPC)]);

%Plota Coeficientes LPC
figure(2); subplot(2,1,1);
plot (coef_LPC, 'r');
grid on;
title('Coeficientes LPC (média dos frames)');

% Número do frame que será analisado na animação
frameAnalisado = 30;

% Calcula o erro estimado de predição e a autocorrelação deste erro para
% mostrar que si assemelha a um ruído branco (para apenas um frame)
est_x1 = filter([0 -coef_LPC(2:end)],1,frames(frameAnalisado,:));
e1 = frames(frameAnalisado,:)-est_x1;
[acs1,lags1] = xcorr(e1,'coeff');

% plota o erro de predição apenas para um frame analisado
figure (3);
subplot(4,1,1);
plot(e1, 'c'); grid on
title 'Erro de Predição para o frame analisado'
figure (3);
subplot(4,1,2);
plot(lags1,acs1, 'c'), grid on;
title 'Autocorrelação do Erro de Predição'
xlabel 'Lags', ylabel 'Normalized value'


% Obter os coeficientes de predição linear para todo o sinal. 
%[a,g] = lpc(x,18);
%[a,g] = lpc(x,80);
[a,g] = lpc(x,40);
rts = roots(a);

disp(['Coeficientes LPC ', ...
    num2str(a)]);

%armazena as raizes para a parte real e obtem os angulos referentes.
rts = rts(imag(rts)>=0);
angz = atan2(imag(rts),real(rts));

% Calcula o erro estimado de predição e a autocorrelação deste erro para
% mostrar que si assemelha a um ruído branco
est_x = filter([0 -a(2:end)],1,x);
e = x-est_x;
[acs,lags] = xcorr(e,'coeff');

%Plota Coeficientes LPC
figure(2); subplot(2,1,2);
plot (a, 'r');
grid on;
title('Coeficientes LPC');

%Plota o erro de predição e a autocorrelação deste erro
figure (3);
subplot(4,1,3);
plot(e, 'c'); grid on
title 'Erro de Predição'
figure (3);
subplot(4,1,4);
plot(lags,acs, 'c'), grid on;
title 'Autocorrelação do Erro de Predição'
xlabel 'Lags', ylabel 'Normalized value'


% método 2 para calcular os formantes
% Converter as freqüências angulares em rad / amostra representada pelos 
%ângulos Hz e calcular as larguras de banda de formantes. As larguras de 
%banda de formantes são representados pela distância da predição zeros 
%polinomiais do círculo unitário.
[frqs,indices] = sort(angz.*(fs/(2*pi)));
bw = -1/2*(fs/(2*pi))*log(abs(rts(indices)));

%Calcula os formantes excluindo os valores menores 90  e mmaiores que 400
 nn = 1;
for kk = 1:length(frqs)
     if (frqs(kk) > 90 && bw(kk) <400)
         formants(nn) = frqs(kk);
         nn = nn+1;
     end
 end
 formants

% Para calcular os formantes (metodo 1) através da função freqz
figure(4);
[X, F] = freqz(a);
F = F.*fs/(2*pi);
Z = 10*log10(abs(1./X));
%Plota o filtro inverso
subplot (2,1,1);
plot(F,Z,'m-'); grid on;
legend('Formantes')
xlabel 'Frequencia (Hz)', ylabel 'Amplitude (dB)'
title 'Resposta em frequência dos coeficienttes LPC: Formantes'

% Para calcular os formantes que utilizam a media dos coeficientes LPC
figure(4);
[H, F2] = freqz(coef_LPC);
F2 = F2.*fs/(2*pi);
Z = 10*log10(abs(1./H));
%Plota o filtro inverso
subplot (2,1,2);
plot(F2,Z,'b-'); grid on;
legend('Formantes')
xlabel 'Frequencia (Hz)', ylabel 'Amplitude (dB)'
title 'Resposta em frequência dos coeficienttes LPC (media): Formantes'

%calcula a FFt do sinal para comparar com o espectro dos formantes
[Y,F1] = freqz(x);
F1 = F1.*fs/(2*pi);

% %plota sinal reconstruido com os coeficientes LPC
% figure (6); subplot(2,1,1);
% plot(1:38001,x(4001:42001),1:38001,est_x(4001:42001),'--'); %Define o eixo para plotar
% grid on;
% title 'Original Signal vs. LPC Estimado para um segmento'
% xlabel 'Sample number', ylabel 'Amplitude'
% legend('Original signal','LPC estimate')

%plota sinal reconstruido com os coeficientes LPC
figure (6); subplot(2,1,2);
hold('on');
plot(frames(frameAnalisado,:),'k-');
plot((est_x1),'r-');
%plot(1:321,x(1:321),1:321,est_x(1:321),'--'); %Define o eixo para plotar
grid on;
title 'Original Signal vs. LPC Estimado para um frame'
xlabel 'Sample number', ylabel 'Amplitude'
legend('Original signal','LPC estimate')


% Plota formantes e espectro do sinal
figure (5);
hold on; grid on;
title 'Formantes vs FFT do sinal: Espectro'
xlabel 'Frequência (Hz)', ylabel 'Amplitude normalizada (dB)'
plot(F,10*(log10(abs(1./X))),'m-'); 
plot(F1,10*(log10(abs(Y))),'c-');
plot(F2,10*(log10(abs(1./H))),'-');
axis ([0 8000 -30 30])
legend('Formantes com LPC do sinal todo','FFT do Sinal Original', 'Formantes com LPC média')


%Plota os filtros
figure(7);subplot (2,1,1);
plot(F,10*(log10(abs(X))),'m-'); 
legend('Filtro')
xlabel 'Frequencia (Hz)', ylabel 'Amplitude (dB)'
title 'Filtro com coeficientes LPC do sinal'
grid on;

figure(7);subplot (2,1,2);
plot(F1,10*(log10(abs(H))),'-');
legend('Filtro'); grid on;
xlabel 'Frequencia (Hz)', ylabel 'Amplitude (dB)'
title 'Filtro com coeficientes média dos coeficientes LPC para cada segmento'
