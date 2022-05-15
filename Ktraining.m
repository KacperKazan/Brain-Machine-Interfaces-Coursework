function Kparams = Ktraining(trails)

% Now you need to do this for all angles and trials 

for ang = 1:size(trails,2) % looping across angles 
    handtrail = trails(1,ang).handPos(1:2,301:end-100); % only x and y  
    spiketrail = trails(1,ang).spikes(:,301:end-100); 

    % Gaussian filtering 
    w = gausswin(10); 
    spiketrail = filter(w,1,spiketrail); 
    
    % Number of time instants for this trial and this angle 
    M = length(handtrail); 

    % Check this below 
    X = handtrail(1:2,:); 
    X_1 = handtrail(1:2,1:end-1); 
    X_2 = handtrail(1:2,2:end); 
    Z = spiketrail; 

    Kparams(ang).A = X_2*transpose(X_1) / (X_1*transpose(X_1)); 
    Kparams(ang).H = Z*transpose(X) / (X*transpose(X)); 

    Kparams(ang).W = ((X_2 - Kparams(ang).A*X_1)*(transpose(X_2 - Kparams(ang).A*X_1)))./(M-1); 
    Kparams(ang).Q = ((Z - Kparams(ang).H*X)*(transpose(Z - Kparams(ang).H*X)))./M; % check that positive definite 
end 
end

