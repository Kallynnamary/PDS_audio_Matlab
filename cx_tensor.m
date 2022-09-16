%% Função para decomposição CX. 
% Decompoem o tensor em decomposição de colunas

function [C_col, Y_d] = cx_tensor(Y,k,z,r)
% desdobramento do tensor Y
Y_d = unfolding(Y, k);

    % calcula a probabilidade para cada coluna de cada modo k
    for i1 = 1:r^2
        prob_ECUR_col(1,i1) = norm(Y_d(:,i1))/norm(Y_d);
    end

% armazena a probabilidade para cada coluna de cada desdobramento
prob_ECUR_col_x{k} = prob_ECUR_col;

%Step 2: Escolhe as c maiores probabilidades armazenando a probabilidade e
%a posição da coluna
prob_max_ECUR_col2{k} = sort(prob_ECUR_col_x{k});
posicao_max_ECUR_col1{k} = prob_max_ECUR_col2{k}(end-z+1:end);
posicao_max_ECUR_col{k} = find(prob_ECUR_col_x{k} >= posicao_max_ECUR_col1{k}(1));

%Step 3: Seleciona as colunas e escalona para criar a matriz C
    for v = 1:z
        p_c = posicao_max_ECUR_col{k}(v);
        C_col(:,v) = Y_d(:,p_c)/sqrt(v*prob_ECUR_col_x{k}(p_c));
    end
end