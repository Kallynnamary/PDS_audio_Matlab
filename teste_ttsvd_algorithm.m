close all; clear all; clc;
% Reconstruir o tensor Y apartir do TT-SVD

%% Declarando as variáveis
M = 10000;        % número de simulações de Monte Carlo
d = 4;            % ordem do tensor
I = 2;            % dimensão do tensor (I1=I2=I3=I)
r = 2;            % rank multilinear do tensor (r1=r2=r3=r)
z = 2;        

for h = 1:M
    %% Gerar o tensor Y
    % criar matrix de fatores
  G1_test = randn(I,I); % 
  G2_test = randn(I,I,I); % 
  G3_test = randn(I,I,I); % 
  G4_test = randn(I,I); %    
    
   % constrói o tensor Y apartir da decomposição Tensor Train (TT)
    for i1 = 1:I
        for i2 = 1:I
            for i3 = 1:I
                for i4 = 1:I
                    for r1 = 1:z
                        for r2 = 1:z
                            for r3 = 1:z
                                Y(i1,i2,i3,i4) = sum(sum((G1_test(i1,:)*G2_test(:,i2,r2))*G3_test(:,i3,r3))*G4_test(:,i4));
                            end
                        end
                    end
                end
            end
        end
    end
    
    %% Reconstrução do tensor Y
    % Calcula a matrix núcleo G1
    Y1 = reshape(Y, [I, I^(d-1)]);
    [U1 S1 V1] = svdtruncada(Y1,z);
    G1 = U1;
    
    % testar a reconstrução do unfolding com U1m S1 e V1
        Y1_rec = U1*S1*V1';
    
    % Armazenar os parâmetros calculados
    Ui = cell(1,d-1);
    svi = cell(1,d-1);
    Vi = cell(d-1,1);
    Gi = cell(1,d);
    Yi = cell(1,d-1);
    
    %Calcula os tensores núcleo para w = 2:d-1 (G2, G3)
    for w = 2:d-1
        % Se for w = 2 calcula utilizando V1
        if w == 2
            Y_un = reshape(S1*V1', [z*I, I^(d-w)]);
            [U_1, S_1, V_1] = svdtruncada(Y_un,z);
            G2 = reshape(U_1, [z I z]);
            
            Ui{w} = U_1;
            Vi{w} = V_1';
            Yi{w} = Y_un;
            svi{w} = S_1;
            Gi{w} = G2;
        else % Caso w = 3 e w = 4 calcual apartir de V_1
            
            for s = w
                n = I^(d-s);
                Y_t = reshape((S_1*V_1'), [z*I, n]);
                [U_1, S_1, V_1] = svdtruncada(Y_t,z);
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
    G = reshape(svi{end}*Vi{end}', [z I]);
    
    % Armazena nas celulas
    Gi{1} = G1; Gi{2} = G2; Gi{end} = abs(G);
    
    % Armazena como matrix G3 e G4
    G3 = Gi{3};
    G4 = Gi{4};
    
    
    %% Reconstruir o tensor Y apartir dos núcleos (TT-cores) estimados
    for i1 = 1:I
        for i2 = 1:I
            for i3 = 1:I
                for i4 = 1:I
                    for r1 = 1:z
                        for r2 = 1:z
                            for r3 = 1:z
                                Y_h(i1,i2,i3,i4) = sum(sum((G1(i1,:)*G2(:,i2,r2))*G3(:,i3,r3))*G4(:,i4));
                            end
                        end
                    end
                end
            end
        end
    end
    
    % Calcula a Normalised Mean Square Erro
    NMSE(h,:) = sqrt(sum(sum(sum(sum(abs(Y-Y_h)).^2))))/sqrt(sum(sum(sum(sum(abs(Y)).^2))));
    
    NMSE_G1(h,:) = sqrt(sum(sum(sum(abs(G1_test(1:z,1:z)-G1)).^2)))/sqrt(sum(sum(sum(abs(G1_test(1:z,1:z))).^2)));
    
    NMSE_G2(h,:) = sqrt(sum(sum(sum(sum(abs(G2_test(1:z,1:z,1:z)-G2)).^2))))/sqrt(sum(sum(sum(sum(abs(G2_test(1:z,1:z,1:z))).^2))));
    
    NMSE_G3(h,:) = sqrt(sum(sum(sum(sum(abs(G3_test(1:z,1:z,1:z)-G3)).^2))))/sqrt(sum(sum(sum(sum(abs(G3_test(1:z,1:z,1:z))).^2))));
    
    NMSE_G4(h,:) = sqrt(sum(sum(sum(abs(G4_test(1:z,1:z)-G4)).^2)))/sqrt(sum(sum(sum(abs(G4_test(1:z,1:z))).^2)));
    
    
end

% Calcula a Normalized Mean Square Erro (NMSE) em dB
NMSE1 = sum(NMSE)/M;
NMSEdB_H = 10*log10(NMSE1);

NMSE2 = sum(NMSE_G1)/M;
NMSEdB_G1 = 10*log10(NMSE2);

NMSE3 = sum(NMSE_G2)/M;
NMSEdB_G2 = 10*log10(NMSE3);

NMSE4 = sum(NMSE_G3)/M;
NMSEdB_G3 = 10*log10(NMSE4);

NMSE5 = sum(NMSE_G4)/M;
NMSEdB_G4 = 10*log10(NMSE5);
