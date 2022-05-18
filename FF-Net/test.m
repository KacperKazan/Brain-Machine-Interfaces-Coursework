function RMSE = test_angle_classification_accuracy()
    load monkeydata_training.mat
    
    % Set random number generator
    rng(2013);
    ix = randperm(length(trial));
    
    % Select training and testing data (you can choose to split your data in a different way if you wish)
    trainingData = trial(ix(1:50),:);
    testData = trial(ix(51:end),:);
    
    
    meanSqError = 0;
    n_predictions = 0; 
    
    
%     figure
%     hold on
%     axis square
%     grid

    % anglesPredictionsResults(x, 1) is correct predictions counter
    % anglesPredictionsResults(x, 2) is total predictions counter

%     anglesPredictionsResults = cell(8, 2);
%     anglesPredictionsResults(:, :) = {0};
    anglesPredictionsResults = zeros(8,2);

    % Train Model
    size(trainingData(1,1))
    modelParameters = positionEstimatorTraining(trainingData);
    
    for tr=1:size(testData,1)
        for direc = 1:size(testData,2)
            decodedHandPos = [];
    
            times=[320];
            % times=320:20:size(testData(tr,direc).spikes,2);
            
            for t=times
                past_current_trial.trialId = testData(tr,direc).trialId;
                past_current_trial.spikes = testData(tr,direc).spikes(:,1:t); 
                past_current_trial.decodedHandPos = decodedHandPos;
    
                past_current_trial.startHandPos = testData(tr,direc).handPos(1:2,1); 
                past_current_trial.dir = direc;
                
                estimatedAngle = angleEstimator(past_current_trial, modelParameters);
                if estimatedAngle == direc
                    anglesPredictionsResults(direc, 1) = anglesPredictionsResults(direc, 1) + 1;
                end

                anglesPredictionsResults(direc, 2) = anglesPredictionsResults(direc, 2) + 1;
                
            end
        end
    end
    
    disp(anglesPredictionsResults)
    for direc = 1:8
      accuracy = anglesPredictionsResults(direc, 1) / anglesPredictionsResults(direc, 2);
      disp(["angle: ", direc, " accuracy ", accuracy]);
    end
      accuracy = sum(anglesPredictionsResults(:, 1)) / sum(anglesPredictionsResults(:, 2));
      disp(["total accuracy :", accuracy]);
      disp("net layer dimensions")
      for i = 1:modelParameters.net.numLayers
        disp(modelParameters.net.layers{i}.dimensions)
      end
end