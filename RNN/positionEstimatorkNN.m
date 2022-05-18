function [x, y] = positionEstimatorkNN(test_data, modelParameters)

  % **********************************************************
  %
  % You can also use the following function header to keep your state
  % from the last iteration
  %
  % function [x, y, newModelParameters] = positionEstimator(test_data, modelParameters)
  %                 ^^^^^^^^^^^^^^^^^^
  % Please note that this is optional. You can still use the old function
  % declaration without returning new model parameters. 
  %
  % *********************************************************

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
  
  
  
  % ... compute position at the given timestep.
  function output = g_filter(spikes, wdw, sigma)
      output = zeros(size(spikes));
      for n = 1:size(spikes,1)
          a = 1/(sigma*sqrt(2*pi));
          x = -(wdw-1)/2:(wdw-1)/2;
          g = a*exp(-(x.^2)./(2*sigma^2));
          g_spikes = conv(spikes(n,:),g);
          output(n,:) = g_spikes(wdw/2:end-wdw/2);
      end
  end

  wdw = 100;
  sigma = 20;
  
  % Return Value:
  % Here direction find direction thanks to k-NN 
  % Include training data in the parameters 
  nbtr = size(modelParameters.trainingData,1); 

  % This will hold the firing frequency for each neural unit 
  test_x = zeros(98,1); 
  
  for nu = 1:98 
      % Check that test_data.spikes is good 
      test_x(nu,1) = sum(test_data.spikes)/length(test_data.spikes); 
  end 

  train_x = zeros(98,8*nbtr); 

  for k = 1:8 
      for tr = 1:nbtr
          for nu = 1:98 
              train_x(nu,(nbtr*k-nbtr)+tr) = sum(trainingData(tr,k).spikes(nu,:))/length(trainingData(tr,k).spikes(nu,:)); 
          end 
      end 
  end 
  % 
  
  net = modelParameters{knn_loop(test_x,train_x,k)}.net; % find direction thanks to k-NN 
  lastPos = test_data.startHandPos();
%   disp(["size of start", size(lastPos)])
  if ~isempty(test_data.decodedHandPos)
%     disp("size of decoded");
%     size(test_data.decodedHandPos)
    lastPos = test_data.decodedHandPos(end-1:end);
  end

  X = con2seq(g_filter(test_data.spikes, wdw, sigma));
%   X(:,end+1:10000) = NaN;
  [Xs,Xi,Ai,~] = preparets(net,X);
  result = net(Xs,Xi,Ai);
%   result = net(X);

  x = lastPos(1);
  y = lastPos(2);

  if ~isempty(result)
    Dpos = seq2con(result);
%     Dpos = result;
    DposC = sum(Dpos{:},2);

    x = DposC(1) + test_data.startHandPos(1);
    y = DposC(2) + test_data.startHandPos(2);
  end
end

function direction = knn_loop(test_x,train_x,k) 
    nbtr = size(train_x,2)/8; 
    
    euclidean_distances = zeros(1,8*nbtr); 
        
    for i = 1:8*nbtr 
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
        choose(ceil(knearestneighbours(i)/nbtr),1) = choose(ceil(knearestneighbours(i)/nbtr),1) + 1; 
    end 
    
    [~, index] = max(choose); 
    
    % angles = [30, 70, 110, 150, 190, 230, 310, 350].*pi/180; 
    
    % angle = angles(index); 
    
    direction = index; 
end