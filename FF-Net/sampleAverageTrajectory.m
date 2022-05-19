function [x, y] = sampleAverageTrajectory(modelParameters, direction, total_t, startHandPos)
  %using the known direction, take a mean of nearly trajectorie of trainingdata
  x_sample = [];
  y_sample = [];
  training_for_trail = 1;
  while training_for_trail <=size(modelParameters.training_data, 1) % for all data
      pos_of_trial = modelParameters.training_data(training_for_trail, direction).handPos(1:2, :);
      if (size(pos_of_trial, 2) >= total_t) && norm(modelParameters.training_data(training_for_trail, direction).handPos(1:2,1) - startHandPos) <= 5 
         x_sample = [x_sample , pos_of_trial(1, total_t)];
         y_sample = [y_sample, pos_of_trial(2, total_t)];
      end
      training_for_trail = training_for_trail+1;
  end

  if size( x_sample,2) == 0
    average = cell2mat(modelParameters.trajectories(direction));
    if total_t < size(average,2)
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