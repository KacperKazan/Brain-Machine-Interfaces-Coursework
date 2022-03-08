load monkeydata_training

test_x = zeros(98,1); 
ktest = 4; 
trialtest = 30; 

for nu = 1:98 
    test_x(nu,1) = sum(trial(trialtest,ktest).spikes(nu,:))/length(trial(trialtest,ktest).spikes(nu,:)); 
end 

train_x = zeros(98,800); 

for k = 1:8 
    for tr = 1:100 
        for nu = 1:98 
            train_x(nu,(100*k-100)+tr) = sum(trial(tr,k).spikes(nu,:))/length(trial(tr,k).spikes(nu,:)); 
        end 
    end 
end 

% Calling function 
angle = knn_loop(test_x,train_x,5);  

function angle = knn_loop(test_x,train_x,k) 
    
    euclidean_distances = zeros(1,800); 
        
    for i = 1:800 
        % compute euclidian distance 
        euclidean_distances(1,:) = sqrt(sum((test_x - train_x).^2)); 
    end
    
    % sort them
    [~, position] = sort(euclidean_distances,'ascend'); 
    knearestneighbours = position(1:k); 

    % extract the angles associated to the k smallest distances,
    % associate that angle to the test data 
    % Link position to angle 
    
    choose = zeros(8,1); 
    
    for i = 1:k
        choose(ceil(knearestneighbours(i)/100),1) = choose(ceil(knearestneighbours(i)/100),1) + 1; 
    end 
    
    [~, index] = max(choose); 
    
    angles = [30, 70, 110, 150, 190, 230, 310, 350].*pi/180; 
    
    angle = angles(index); 
end