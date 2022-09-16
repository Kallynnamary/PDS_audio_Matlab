close all; clear; clc;

%% Decomposição CUR para estimação e reconstrução da matriz A_est

% Variaveis
M = 1000;      % número de simulações de Monte Carlo
m = 10;        % numero de linhas da matriz original
n = 10;        % número de colunas da matriz original
c = 9;         % numero de colunas a serem selecionadas da matriz original
r = 10;        % numero de linhas a serem selecionadas da matriz original

prob_SVDCUR_col = zeros(1,n);
prob_SVDCUR_lin = zeros(1,m); 
C = zeros(m,c);   % matriz de colunas escolhidas
R = zeros(r,n);   % matriz de linhas escolhdas
tet = 3;

Err = zeros(M,c);  % erro para o numero de colunas

for w=1:r  % para variar o rank truncado
        fprintf('numero de linhas t= %d\r', w);
    for z=1:c  % para variar o rank truncado
        fprintf('numero de coluna t= %d\r', z);
        for f = 1:M
        fprintf('Simulacao de Monte Carlo = %d\r', f);

        % Inicializa a matriz esparsa A
        A = zeros(m,n); 

        %cria a matriz esparsa A
        C = randn(m,m); Q = orth(C);    % Q é uma matrix ortogonal
        A = Q*diag(1:m)^(-tet); % calcular as matrizes de fatores U^(k) ortogonais


        %% Decomposição CUR
        % Método 2 - SVD-CUR: calcula a probabilidade utilizando a SVD economica
        %% Calcular  a SVD economica da matriz
        [V_e S V_d] = svd(A);
        [l_d c_d] = size(V_d);
        [l_e c_e] = size(V_e);

        %% Calcular a matriz C
        %Step 1: Calcular probabilidade de cada coluna através dos volores sing da
        %direita
            for i = 1:c_d
                prob_SVDCUR_col(i) = sum(V_d(:,i))^2/c_d;
            end

        %Step 2: Escolhe as c maiores probabilidades armazenando a probabilidade e
        %a posição da coluna
        prob_max_SVDCUR_col2 = sort(prob_SVDCUR_col);
        posicao_max_SVDCUR_col1 = prob_max_SVDCUR_col2(end-z+1:end); 
        posicao_max_SVDCUR_col = find(prob_SVDCUR_col >= posicao_max_SVDCUR_col1(1));

        %Step 3: Seleciona as colunas e escalona para criar a matriz C
        for i = 1:z
            p_c = posicao_max_SVDCUR_col(i);
            C(:,i) = A(:,p_c)*(1/sqrt(z*prob_SVDCUR_col(p_c)));
        end

        %% Calcular a matriz R
        %Step 1: Calcular probabilidade de cada coluna através da energia
        for i = 1:l_e
            prob_SVDCUR_lin(i) = sum(V_e(i,:))^2/l_e;
        end

        %Step 2: Escolhe as c maiores probabilidades armazenando a probabilidade e
        %a posição da coluna
        prob_max_SVDCUR_lin2 = sort(prob_SVDCUR_lin);
        posicao_max_SVDCUR_lin1 = prob_max_SVDCUR_lin2(end-w+1:end); 
        posicao_max_SVDCUR_lin = find(prob_SVDCUR_lin >= posicao_max_SVDCUR_lin1(1));

        %Step 3: Seleciona as colunas e escalona para criar a matriz C
        for i = 1:w
            p_r = posicao_max_SVDCUR_lin(i);
            R(i,:) = A(p_r,:)*(1/sqrt(w*prob_SVDCUR_lin(p_r)));
        end

        %% Calcular a matriz U
        U = pinv(C)*A*pinv(R);

        %% Reconstroi a matriz A
        A_rec = C*U*R;

        % Calcula o erro de estimação
        Err(f,z) = norm(A-A_rec, 'fro')/norm(A, 'fro');

        end
      % Calcula a Normalised Mean Square Erro em dB
      NMSE1(w,:) = sum(Err(:,:))/M; 
      NMSEdB(w,:) = 10*log10(NMSE1(w,:));
    end
end


%% Gráfico
figure(1);  hold on;
plot(NMSEdB(1,:), 'm-o', 'linewidth',1); plot(NMSEdB(2,:), 'k-s', 'linewidth',1); plot(NMSEdB(3,:), 'c-*', 'linewidth',1.5);plot(NMSEdB(4,:), 'b-o', 'linewidth',1);
plot(NMSEdB(5,:), 'r-s', 'linewidth',1.8); plot(NMSEdB(6,:), 'g-+', 'linewidth',1); plot(NMSEdB(7,:), 'k->', 'linewidth',2);  plot(NMSEdB(8,:), 'r-o', 'linewidth',1);
plot(NMSEdB(9,:), 'm-s', 'linewidth',1); plot(NMSEdB(10,:), 'b-*', 'linewidth',1);
legend('rows number = 1','rows number = 2','rows number = 3','rows number  = 4','rows number = 5', 'rows number = 6', 'rows number = 7','rows number = 8','rows number = 9','rows number = 10')
grid('minor'); set(cgf,'color','w');
title('NMSE(Y) in dB Vs columns number - SVD-CUR method');
xlabel ('columns number'); ylabel ('NMSE(A) in dB');

