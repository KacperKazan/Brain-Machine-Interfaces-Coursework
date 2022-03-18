function K = trainKalman(output)
%UNTITLED5 Summary of this function goes here
%   Detailed explanation goes here
    for angle = 1:length(output.Av_po)
        len = size(output.Av_po{angle},2);
        
        K{angle}.X = output.Av_po{angle}(1:2,1:len); 
        K{angle}.X_1 = output.Av_po{angle}(1:2,1:(len-1)); 
        K{angle}.X_2 = output.Av_po{angle}(1:2,2:len);
        K{angle}.A = K{angle}.X_2*transpose(K{angle}.X_1)*inv(K{angle}.X_1*transpose(K{angle}.X_1));
        
        for i = 1:98
            K{angle}.Z(i,:) = output.l_PSTH_non_shifted{i,angle}(:,1:len); 
        end 
        
        K{angle}.H = K{angle}.Z*transpose(K{angle}.X)*inv(K{angle}.X*transpose(K{angle}.X)); 
        
        K{angle}.W = (K{angle}.X_2-K{angle}.A*K{angle}.X_1)*transpose(K{angle}.X_2-K{angle}.A*K{angle}.X_1)./(size(K{angle}.X_1,2));
        K{angle}.Q = (K{angle}.Z - K{angle}.H*K{angle}.X)*transpose(K{angle}.Z - K{angle}.H*K{angle}.X)/(size(K{angle}.Z,2)); 
    end
end

