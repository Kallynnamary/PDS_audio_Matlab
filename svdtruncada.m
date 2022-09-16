function [U S V] = svdtruncada(A, r)
%SVDTRUNC Truncated SVD decomposition.
%	[U sv tol] = SVDTRUNC(A)
%	[U sv tol] = SVDTRUNC(A, tol)
%
%	A    - matrix
%	tol  - tolerance, only singular values > tol are kept (default: eps)
%
%	U    - truncated (left) singular vectors
%	sv   - list of truncated singular values
%	tol  - next singular value after truncation
%
%	eg. [U sv tol] = svdtrunc(rand(6,7), 0.5)
%
%	See also HOSVD, SVD.
% Calcula a SVD da matriz a
[U S V] = svd(A);

% Armazena apenas as r primeiras colunas de cada matriz da SVD
U = U(:, 1:r);
S = S(1:r, 1:r);
V = V(:, 1:r);

% Corresponde as ultimas colunas das matrizes da SVD
Urest = U(:, r+1:end);
V = V(:, 1:r);
Vrest = V(:, r+1:end);    
end

