function [x,y,newKparams] = Ktest(input,Kparams,ang)
    % change ang so that it depends on your knn 
    startpos = input.startHandPos; 
    
    ang 
    ho = Kparams 
    
    % Gaussian filtering 
    w = gausswin(10); 
    spikes = filter(w,1,input.spikes(:,end)); 
    
    A = Kparams(ang).A; 
    H = Kparams(ang).H; 
    
    W = Kparams(ang).W; 
    Q = Kparams(ang).Q; 
    
    if (isempty(input.decodedHandPos)) 
        x_est_true_init = startpos; 
        P_post_init = zeros(2); 
    else 
        x_est_true_init = Kparams(ang).x_est_true_init; 
        P_post_init = Kparams(ang).P_post_init; 
    end 
    
    x_est = A*x_est_true_init; 
    
    P = A*P_post_init*transpose(A) + W; 
    
    % Kalman gain matrix 
    K = (P*transpose(H)) / (H*P*transpose(H) + Q); 
    
    % Final estimate
    predictedpos = x_est + K*(spikes - H*x_est); 
    
    x = predictedpos(1); 
    y = predictedpos(2); 
    
    % Posterior error covariance matrix 
    P_post = (eye(2) - K*H)*P; 
    
    newKparams = Kparams; 
    newKparams(ang).P_post_init = P_post; 
    newKparams(ang).x_est_true_init = predictedpos; 
end

