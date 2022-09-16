% Compute misclassification rate using stratified 10-fold
       % cross-validation
       close all; clear; clc;
       
       load('Dados15medidas');
       N=15; %número de medidas (características)
       y = EDMxNDL15medidas;
       tipo=2;
       
       % A stratified partition is preferred to evaluate classification
       % algorithms.
       cp = cvpartition(y,'k',10);
       
       %classf = @(xtrain, ytrain,xtest)(classify(xtest,xtrain,ytrain));
       %cvMCR = crossval('mcr',cincoconv,y,'predfun', classf,'partition',cp)
       err = zeros(cp.NumTestSets,1);
          for w = 1:cp.NumTestSets
               trIdx = cp.training(w);
               teIdx = cp.test(w);
               %teste(i,:)=teIdx;
               tamanhoTeste=cp.TestSize;
               ytest = classify(dataEDMxNDL15medidas(teIdx,[1 2 3 4 5 6 7 8 9 10 11 12 13 14 15]),dataEDMxNDL15medidas(trIdx,[1 2 3 4 5 6 7 8 9 10 11 12 13 14 15]),y(trIdx,1),'quadratic');
               [MatrizConfusao,grpOrder] = confusionmat(y(teIdx),ytest);
               txfalsopositivo(w)=(MatrizConfusao(1,2)/(MatrizConfusao(1,1)+MatrizConfusao(1,2)))*100;
               txfalsonegativo(w)=(MatrizConfusao(2,1)/(MatrizConfusao(2,1)+MatrizConfusao(2,2)))*100;
               err(w) = sum(~strcmp(ytest,y(teIdx)));
               taxaclassifica(w)= ((tamanhoTeste(w)-err(w))/tamanhoTeste(w))*100;
           end
           acuracia_media=mean(taxaclassifica);
           acuracia_desvio=std(taxaclassifica);
           falsopositivo_media=mean(txfalsopositivo);
           falsopositivo_desvio=std(txfalsopositivo);
           falsonegativo_media=mean(txfalsonegativo);
           falsonegativo_desvio=std(txfalsonegativo);
           %cvErr = sum(err)/sum(cp.TestSize);
           acmax=max(acuracia_media);
           if tipo==1
                       xlswrite('ValidacaoCruzada15medidas.xlsx',acuracia_media,'EDMxNDL','A793')
                       xlswrite('ValidacaoCruzada15medidas.xlsx',acuracia_desvio,'EDMxNDL','A797')
                       xlswrite('ValidacaoCruzada15medidas.xlsx',falsopositivo_media,'EDMxNDL','A801')
                       xlswrite('ValidacaoCruzada15medidas.xlsx',falsopositivo_desvio,'EDMxNDL','A805')
                       xlswrite('ValidacaoCruzada15medidas.xlsx',falsonegativo_media,'EDMxNDL','A809')
                       xlswrite('ValidacaoCruzada15medidas.xlsx',falsonegativo_desvio,'EDMxNDL','A813')            
           else
                       xlswrite('ValidacaoCruzada15medidas.xlsx',acuracia_media,'EDMxNDL','A821')
                       xlswrite('ValidacaoCruzada15medidas.xlsx',acuracia_desvio,'EDMxNDL','A825')
                       xlswrite('ValidacaoCruzada15medidas.xlsx',falsopositivo_media,'EDMxNDL','A829')
                       xlswrite('ValidacaoCruzada15medidas.xlsx',falsopositivo_desvio,'EDMxNDL','A833')
                       xlswrite('ValidacaoCruzada15medidas.xlsx',falsonegativo_media,'EDMxNDL','A837')
                       xlswrite('ValidacaoCruzada15medidas.xlsx',falsonegativo_desvio,'EDMxNDL','A841')            
           end
       
       
     