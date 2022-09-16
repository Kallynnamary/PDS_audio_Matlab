# Matlab_PDS e decomposicao tensorial

Repositório de códigos em Matlab para Processamento Digital de Áudio e Decomposição Tensorial (Algebra Multilinear)

Os códigos aqui apresentados são divididos em duas classe. A primeira, apresenta os códigos utilizados para extração de características e classificação de sinais de audio. A segunda classe são exemplos de aplicações para decomposições tensoriais em Algebra Multilinear.

Classe 1 - algoritmos para PDS
Para realizar a extração de característica, utilizar a função "audioread" para leitura do sinal de áudio.

Extração de características:
- Formantes
- Jitter
- Coeficientes LPC
- Pitch
- Frequencia fundamental

Rede neural/Classificador: 
- K-means
- Codebook
- Rede neural  Multi Layer Perceptron (MLP)


Classe 2) Decomposições tensoriais

Nesta classe são apresentados algumas aplicações de decomposições tensoriais que estou utilizando durante o doutorado para estimação de parâmetros em decomposição de tensores e matrizes.
As decomposições são:
- CUR para matrizes;
- SVD truncada;
- Decomposição CX para tensores;
- Decomposição TT-SVD para tensores;
- Decomposição HOSVD para tensores;

Nesta classe, são usados também algumas funções da Toolbox Tensor Lab.
Esta Toolbox encontra-se em: https://www.tensorlab.net/

