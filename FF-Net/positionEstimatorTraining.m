function [modelParameters] = positionEstimatorTraining(training_data)
  % Arguments:
  
  % - training_data:
  %     training_data(n,k)              (n = trial id,  k = reaching angle)
  %     training_data(n,k).trialId      unique number of the trial
  %     training_data(n,k).spikes(i,t)  (i = neuron id, t = time)
  %     training_data(n,k).handPos(d,t) (d = dimension [1-3], t = time)
  
  % ... train your model
  
  % Return Value:
  
  % - modelParameters:
  %     single structure containing all the learned parameters of your
  %     model and which can be used by the "positionEstimator" function.
  % separate network for each direction


  % Neural Network Angle Classifier
  % Pre-Processing Inputs
  training_data(1,1)
  group_size = 320;
  target = {};
  spikes = {};

  for dir = 1:size(training_data, 2)
    for N = 1:size(training_data, 1)
      index = (N-1)*size(training_data,2) + dir;
      spikes(:, index) = {mean(training_data(N,dir).spikes(:, 1:group_size), 2)}; 
      
%       target(1, index) = {onehot(dir, size(training_data, 2))};
      target(1, index) = {full(ind2vec(dir, size(training_data, 2)))};
    end
  end

  X = spikes;
  T = target;

  net = patternnet([32, 32]);
  net = train(net, X, T);

  modelParameters = struct();
  modelParameters.net = net;


  % KNN Classifier
  nbtr = size(training_data,1); 

  

  train_x = zeros(98,8*nbtr); 
  for k = 1:8 
      for tr = 1:nbtr
          for nu = 1:98 
              train_x(nu,(nbtr*k-nbtr)+tr) = sum(training_data(tr,k).spikes(nu,:))/length(training_data(tr,k).spikes(nu,:)); 
          end 
      end 
  end 

 modelParameters.knn = struct();
 modelParameters.knn_train_x = train_x;
 [num_trials , num_classes]= size(training_data);


  modelParameters.olddata = training_data;
 % find average trajectory for each angle
  trajectories = {};
  for ang = 1:num_classes
      % make the handPos trajectories all the same length and find average
      traj = training_data(1,ang).handPos;
      division_count = zeros(1,1500);
      for trial = 2:num_trials
          current_traj = training_data(trial,ang).handPos;  
          for i = 1:length(current_traj)
              division_count(i) = division_count(i) + 1;
          end
          if length(current_traj) < length(traj)
              traj(:, 1:length(current_traj)) = traj(:, 1:length(current_traj)) + current_traj;
          elseif length(current_traj) > length(traj)
              current_traj(:, 1:length(traj)) = current_traj(:, 1:length(traj)) + traj;
              traj = current_traj;
          end
      end
      for j = 1:length(traj)
          traj(:,j) = traj(:,j) / division_count(j);
      end
      trajectories = [trajectories, traj];
  end
  modelParameters.trajectories = trajectories;
end