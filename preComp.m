% pre-comp hw

load monkeydata_training;

% plotting tuning curves for movement directions = directional preference
% of individual neural units 
angles = [30/180*pi,70/180*pi,110/180*pi,150/180*pi,190/180*pi,230/180*pi,310/180*pi,350/180*pi]
neuralbin=zeros(98,8);
for spike = 1:98
    nb = spike; % neural unit number
    direction= zeros(100,8);
    % Storing the firing rates 
    frs = zeros(100,8); 
    % Looping through all time 
    for i = 1:100  % for each trial
        for j = 1:8 % for each angle
            sp_t = trial(i,j).spikes(nb,:); %
            N = length(sp_t); 
        
            % Store firing rate for the trial & angle 
            frs(i,j) = sum(sp_t)/N; 
        end 
    end

    % Averaging across trials
    av = mean(frs);



    for angleindex=1:8
        neuralbin(nb, angleindex) = av(angleindex);
    end
    
    % Plotting average firing rate depending on angle? 
    %figure;
    %scatter(angles,av);
    %hold on;
    %plot(angles,av);
    %title('Neuron 12');
    %xlabel('Angle'); ylabel('Average firing rate');
end

k = 1;
n = 1;
x = trial(n,k).handPos(1,:);
y = trial(n,k).handPos(2,:);
times = 1:length(x);

%[dirs{:}] = arrayfun(@(t) , times, UniformOutput=false);
%%
dirs = zeros([length(x), 2]);
for t = times
    temp = get_direction(n, k, t, neuralbin, trial);
    dirs(t, :) = temp;
end
%%disp(dirs)
disp("_________dirs______________________")
non_nan_indices = find(~isnan(dirs));
%dirs(isnan(dirs)) = 0;

%non_nan_dirs = dirs();
non_nan_dirs = dirs(all((~isnan(dirs)),2), :);
non_nan_indices = find(all((~isnan(dirs)),2));

disp(size(non_nan_dirs));

estimated_angles = arrayfun(@(v1, v2) vec2angle([v1, v2]), non_nan_dirs(:, 1), non_nan_dirs(:, 2));

plot(non_nan_indices, rad2deg(estimated_angles));
real_angles = zeros([length(non_nan_indices), 1]);

%%
for i = 1:length(non_nan_indices)
    non_nan_index = non_nan_indices(i);
    if non_nan_index ~= length(x)
        x_diff = x(non_nan_index + 1) - x(non_nan_index);
        y_diff = y(non_nan_index + 1) - y(non_nan_index);
        real_angles(i) = vec2angle([x_diff, y_diff]);
    end
end

%plot(non_nan_indices, real_angles);

% disp(size(real_angles));
% disp(size(estimated_angles));
% 
% disp(class(estimated_angles));
% disp(class(real_angles));
% disp(estimated_angles);
figure('Name','Angle Difference','NumberTitle','off')

angle_diff = angdiff(real_angles, estimated_angles);
hold on;
plot(non_nan_indices, rad2deg(angle_diff), 'DisplayName','angle difference');
legend();
hold off;
title("Angle difference");

%%
figure('Name','Real vs Estimated Angles','NumberTitle','off')
title("Real vs Estimated Angles");
hold on;
plot(non_nan_indices, rad2deg(real_angles), 'DisplayName','real angles');
% plot(non_nan_indices, rad2deg(estimated_angles), 'DisplayName','estimated angles');
plot(non_nan_indices, movmean(rad2deg(estimated_angles), 3), 'DisplayName','estimated angles moving mean');
legend();
hold off;
%%
MSE = calc_RMSE(rad2deg(real_angles), rad2deg(estimated_angles));
disp(["MSE: ", MSE]);

%%
function [res] = get_direction(n, k, t, neuralbin, trial)
    angles = [30/180*pi,70/180*pi,110/180*pi,150/180*pi,190/180*pi,230/180*pi,310/180*pi,350/180*pi];
    % For one specific trial and angle 
    spikes = trial(n,k).spikes(:,t);

    fired = find(spikes == 1);
    % weight for each angle
    weights = zeros([8, 1]);
    for fired_i = 1:size(fired, 1)
        % sum to the weights
        n = fired(fired_i);
        for k = 1:8
            weights(k) = weights(k) + neuralbin(n,k);
        end
    end
    weights = normalize(weights);
    [angle_vectors{1:2}] = arrayfun(@angle2vec, angles);
    x_dir = 0;
    y_dir = 0;
    for k = 1:8
        x_dir = x_dir + weights(k) * angle_vectors{1}(k);
        y_dir = y_dir + weights(k) * angle_vectors{2}(k);
    end
    disp("--------------")
    disp(x_dir)
    disp(y_dir)
    res = [x_dir, y_dir]
end



function [x, y] = angle2vec(angle) % get directional vector from angle
    x = cos(angle);
    y = sin(angle);
end

function ang = vec2angle(v)
    ang = angle(v(1)+1i*v(2));
end

function d = angdiff(th1, th2)
  
    switch nargin
        case 1
            if length(th1) == 2
                d = th1(1) - th1(2);
            else
                d = th1;
            end
        case 2
            if length(th1) > 1 && length(th2) > 1
                % if both arguments are vectors, they must be the same
                assert(all(size(th1) == size(th2)), 'SMTB:angdiff:badarg', 'vectors must be same shape');
            end
            % th1 or th2 could be scalar
            d = th1 - th2;
    end
    
    % wrap the result into the interval [-pi pi)
    d = mod(d+pi, 2*pi) - pi;
end

function rmse=calc_RMSE(a,b)
    rmse=sqrt(mean((a(:)-b(:)).^2));
end