function [x, y, newModelParameters] = positionEstimator(test_data, modelParameters)

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
  function output = g_filter(spikes)
      output = zeros(size(spikes));
      for n = 1:size(spikes,1)
          output(n,:) = filter(gausswin(10), 1, spikes(n, :));
      end
  end

  wdw = 100;
  sigma = 20;
  
  % Return Value:
  net = modelParameters.Models{test_data.dir}.net;

  X = con2seq(g_filter(test_data.spikes, wdw, sigma));
  [Xs,Xi,Ai,~] = preparets(net,X);
  result = net(Xs,Xi,Ai);

  x = 0;
  y = 0;

  if ~isempty(result)
    Dpos = seq2con(result);
    DposC = sum(Dpos{:},2);

    x = DposC(1) + 0;
    y = DposC(2) + 0;
  end

  newModelParameters = modelParameters;
  % TODO: could genralise the way we we find the start of an inference run
  if length(test_data.spikes) == 320
    newModelParameters.start = [x,y];
  end

  x = x - newModelParameters.start(1) + test_data.startHandPos(1);
  y = y - newModelParameters.start(2) + test_data.startHandPos(2);
end