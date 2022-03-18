function output = fr_processing(trial,dt)

output = struct();

output.l_PSTH_non_shifted = cell(98,8);
output.l_local_non_shifted = cell(98,8);

angle_max = 8; % should be 8 for all angles
%angle_max = 2;

output.Av_po = cell(1,angle_max);

sizes_recordings = zeros(size(trial, 1), angle_max);
for n=1:size(trial,1)
    for a = 1:angle_max
        sizes_recordings(n,a) = length(trial(n,a).spikes(1,:));
    end 
end 


for i = 1:size(trial(1,1).spikes,1)
    for a = 1:angle_max
        max_len = max(sizes_recordings(:,a));
        min_len = min(sizes_recordings(:,a));
        output.l_PSTH_non_shifted{i,a} = zeros(1, max_len); 

        A = zeros(1,max_len);
        B = zeros(1,max_len);
        
        output.l_local_non_shifted{i,a} = zeros(size(trial,1), max_len);

        for n = 1:size(trial,1)
            len = length(trial(n,a).spikes(i,:));
            
            B(1:len) = B(1:len) + trial(n,a).spikes(i,:);
           
            output.l_local_non_shifted{i,a}(n,1:length(fr_es(trial(n,a).spikes(i,:),dt))) = fr_es(trial(n,a).spikes(i,:),dt);
            
            B(1:len) = B(1:len) + trial(n,a).spikes(i,:);
        end 

        l = zeros(1,length(B));

        for j = (dt+1):(length(B))
            l(j) = sum(B((j-dt):j))./(dt);
        end
        
        output.l_PSTH_non_shifted{i,a}(1:min_len) = l(1:min_len)./100;
 
 
        for index = (min_len+1):max_len
            output.l_PSTH_non_shifted{i,a}(index) = l(index)./sum((sizes_recordings(:,a)>(index-1)));
        end
     end 
end

    for angle = 1:8
        max_len = max(sizes_recordings(:,angle));
        min_len = min(sizes_recordings(:,angle));

        output.Av_po{angle} = zeros(3,max_len);

        for n = 1:100
            output.Av_po{angle}(:,1:size(trial(n,angle).handPos,2)) = output.Av_po{angle}(:,1:size(trial(n,angle).handPos,2)) + trial(n,angle).handPos;
        end 

        output.Av_po{angle}(:,1:min_len) = output.Av_po{angle}(:,1:min_len)./n;
        for index = (min_len+1):max_len
            output.Av_po{angle}(:,index) = output.Av_po{angle}(:,index)./sum((sizes_recordings(:,angle)>(index-1)));
        end
    end 

end

