% Teste de entendimento de K-Means
X = rand(20,2);
figure(1);
plot(X(:,1),X(:,2),'k.');

figure(2);
plot(X(:,1),X(:,2),'b.');
[idx,ctrs] = kmeans(X,6);

figure(2);
hold('on');
plot(X(idx==1,1),X(idx==1,2),'.r');
plot(X(idx==2,1),X(idx==2,2),'.b');
plot(X(idx==3,1),X(idx==3,2),'.g');
plot(X(idx==4,1),X(idx==4,2),'.m');
plot(X(idx==5,1),X(idx==5,2),'.y');
plot(X(idx==6,1),X(idx==6,2),'.k');

% Centroide 1
plot(ctrs(1,1),ctrs(1,2),'or');
% Centroide 2
plot(ctrs(2,1),ctrs(2,2),'ob');
% Centroide 3
plot(ctrs(3,1),ctrs(3,2),'og');
% Centroide 4
plot(ctrs(4,1),ctrs(4,2),'om');
% Centroide 5
plot(ctrs(5,1),ctrs(5,2),'oy');
% Centroide 6
plot(ctrs(6,1),ctrs(6,2),'ok');