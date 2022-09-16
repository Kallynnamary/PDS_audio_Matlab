close all; clear; clc;

%% HOSVD for a 3-order tensor A of dimensions I1 x I2 x I3
% Defining the dimensions of tensor A
I1 = 2; 
I2 = 4; 
I3 = 3;        % dimensions

% Defining the tensor A
A = rand(I1, I2, I3); 

% Defining the unfolding A1
A1 =  reshape(A, [I1, I2*I3]); % Rearrange the tensor A according to the dimensions of the unfolding A1

% Applies to SVD to find the singular vector matrices U1, V1 and singular
% values matrix S1
[U1, S1, V1] = svd(A1);

% Defining the unfolding A2
A2 =  reshape(A, [I2, I3*I1]); 

% Applies to SVD to find the singular vector matrices U2, V2 and singular
% values matrix S2
[U2, S2, V2] = svd(A2);

% Defining the unfolding A3
A3 =  reshape(A, [I3, I1*I2]); 

% Applies to SVD to find the singular vector matrices U3, V3 and singular
% values matrix S3
[U3, S3, V3] = svd(A3);

% Calculates the core tensor S
S = nmodeproduct(A, U1', 1); % Mode-1 Product
S = nmodeproduct(S, U2', 2); % Mode-2 Product
S = nmodeproduct(S, U3', 3); % Mode-3 Product

% Creates tensor B to compare with tensor A
B = nmodeproduct(S, U1, 1);  % Mode-1 Product
B = nmodeproduct(B, U2, 2);  % Mode-2 Product
B = nmodeproduct(B, U3, 3);  % Mode-3 Product

% Error between tensors A and B
err = sqrt(sum(sum(sum(abs(B-A).^2))));