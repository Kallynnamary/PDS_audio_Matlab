clc; close('all'); clear;


%fecha todos os programas
%Lê o arquivo
[x,fs] = audioread('edema1.wav');

% Tranforma o sinal estéreo em mono
x = x(:,1);

figure (1); subplot(2,1,1)
plot(x(:,1), 'r-'); grid on;
title('Sinal original'); ylabel ('Amplitude');
set(gcf,'color','w');

% tempo do sinal original
t = (1:length(x))./fs;

% Valor de sobreposicao em porcentgem e define o tamanho do segmento
sobreposicao = 50; % 50 é eq. a 50%.
tamsegmento = 0.020; % Tempo em s

% Aplicando o filtro de pre-enfase
x=filter([1,-0.95],1,x);

% Retira o nível DC extra e renivela o sinal
x = x - mean(x);
x = x./ max(x);

% Descobre o número de amostras por
segmentos
N_APF = floor(fs * tamsegmento);

% Cálculo do passo de deslocamento
%(método com sobreposição)
passo_de_deslocamento = floor(N_APF* (100-sobreposicao) / 100);

% Determina o número de frames que o sinal terá quando segmentado
Nsegmento = floor(length(x)/passo_de_deslocamento - 1);

% Prealoca o espaço de cada frame
frames = zeros(Nsegmento,N_APF);

% Segmenta o sinal em frames com sobreposição;
numero_do_frame = 1; %Contabilizará qual é o frame
final =(Nsegmento*passo_de_deslocamentopasso_de_deslocamento);
for i = 1:Nsegmento
 indice_inicial = (i-1)*passo_de_deslocamento + 1;
 indice_final = indice_inicial +N_APF - 1;
 frames(i,:) = x(indice_inicial:indice_final);
 frames(i,:) = frames(i,:) .*hamming(N_APF)';
end

% Plota o sinal com pré-enfase e
janelamento
figure (1); subplot (2,1,2);
plot(x(:,1), 'b-'); grid on;
title('Sinalcom pré-enfase');
xlabel 'Segmentos (20 ms)', ylabel 'Amplitude'
grid on;

%Calcula o LPC para todo o sinal
%[a,g] = lpc(x,18);
%[a,g] = lpc(x,50);
[a,g] = lpc(x,100);
rts = roots(a);
disp(['Coeficientes LPC ', ...
 num2str(a)]);

%Plota Coeficientes LPC
figure(2); subplot (2,1,1);
plot (a, 'x-');
grid on; set(gcf,'color','w');
title('Coeficientes LPC');

%Porque os coeficientes LPC sãoreais, as raízes ocorrem em paresconjugados
%complexos. Reter apenas as raízescom um sinal para a parte imaginária e
%determinar os ângulos correspondentes às raízes.
rts = rts(imag(rts)>=0);
angz = atan2(imag(rts),real(rts));

%Calcula LPC para cada segmento
%LPC segmental
%N_coef_LPC = 50;
N_coef_LPC = 100;

%N_coef_LPC = round((fs/1000) + 2);
a1 = zeros(Nsegmento,N_coef_LPC+1);
g1 = zeros(Nsegmento,1);
rts1 = zeros(Nsegmento,N_coef_LPC+1);
angz1 = zeros(Nsegmento,N_coef_LPC+1);

for numero_do_frame = 1:Nsegmento

[a1(numero_do_frame,:),g1(numero_do_frame)] =lpc(frames(numero_do_frame,:),N_coef_LPC);
 rts1 =roots(a1(numero_do_frame,:));
 rts1 = rts1(imag(rts1)>=0);
 angz1 =atan2(imag(rts1),real(rts1));
end

coef_LPC = sum ((a1)/(Nsegmento));
disp(['Coeficientes LPC (media de cada segmento)', ...
 num2str(coef_LPC)]);

%Plota Coeficientes LPC
figure(2); subplot(2,1,2);
plot (coef_LPC, 'r-+');
grid on;
title('Coeficientes LPC : media dos coeficientes para cada segmento');

% Calcula o erro estimado de predição e a autocorrelação deste erro para
% mostrar que si assemelha a um ruído branco
est_x = filter([0 -a(2:end)],1,x);
e = x-est_x;
[acs,lags] = xcorr(e,'coeff');

%Plota o erro de predição e a autocorrelação deste erro
figure (3);
subplot(2,1,1);
plot(e, 'b'); grid on
title 'Erro de Predição para osinal'
figure (3);
subplot(2,1,2);
plot(lags,acs, 'r'), grid on;
title 'Autocorrelação do Erro de Predição'
xlabel 'Lags', ylabel 'Valor Normalizado'
set(gcf,'color','w');

% Converter as freqüências angulares em rad / amostra representada pelos
%ângulos Hz e calcular as larguras de banda de formantes. As larguras de
%banda de formantes são representados pela distância da predição zeros
%polinomiais do círculo unitário.
[frqs,indices] = sort(angz.*(fs/(2*pi)));
bw = - 1/2*(fs/(2*pi))*log(abs(rts(indices)));

% Para calcular os formantes: atraves da FFT dos coeficientes
figure(4);
[X, F] = freqz(a);
F = F.*fs/(2*pi);
Z = 10*log10(abs(1./X));

%Plota o filtro inverso
subplot (2,1,1);
plot(F,Z,'r-'); grid on;
legend('Formantes')
xlabel 'Frequencia (Hz)', ylabel 'Amplitude (dB)'
title 'Resposta em frequência dos coeficienttes LPC: Formantes'

%Calcula os formantes usando a media dos LPC
[H, F2] = freqz(coef_LPC);
F2 = F2.*fs/(2*pi);
Z1 = 10*log10(abs(1./H));

%Plota o filtro inverso
subplot (2,1,2);
plot(F2,Z1,'b-'); grid on;
legend('Formantes')
xlabel 'Frequencia (Hz)', ylabel 'Amplitude (dB)'
title 'Resposta em frequência dos coeficienttes LPC (media): Formantes'
set(gcf,'color','w');

%Calcula os formantes usando as frqs calculadas direto do LPC
%Calcula os formantes excluindo os valores menores 90 e mmaiores que nn = 1;
for kk = 1:length(frqs)
 if (frqs(kk) > 90 && bw(kk) <400)
 formants(nn) = frqs(kk);
 nn = nn+1;
 end
end
formants

%calcula a FFT do sinal
[Y,F1] = freqz(x);
F1 = F1.*fs/(2*pi);

figure (5);
title 'FFT do sinal'
plot(F1,(10*(log10(abs(Y)))),'b-');
grid on;
xlabel 'Frequencia (Hz)', ylabel 'Amplitude(dB)'
axis ([0 8000 -30 30])
legend('FFT do Sinal Original')
set(gcf,'color','w');

% Plota o espectro dos formantes e fft do sinal
figure (6);
hold on; grid on;
title 'Formantes vs FFT do sinal: Espectro'
xlabel 'Frequência (Hz)', ylabel 'Amplitude normalizada (dB)'
plot(F,10*(log10(abs(1./X))),'r-');
plot(F1,10*(log10(abs(Y))),'-');
plot(F2,Z1,'-');
legend('Formantes Estimado Pelo LPC do sinal todo','FFT do Sinal  Original','Formantes Estimado Pelo LPC de cada segmento')
set(gcf,'color','w');
axis ([0 9000 -30 30])

%plota sinal reconstruido com os coeficientes LPC
figure (7); subplot (2,1,1);
plot(1:40001,x(4001:44001),1:40001,est_x(4001:44001),'--'); %Define o eixo para plotar
grid on;
title 'Original Signal vs. LPC Estimado para o sinal'
xlabel 'Sample number', ylabel 'Amplitude'
legend('Original signal','LPC estimate')
set(gcf,'color','w');
% Número do frame que será analisado na animação
frameAnalisado = 26;

% Calcula o erro estimado de predição e a autocorrelação deste erro para
% mostrar que si assemelha a um ruído branco (para apenas um frame)
est_x1 = filter(0 - coef_LPC(2:end),1,frames(frameAnalisado,:));
e1 = frames(frameAnalisado,:)-est_x1;
[acs1,lags1] = xcorr(e1,'coeff');

%plota sinal reconstruido com os coeficientes LPC para um segmento
figure (7); subplot(2,1,2);
hold('on');
plot(frames(frameAnalisado,:),'k-');
plot((est_x1),'r-');
grid on;
title 'Original Signal vs. LPC Estimado para um frame'
xlabel 'Sample number', ylabel 'Amplitude'
legend('Original signal','LPC estimate')

%Plota a resposta em frequência do filtro
figure (8); subplot (2,1,2);
[H, F2] = freqz(coef_LPC);
F2 = F2.*fs/(2*pi);
plot(F2,(10*(log10(abs(H)))),'b-');
grid on;
title 'Resposta em frequência do Filtro para o Sinal utilizando os coeficientes de cada segmento'
xlabel 'Frequência (Hz)', ylabel 'Amplitude normalizada (dB)'

figure (8); subplot (2,1,1);
[X, F] = freqz(a);
F = F.*fs/(2*pi);
plot(F,(10*(log10(abs(X)))),'b-');
title 'Resposta em frequência do Filtro para o Sinal'
xlabel 'Frequência (Hz)', ylabel 'Amplitude normalizada (dB)'
grid on;
set(gcf,'color','w');