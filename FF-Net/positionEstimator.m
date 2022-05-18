function [x, y] = positionEstimator(test_data, modelParameters)

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
  outcome = angleEstimator(test_data, modelParameters);
  total_t = size(test_data.spikes, 2);


  %using the known direction,take a mean of nearly trajectorie of trainingdata
  x_sample = [];
  y_sample = [];
  training_for_trail = 1;
  while training_for_trail <=size(modelParameters.olddata, 1) % for all data
      pos_of_trial = modelParameters.olddata(training_for_trail, outcome).handPos(1:2, :);
      if (size(pos_of_trial, 2) >= total_t) && norm(modelParameters.training_data(training_for_trail, outcome).handPos(1:2,1) - test_data.startHandPos(1:2,1)) <= 5 
         x_sample = [x_sample , pos_of_trial(1, total_t)];
         y_sample = [y_sample, pos_of_trial(2, total_t)];
      end
      training_for_trail = training_for_trail+1;
  end

  if size( x_sample,2) == 0
    average = cell2mat(modelParameters.trajectories(outcome));
    if max_time < size(average,2)
        x = average(1, total_t);
        y = average(2, total_t);
    else
        x = average(1, end);
        y = average(2, end);
    end
  else
     x = mean(x_sample);
     y = mean(y_sample);
  end

end