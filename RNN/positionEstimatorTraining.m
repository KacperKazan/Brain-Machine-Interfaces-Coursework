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
  function output = g_filter(spikes)
      output = zeros(size(spikes));
      for n = 1:size(spikes,1)
          output(n,:) = filter(gausswin(10), 1, spikes(n, :));
      end
  end


    modelParameters = struct();
    modelParameters.Models = cell(1, 8);
    modelParameters.start = [0,0];
  
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
  
    for dir = 1:size(training_data, 2)
      rnn_network = layrecnet(1:delays,hidden,'traingdx');
      % ensures that X and Y coordinate prediction erros are treated with
      % equal weighting
      rnn_network.performParam.normalization = 'percent';
  
      for N = 1:size(training_data, 1)  
        index = N;
        % preallocate X and T
        rawInput = g_filter(training_data(N,dir).spikes,wdw,sigma);
        rawInput(:,end+1:MAX_LENGTH) = NaN;
        X{1, index} = rawInput;
        rawTarget = diff(training_data(N,dir).handPos(1:2,:),1,2);
  
        % not sure if adding 0 at the end is needed
        rawTarget(:,end+1) = 0;

        rawTarget(:,end+1:MAX_LENGTH) = NaN;
        T{1, index} = rawTarget;
      end
      [Xs,Xi,Ai,Ts] = preparets(rnn_network,X,T);
      rnn_network = train(rnn_network,Xs,Ts,Xi,Ai);
      

      model = struct();
      model.net = rnn_network;
      close all
      modelParameters.Models{dir} = model;
    end
end