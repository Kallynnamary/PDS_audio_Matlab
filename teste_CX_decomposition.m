close all; clear all; clc;
% Reconstruir o tensor Y apartir do THOSVD

%% Declarando as variáveis
M = 10000;           % número de simulações de Monte Carlo
d = 3;               % ordem do tensor
I = 20;
r = 20;              % rank multilinear do tensor (r1=r2=r3=r)
t = 100;             % trunca o rank para calcular a CX de 5 em 5
SNR = 10;            % SNR fixa em dB
teta = 10;


% para CX
prob_ECUR_col = zeros(1,r^2);
Err_C = zeros(M,t,d);  % erro para o numero de colunas
NMSE1 = zeros(M,t);

%% Gerar o tensor Y
tEnd1_CX = zeros(M,1);

for tet = 1:teta % para variar o teta
    fprintf('TETA = %d\r', tet);
    for t1=1:t  % para variar o num de colunas
        z = t1*2- 1;
        fprintf('num de colunas t= %d\r', z);
        
        for i = 1:M % para simulações de Monte Carlo
            %   fprintf('Simulacao de Monte Carlo = %d\r', i);
            
            G = randn(r,r,r); % tensor núcleo r x r x r
            
            for j = 1:d
                Mat = randn(I,I); Q = orth(Mat);    % Q é uma matrix ortogonal
                U(:,:,j) = Q*diag(1:I)^(-tet); % calcular as matrizes de fatores U^(k) ortogonais
            end
            
            
            % calcula o tensor X pelo produto de modo-n
            X = nmodeproduct(G, U(:,:,1),1); X = nmodeproduct(X, U(:,:,2),2);X = nmodeproduct(X,  U(:,:,3),3);
            norm_X = sqrt(sum(sum(sum(abs(X)).^2))); % norma do tensor X
            
            X_hat = X/norm_X; % normaliza o tensor X
            norm_X_hat = sqrt(sum(sum(sum(abs(X_hat)).^2))); % norma do tensor X normalizado
            
            % Gerando tensor V de tamanho I x I x I
            V = randn(I,I,I); norm_V = sqrt(sum(sum(sum(abs(V)).^2))); % norma do tensor V
            
            V_hat = V/norm_V; % normaliza o tensor V
            norm_V_hat = sqrt(sum(sum(sum(abs(V_hat)).^2))); % norma do tensor V normalizado
            
            alfa= 1/20^(SNR/10); %constante SNR linear
            
            %Gerar tensor Y
            Y = X_hat+ alfa*V_hat;
            Norm_Y = (sqrt(sum(sum(sum(abs(Y)).^2))));
            
            % TESTE: calclua a SNR para comparar com a SNR fixa
            SNR_hat = 10*log10(norm_X_hat/(alfa*norm_V_hat));
            
            %% Para o CX-tensor
            % tempo de simulação
            tStart = tic;
            
            % Computa a SVD de cada unfolding
            Y_unf = cell(1,d);
            prob_ECUR_col_x = cell(1,d);
            prob_max_ECUR_col2 = cell(1,d);
            C_esc = cell(1,d);
            
            
            for k = 1:d
                % Função CX para tensor
                [C_col, Y_d] = cx_tensor(Y,k,z,r);
                C_esc{k} = C_col;
                Y_unf{k} = Y_d;
            end
            
            %calcula tensor W
            if z == 1
                %
                Y_test1 = C_esc{1}*khatrirao(C_esc{3},C_esc{2})';
                Y_hat3 = reshape(Y_test1, [I I I]);
                %
            else
                W = nmodeproduct(Y,pinv(C_esc{1},10^-6),1);  W = nmodeproduct(W,pinv(C_esc{2}, 10^-6),2);
                W = nmodeproduct(W,pinv(C_esc{3},10^-6),3);
                
                % Reconstroi o tensor
                Y_hat3 = nmodeproduct(W,C_esc{1},1); Y_hat3 = nmodeproduct(Y_hat3,C_esc{2},2);
                Y_hat3 = nmodeproduct(Y_hat3,C_esc{3},3);
            end
            
            
            tEnd1_CX(i) = toc(tStart);
            
            % Calcula a Normalised Mean Square Erro
            % para CX
            NMSE1(i,t1) = sqrt(sum(sum(sum(abs(Y-Y_hat3)).^2)))/sqrt(sum(sum(sum(abs(Y)).^2)));
            %
        end
        
        %         % Calcula a Normalised Mean Square Erro em dB
        NMSE_CX(tet,:) = sum(NMSE1(:,:))/M; NMSEdB_CX(tet,:) = 10*log10(NMSE_CX(tet,:));
        
    end
    
    fprintf('time CX = %d\r', mean(tEnd1_CX));
    
end




%% Gráfico para o CX
figure(1);  hold on;
plot(NMSEdB_CX(1,:), 'm-o', 'linewidth',1); plot(NMSEdB_CX(3,:), 'c-*', 'linewidth',1.5);
plot(NMSEdB_CX(5,:), 'r-s', 'linewidth',1.8); plot(NMSEdB_CX(7,:), 'k->', 'linewidth',2);  plot(NMSEdB_CX(10,:), 'b-*', 'linewidth',1);
legend('teta = 1','teta = 3','teta = 5', 'teta = 7', 'teta = 10')
grid('minor'); set(cgf,'color','w');
%axis([1 9 -120 20]);
title('NMSE(Y) in dB Vs columns - CX');
xlabel ('rank'); ylabel ('NMSE(Y) in dB');

