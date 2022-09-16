clc; close('all'); clear; %fecha todos os programas

%Lê o arquivo
%vozes patológicas
[y,fs] = audioread('normal15.wav');

y=detrend(y);
n=length(y);
N=86*16000/fs; %Comprimento da janela da média (86 para uma Fs de 16KHz)
espacamento=1;
M=zeros(1,n);
j=0;
M=fmedia(y,N,espacamento); % função da média deslizante
M=detrend(M);
n=length(M);
m=zeros(n,1);

% ***** Determinação dos Impulsos Glotais *****
k=15;
while (k<n-15)
while ((M(k+1)<M(k)) && (k<n-1)), k=k+1; end
while ((M(k+1)>=M(k)) && (k<n-1)), k=k+1; end
if (k<n-15)
sina=y(k-15:k+15);
[pico,indp]=max(sina);
kj=k-15+indp-1;
m(kj,1)=y(kj);
end
end

%%%%%% Determinar os Índices dos Impulsos Glotais %
z=length(m);
v=zeros(1,z);
j=1;
for i=1:z
if m(i)>0.02
v(j)=i;
j=j+1;
end
end
v=v(1:j-1);

sizeV=j-1;
for i=1:sizeV-1
periodo(i)=(v(i+1)-v(i))/fs;
end

for i=1:sizeV-2
jitter(i)=(periodo(i+1)-periodo(i));
end

MP=mean(periodo);
jita=mean(abs(jitter)); %segundo
jitt=(jita/MP)*100; %(%)

%RAP
for i=1:sizeV-3
md3(i)=sum(periodo(i:i+2))/3;
vetor3(i)=periodo(i+1)-md3(i);
end
RAP=(mae(vetor3)/MP)*100;

%ppq5
for i=3:sizeV-3
md5(i)=mean(periodo(i-2:i+2));
vetor5(i)=periodo(i)-md5(i);
end
PPQ5=(mae(vetor5)/MP)*100;

