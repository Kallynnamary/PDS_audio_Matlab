%fecha todos os programas
clc; close('all'); clear('variables');

% Carrega todos os arquivos
 arquivos = dir;

 % Processa cada arquivo
arq_concats_indice = [];
arq_concats_comprimento = [];
for arquivo_da_vez = 1:length(arquivos)
   
    % Verifica se é um arquivo concatenado
    if strfind(arquivos(arquivo_da_vez).name,'LPC_concatenado_')
        
        % Processa cada arquivo
        fprintf('Verificando arquivo: %s\r',arquivos(arquivo_da_vez).name);
        arq_concats_indice = [arq_concats_indice arquivo_da_vez];
        
        % Carrega o arquivo
        load(arquivos(arquivo_da_vez).name)
       
        % Pega o tamanho da matriz
        Variavel = arquivos(arquivo_da_vez).name(1:end-4);
        Variavel(2:3) = 'pc';        
        arq_concats_comprimento = [arq_concats_comprimento length(eval(Variavel))];
        
    end
   
end

% Cria a super matrix
Matrix_Concat = zeros(length(arq_concats_indice),max(arq_concats_comprimento));

% Preenche a matrix
for i = 1:length(arq_concats_indice)
    Variavel = arquivos(arq_concats_indice(i)).name(1:end-4);
    Variavel(2:3) = 'pc'; 
    Matrix_Concat(i, 1:arq_concats_comprimento(i)) = eval(Variavel);
end
clear Lpc_* Variavel arquivos arq_* i arquivo_da_vez
%fprintf('Acabou :)\r');

[m, n] = size(Matrix_Concat);
%divide a imagem em blocos de tamanho [8xn colunas]

X = Matrix_Concat;
niveis = 1024;
representates_por_nivel = 46;

[Grupos, Centroides, sumd, D] = kmeans(X(:),niveis);

Codebook = zeros(niveis,representates_por_nivel);

for grupo_id = 1:niveis
    Grupo_Vetor = X(Grupos==grupo_id);
    if(length(Grupo_Vetor) < representates_por_nivel)
        disp(['Amostras insuficientes no grupo ',num2str(grupo_id),' -- completando']);
        Grupo_Vetor = Grupo_Vetor(randi(length(Grupo_Vetor),1,representates_por_nivel));
    end
    Distancias = dist(Grupo_Vetor(:),Centroides(grupo_id))';
    [Valores, Indices] = sort(Distancias);
    Codebook(grupo_id,:) = Grupo_Vetor(Indices(1:representates_por_nivel));
end

%salva em uma matrix o codebook
 %Codebook_rugoso = Codebook;
 save('Codebook_rugoso_1024.mat','Codebook');
