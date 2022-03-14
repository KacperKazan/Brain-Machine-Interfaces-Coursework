% Kalman % 
% Assumes that the state is LINEARLY related to the observations 

load monkeydata_training 

% Number of neural units 
C = length(trial(1,1).spikes(:,1)); 
% Matrix that linearly relates the hand state to the neural firing
% z_k = H_k.x_k + q_k (at t = t_k) w/ q_k 0-mean & normally distributed
% noise, following N(0,Q_k) w/ Q_k the covariance matrix 
% states assumed to propagate in time according to x_k+1 = A_k.x_k + w_k
% w/ A_k the coefficient matrix (2x2) and noise term w_k 
% Assume that all of these things are constant 

% Estimating the coefficient matrices by least squares 
% Inter matrixes 
tr = 1; 

M = length(trial(tr,1).handPos(1:2,:)); 

X = trial(tr,1).handPos(1:2,:); 
X_1 = trial(tr,1).handPos(1:2,1:end-1); 
X_2 = trial(tr,1).handPos(1:2,2:end); 
Z = trial(tr,1).spikes(:,:); 

A = X_2*X_1'*inv(X_1*X_1'); 
H = Z*X'*inv(X*X'); 
    
W = (X_2 - A*X_1)*(X_2 - A*X_1)'/(M-1); 
Q = (Z - H*X)*(Z-H*X)'/M; 

% Step 1 
x_est = zeros(2,M); 
x_est(:,1) = [0,0]; 

x_est_true = zeros(2,M); 

error1 = zeros(2,M); 

P = zeros(2,2,M);
% Problem here probably? - no actually 
P(:,:,1) = [0,0;0,0]; 

I = eye(2); 

for k = 2:M
    x_est(:,k) = A*x_est(:,k-1);  
    
    P(:,:,k) = A*P(:,:,k-1)*A' + W;
    
    K = P(:,:,k)*H'*inv(H*P(:,:,k)*H' + Q);  

    x_est_true(:,k) = x_est(:,k) + K*(trial(tr,1).spikes(:,k) - H*x_est(:,k));
    
    % Problem here?  
    P(:,:,k) = (I - K*H)*P(:,:,k); 
end 



