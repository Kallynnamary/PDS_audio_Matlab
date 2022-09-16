clear('variables'); close('all');   clc;
X = rand(10,19320);
niveis = 64;
representates_por_nivel = 46;
[Grupos, Centroides] = kmeans(X(:),niveis);

Codebook = zeros(niveis,representates_por_nivel);

for grupo_id = 1:niveis
    Grupo_Vetor = X(Grupos==grupo_id);
    Distancias = dist(X(Grupos==grupo_id),Centroides(grupo_id));
    [Valores, Indices] = sort(Distancias);
    Codebook(grupo_id,:) = Grupo_Vetor(Indices(1:representates_por_nivel));
end

%salva em uma matrix o codebook
 %Codebook_rugoso = Codebook;
 save('Codebook','Codebook_rugoso.mat');