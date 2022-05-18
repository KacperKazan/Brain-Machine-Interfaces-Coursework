function angle = angleEstimator(test_data, modelParameters)
  % - test_data:
  %     test_data(m).trialID
  %         unique trial ID
  %     test_data(m).startHandPos
  %         2x1 vector giving the [x y] position of the hand at the start
  %         of the trial
  %     test_data(m).decodedHandPos
  %         [2xN] vector giving the hand position estimated by your
  %         algorithm during the previous iterations. In this case, N is 
  %         the number of times your function has been called previously on
  %         the same data sequence.
  %     test_data(m).spikes(i,t) (m = trial id, i = neuron id, t = time)
  %     in this case, t goes from 1 to the current time in steps of 20
  %     Example:
  %         Iteration 1 (t = 320):
  %             test_data.trialID = 1;
  %             test_data.startHandPos = [0; 0]
  %             test_data.decodedHandPos = []
  %             test_data.spikes = 98x320 matrix of spiking activity
  %         Iteration 2 (t = 340):
  %             test_data.trialID = 1;
  %             test_data.startHandPos = [0; 0]
  %             test_data.decodedHandPos = [2.3; 1.5]
  %             test_data.spikes = 98x340 matrix of spiking activity
  
  %  Neural Network Classifier
  group_size = 320;
  X = {mean(test_data.spikes(:, 1:group_size), 2)};
  result = cell2mat(modelParameters.net(X));
  result = vec2ind(result);
  angle = result;

  % KNN Classifier

  % This will hold the firing frequency for each neural unit 
%   test_x = zeros(98,1); 
%   for nu = 1:98 
%       % Check that test_data.spikes is good 
%       test_x(nu,1) = sum(test_data.spikes)/length(test_data.spikes); 
%   end 
%   
%   result = knn_loop(test_x,modelParameters.knn_train_x, 5);
% 
%   angle = result;

%   function direction = knn_loop(test_x,train_x,k) 
%     nbtr = size(train_x,2)/8; 
%     
%     euclidean_distances = zeros(1,8*nbtr); 
%         
%     for i = 1:8*nbtr 
%         % compute euclidian distance 
%         euclidean_distances(1,:) = sqrt(sum((test_x - train_x).^2)); 
%     end
%     
%     % sort them
%     [~, position] = sort(euclidean_distances,'ascend'); 
%     knearestneighbours = position(1:k); 
% 
%     % extract the angles associated to the k smallest distances,
%     % associate that angle to the test data 
%     % Link position to angle 
%     
%     choose = zeros(8,1); 
%     
%     for i = 1:k
%         choose(ceil(knearestneighbours(i)/nbtr),1) = choose(ceil(knearestneighbours(i)/nbtr),1) + 1; 
%     end 
%     
%     [~, index] = max(choose);
%     
%     direction = index; 
%   end
end