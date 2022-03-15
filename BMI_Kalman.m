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

% Truncating the data so that we only have when the monkey moves 
handtrail = trial(tr,1).handPos(1:2,301:end-100); 
spiketrail = trial(tr,1).spikes(:,301:end-100); 

M = length(handtrail); 

X = handtrail(1:2,:); 
X_1 = handtrail(1:2,1:end-1); 
X_2 = handtrail(1:2,2:end); 
Z = spiketrail; 

%{
Z = zeros(98,M); 

for k = 1:M 
    for nu = 1:98 
        Z(nu,k) = sum(spiketrail(nu,1:k))/length(spiketrail(nu,1:k)); 
    end 
end 
%}

A = X_2*transpose(X_1) / (X_1*transpose(X_1)); 
H = Z*transpose(X) / (X*transpose(X)); 
    
W = ((X_2 - A*X_1)*(transpose(X_2 - A*X_1)))./(M-1); 
Q = ((Z - H*X)*transpose(Z - H*X))./M; % check that positive definite 

% Intialise to 0 
x_est = zeros(2,M); 
x_est_true = zeros(2,M); 

% P has to be positive definite, good idea to initialise it to something
% large - multiply identity matrix with big number 
P = zeros(2,2,M);
P_post = zeros(2,2,M); 
K = zeros(2,98,M); 
% Paper initialises P to 0 but we're going to initialise it as Q (other
% paper does this) 

P(:,:,1) = eye(2)*100; 

error1 = zeros(2,M); 

I = eye(2); 

for k = 2:M 
    x_est(:,k) = A*x_est(:,k-1);  
    
    P(:,:,k) = A*P(:,:,k-1)*transpose(A) + W; 
    
    P(:,:,k) = 0.5*(P(:,:,k) + P(:,:,k)'); 
    
    % hey = H*P(:,:,k)*(H)' + Q; 

    K(:,:,k) = P(:,:,k)*transpose(H) / (H*P(:,:,k)*transpose(H) + Q);  
    
    % K(:,:,k) = P_post(:,:,k)*(H)' / Q; 
    
    z = zeros(98,1); 
    
    %{
    for nu = 1:98 
        z(nu,1) = sum(spiketrail(nu,1:k))/length(spiketrail(nu,1:k)); 
    end 
    %}

    x_est_true(:,k) = x_est(:,k) + K(:,:,k)*(Z(:,k) - H*x_est(:,k));
    
    % Check this 
    P_post(:,:,k) = (I - K(:,:,k)*H)*P(:,:,k); 
end 



