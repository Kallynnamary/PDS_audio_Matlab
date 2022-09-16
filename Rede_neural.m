%% Rede neural MLP para classificação de base de dados
%% baseado nas caracteristicas extraídas

% Reset geral
clear; close('all'); clc;

% Cria o arquivo que conterá os resultados
ArqID = fopen('DES_X_SDL_mel.txt','w');

% Validação Cruzada
num_validacoes = 10;
load('vozes_para_classificacao');

% Número de neurônios da camada oculta
Num_neuronios_ocultos = 9;

% Numero de características para classificação
num_max_caracteristicas = size(caracteristicasEntrada ,1);

% Vetor para melhor combinação
melhor_comb = [];
melhor_acu  = 0;

for num_caracteristicas = num_max_caracteristicas

	combinacoes_de_caracteristicas = combntns(1:num_max_caracteristicas,num_caracteristicas);

    for combinacao_da_vez = 1:size(combinacoes_de_caracteristicas, 1)

		% Realiza a combinação de todas as características
		CaraceteristicasDesejadas = combinacoes_de_caracteristicas(combinacao_da_vez,:);
		clear 'caracteristicasEntrada' 'caracteristicasObjetivo' 'infoObjetivo' 'infoEntrada';
        
        % Reaload os valores
        load('vozes_para_classificacao');
		
        % Seleciona apenas as características desejadas e altera o gráfico
		caracteristicasEntrada = caracteristicasEntrada(CaraceteristicasDesejadas,:);
		infoEntrada = infoEntrada(CaraceteristicasDesejadas,1);
		
		fprintf(ArqID, '-------------------------------------\n');
		fprintf(ArqID, 'Características testadas: ');
        fprintf('Testando: ');
        
        for i = 1:num_caracteristicas-1
			fprintf(ArqID,'%s + ',char(infoEntrada(i)));
            fprintf('%s + ',char(infoEntrada(i)));
        end
        
         fprintf(ArqID,'%s\n\n',char(infoEntrada(end)));
         fprintf('%s\n\n',char(infoEntrada(end)));

         
		AcuVetor = [];
		SenVetor = [];
		EspVetor = [];
        
        for validacao = 1:num_validacoes

			% Define e treina a rede neural
			net = patternnet(Num_neuronios_ocultos);
			net = train(net,caracteristicasEntrada,caracteristicasObjetivo);

			% Visualiza a rede neural
			%view(net);

			% Classifica todos os dados
			classificacao = net(caracteristicasEntrada);

			[~,cm,~,~] = confusion(caracteristicasObjetivo,classificacao);
			Acuracia=((cm(1,1)+cm(2,2))/(sum(sum(cm))))*100;
            
            correta_aceitacao = cm(1,1);
            correta_rejeicao = cm(2,2);
            falsa_aceitacao = cm(1,2);
            falsa_rejeicao = cm(2,1);
            Sensitividade=(correta_aceitacao/(correta_aceitacao + falsa_rejeicao))*100;
            Especificidade=(correta_rejeicao/(correta_rejeicao + falsa_aceitacao))*100;
			
            AcuVetor = [AcuVetor Acuracia];
			SenVetor = [SenVetor Sensitividade];
			EspVetor = [EspVetor Especificidade];

			%fprintf(ArqID,'\nValidação #%d\n',validacao);
			%fprintf(ArqID,'Resultados:\n');
			%fprintf(ArqID,'Acurácia: %f%%\n', Acuracia);
			%fprintf(ArqID,'Sensitividade: %f%%\n', Sensitividade);
			%fprintf(ArqID,'Especificidade: %f%%\n', Especificidade);
			
        end
		
			fprintf(ArqID,'Acurácia\n-------------\nMédia: %.2f%%\nDesvio Padrão: %.3f\n\n', median(AcuVetor), std(AcuVetor)/sqrt(num_validacoes));
			fprintf(ArqID,'Sensibilidade\n-------------\nMédia: %.2f%%\nDesvio Padrão: %.3f\n\n', median(SenVetor), std(SenVetor)/sqrt(num_validacoes));
			fprintf(ArqID,'Especificidade\n-------------\nMédia: %.2f%%\nDesvio Padrão: %.3f\n\n', median(EspVetor), std(EspVetor)/sqrt(num_validacoes));
		
            if (melhor_acu < mean(AcuVetor))
                melhor_acu = mean(AcuVetor);
                melhor_comb = infoEntrada;
                fprintf('Novo melhor valor encontrado');
                melhor_comb
                fprintf('Apresentando Acurácia média de: %.3f%%\n',melhor_acu);
            end
     end
end

fprintf(ArqID, '\n\nMelhores resultados foram para as características:\n');
fprintf('\n\nMelhores resultados foram para as características:\n');

for i = 1:(size(melhor_comb, 1)-1)
    fprintf(ArqID, '%s + ',char(melhor_comb(i)));
	fprintf('%s + ',char(melhor_comb(i)));
end
fprintf(ArqID, '%s\n\n',char(melhor_comb(end)));
fprintf('%s\n\n',char(melhor_comb(end)));

% Fecha o arquivo
fclose(ArqID);

% Referências:
% [1] - http://www.mathworks.com/help/nnet/ref/plotconfusion.html
