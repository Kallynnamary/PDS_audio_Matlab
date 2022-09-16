% Compute misclassification rate using stratified 10-fold
       % cross-validation
       clear; close all; clc;
       
       load('DadosMQR1pc');
       N=7; %número de medidas (características)
       y = EDMxNDLmqr1pc;
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
               ytest = classify(dataEDMxNDLmqr1pc(teIdx,[1 2 3 4 5 6 7]),dataEDMxNDLmqr1pc(trIdx,[1 2 3 4 5 6 7]),y(trIdx,1),'quadratic');
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
           if tipo==1
                       xlswrite('ValidacaoCruzadaMQR.xlsx',acuracia_media,'EDMxNDL','A349')
                       xlswrite('ValidacaoCruzadaMQR.xlsx',acuracia_desvio,'EDMxNDL','A353')
                       xlswrite('ValidacaoCruzadaMQR.xlsx',falsopositivo_media,'EDMxNDL','A357')
                       xlswrite('ValidacaoCruzadaMQR.xlsx',falsopositivo_desvio,'EDMxNDL','A361')
                       xlswrite('ValidacaoCruzadaMQR.xlsx',falsonegativo_media,'EDMxNDL','A365')
                       xlswrite('ValidacaoCruzadaMQR.xlsx',falsonegativo_desvio,'EDMxNDL','A369')
           else
                       xlswrite('ValidacaoCruzadaMQR.xlsx',acuracia_media,'EDMxNDL','A377')
                       xlswrite('ValidacaoCruzadaMQR.xlsx',acuracia_desvio,'EDMxNDL','A381')
                       xlswrite('ValidacaoCruzadaMQR.xlsx',falsopositivo_media,'EDMxNDL','A385')
                       xlswrite('ValidacaoCruzadaMQR.xlsx',falsopositivo_desvio,'EDMxNDL','A389')
                       xlswrite('ValidacaoCruzadaMQR.xlsx',falsonegativo_media,'EDMxNDL','A393')
                       xlswrite('ValidacaoCruzadaMQR.xlsx',falsonegativo_desvio,'EDMxNDL','A397')    
           end
       
       
     