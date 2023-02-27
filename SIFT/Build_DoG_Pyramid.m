%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% Author: Gao Chenzhong
% Contact: gao-pingqi@qq.com
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

function DoG = Build_DoG_Pyramid...
    (gaussian,nOctaves,dog_center_layer)

DoG = cell(nOctaves,dog_center_layer+2);
for i = 1:nOctaves
    for j = 1:dog_center_layer+2
        DoG{i,j}(:,:) = ...
            gaussian{i,j+1}(:,:) - gaussian{i,j}(:,:);
    end
end