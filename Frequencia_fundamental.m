clc; close('all'); clear; %fecha todos os programas

%Lê o arquivo
%vozes patológicas
[x,fs] = audioread('normal6.wav');

%Plotagem do sinal de voz
% tempo do sinal original
t = (1:length(x))./fs;

% Plota o sinal original
figure(1);
subplot(2,1,1); plot(t,x,'k-'); grid on;
title('Sinal');
xlabel('Tempo (s)'); ylabel('Amplitude');

%filtragem passa baixo
[b,a]=butter(3,0.25);
x=filter(b,a,x);

%Etapa de pré-processamento do sinal
%Definido variaveis
tamsegmento = 0.020; % Tamanho da janela

% Valor da sobreposição
sobreposicao_da_janela = 50;

% Aplica a pré-enfâse  com a funçao Hp(z) = 1 - a_p * z^-1, a_p típico = 0,95 
for i = 2:length(x)
    x(i) = x(i) - 0.95 * x(i - 1); 
end

x = x/ max(x); % Renivela o sinal
x = x - mean(x); % Equaliza o sinal

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
numero_do_frame = 1;            % Contabiliza qual é o frame
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
    for k = limiarAmostras:round(N_APF/2)
        % Desloca o frame em k elementos
        aux1 = [frames(i,1+k:N_APF),frames(i,1:k)];

        % Subtrai os sinais, tira o absoluto e soma tudo.
        aux2 = sum(abs(frames(i,:) - aux1));
        
        % Verifica se encontrou um fator de autocorrelação maior,
        if (valoresAMDF(i) > aux2)
        
            % Guarda este valor de autocorrelação e sua posição
            valoresAMDF(i) = aux2;
            deslocamentosAMDF(i) = k;
        end
    end
end
 
% Frequência Fundamental
disp(['Frequência Fundamental pela AMDF: ', ...
    num2str(fs/mean(deslocamentosAMDF)),' Hz']);

% periodo de pitch
disp(['Pitch pela AMDF: ', ...
    num2str(mean(deslocamentosAMDF)/fs),' s']);
 
% Frequência Fundamental com a AMDF
figure(2);
plot(fs./deslocamentosAMDF,'k.');
title('Frequência fundamental com AMDF');
ylabel('Frequência Fundamental (Hz)');
xlabel('Frame 20 ms / 50% de sobreposição');
grid minor;


% Plota a AMDF
figure(3)
plot(valoresAMDF,'b-','LineWidth',1.5);
title('AMDF');
ylabel('AMDF_{Min}');
xlabel('Frame 20 ms / 50% de sobreposição');
grid on; 
