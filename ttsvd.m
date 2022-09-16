%% Função TTSVD
% Estima os TT-cores da decomposição TT-SVD apartir da SVD de cada
% desdobramento
function [Gi, Ui, Vi] = ttsvd(Y, t, d)


for w = 2:d-1
                % Se for w = 2 calcula utilizando V1
                if w == 2
                    Y_un = reshape(V1', [z*I, I^(d-w)]);
                    [U_1, S_1, V_1] = svdtruncada(Y_un, z);
                    G2 = reshape(U_1, [z I z]);
                    
                    Ui{w} = U_1;
                    Vi{w} = V_1';
                    Yi{w} = Y_un;
                    svi{w} = S_1;
                    Gi{w} = G2;
                    
                else % Caso w = 3 e w = 4 calcual apartir de V_1
                    for s = w
                        n = I^(d-s);
                        Y_t = reshape(V_1', [z*I, n]);
                        [U_1, S_1, V_1] = svdtruncada(Y_t, z);
                        G_t = reshape(U_1, [z I z]);
                        
                        Yi{s} = Y_t;
                        Ui{s} = U_1;
                        Vi{s} = V_1';
                        svi{s} = S_1;
                        Gi{s} = G_t;
                        
                    end
                end
end

% Calcula G4 apartir de V3 (end por que é a ultima cell)
            G = reshape(Vi{end}', [z I]);
end