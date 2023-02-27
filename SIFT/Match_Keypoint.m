%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% Author: Gao Chenzhong
% Contact: gao-pingqi@qq.com
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

function [cor1,cor2,solution,rmse] = Match_Keypoint(descriptors_1,descriptors_2,trans_form)
distRatio = 0.9;
des1 = descriptors_1.des; loc1 = descriptors_1.kps;
des2 = descriptors_2.des; loc2 = descriptors_2.kps;
for i = 1:size(des1,1)
    % Euclidean distance
    temp_des1 = des1(i,:);
    temp_des1 = repmat(temp_des1,size(des2,1),1);
    diff_des1 = temp_des1-des2;
    ED_distance = sqrt(sum(diff_des1.^2,2));  
    [vals,index] = sort(ED_distance);
    
    % NNDR
    if (vals(1) < distRatio * vals(2))
        match(i) = index(1);
    else
        match(i) = 0;
    end
end
num = sum(match > 0);
fprintf('NNDR Found %d matches.\n', num);
[~,point1,point2] = find(match);

cor1 = loc1(point1,:); cor1 = [cor1 point1'];
cor2 = loc2(point2,:); cor2 = [cor2 point2'];

%% Delete duplicate point pair
[~,indx,~] = unique([cor1(:,[1 2]),cor2(:,[1 2])],'rows','first');
cor1 = cor1(sort(indx)',:); cor2 = cor2(sort(indx)',:);

%% FSC
[solution,rmse,cor2,cor1] = FSC(cor2,cor1,trans_form,1);
fprintf('After FSC, found %d matches.\n', size(cor1,1));