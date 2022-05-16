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
  
  if ~isfile("rnn_network.mat") || true
    % try hidden 8
    hidden = 8;
    delays = 1;

    wdw = 400;
    sigma = 50;

    MAX_LENGTH = 0;
    for N = 1:size(training_data, 1)  
      for dir = 1:size(training_data,2)
        if length(training_data(N, dir).spikes) > MAX_LENGTH
          MAX_LENGTH = length(training_data(N, dir).spikes);
        end
      end
    end

    rnn_network = layrecnet(1:delays,hidden,'traingdx');
    % ensures that X and Y coordinate prediction erros are treated with
    % equal weighting
    rnn_network.performParam.normalization = 'percent';
    for N = 1:size(training_data, 1)  
      for dir = 1:size(training_data,2)
        index = (N-1)*size(training_data,2) + dir;
        % preallocate X and T
        rawInput = g_filter(training_data(N,dir).spikes,wdw,sigma);
        rawInput(:,end+1:MAX_LENGTH) = NaN;
        X{1, index} = rawInput;
        rawTarget = diff(training_data(N,dir).handPos(1:2,:),1,2);

        % not sure if adding 0 at the end is needed
        rawTarget(:,end+1) = 0;
        if length(rawTarget) > MAX_LENGTH
          disp("bigger!")
        end
        rawTarget(:,end+1:MAX_LENGTH) = NaN;
        T{1, index} = rawTarget;
      end
    end

      %Shuffle the data around for less bias
      rand_pos = randperm(length(X));
      X_shuffled = cell(size(X));
      T_shuffled = cell(size(T));
      for k = 1:length(X)
        X_shuffled(k) = X(rand_pos(k));
        T_shuffled(k) = T(rand_pos(k));
      end
      
      [Xs,Xi,Ai,Ts] = preparets(rnn_network,X_shuffled,T_shuffled);
      rnn_network = train(rnn_network,Xs,Ts,Xi,Ai);
    
    save rnn_network
  else
    load rnn_network.mat
  end
  model = struct();
  model.net = rnn_network;
  close all
  modelParameters = model;
end