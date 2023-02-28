%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% Author: Gao Chenzhong
%   Beijing Key Laboratory of Fractional Signals and Systems,
%   Multi-Dimensional Signal and Information Processing Laboratory,
%   School of Information and Electronics, Beijing Institute of Technology
% Contact: gao-pingqi@qq.com
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

close all; clear; clc;
%% Make fileholder for images saving
if (exist('save_image','dir') == 0) % 如果文件夹不存在
    mkdir('save_image');
end

%% What spatial transformation model do you need at the end
% trans_form = 'similarity';
trans_form = 'affine';
% trans_form = 'projective';
% trans_form = 'polynomial-2'; % n = 2,3,... (only for output_form = 'Reference')
%% What image pair output form do you need at the end
% output_form = 'Reference';
output_form = 'Union';
% output_form = 'Inter';

%% Read images
[image_1,image_2,file1,file2] = Readimage;
% [image_1,image_2,~,~] = Readimage(file1,file2);

%% Image preproscessing
resample1 = 1/1; resample2 = 1/1;
[I1_s,I1] = Preproscessing(image_1,resample1,[]); % resample: one may pre-resample the images to avoid unnecessary burdens
[I2_s,I2] = Preproscessing(image_2,resample2,[]); % []: one may select 1 or 3 bands for display, eg.[8,4,3]
figure,imshow(I1_s),title('Reference image'); pause(0.01)
figure,imshow(I2_s),title('Sensed Image'); pause(0.01)
% figure,imshow(I1),title('Reference image'); pause(0.01)
% figure,imshow(I2),title('Sensed Image'); pause(0.01)
if size(resample1,2)==1
    resample1 = [resample1,resample1];
end
if size(resample2,2)==1
    resample2 = [resample2,resample2];
end

%%
warning off
    fprintf('\n** Matching starts, have fun\n\n'); ts=cputime;

addpath('SIFT'); [cor1,cor2] = A_SIFT_matching(I1,I2);

% matchment = Show_Matches(I1,I2,cor1,cor2,1); pause(0.01)
cor1 = [cor1(:,1)/resample1(2), cor1(:,2)/resample1(1);];
cor2 = [cor2(:,1)/resample2(2), cor2(:,2)/resample2(1);];
matchment = Show_Matches(I1_s,I2_s,cor1,cor2,1); pause(0.01)

%% Image transformation
tic
switch output_form
    case 'Reference'
        [I2_r,I2_rs,I3,I4] = Transform_ref...
            (image_1,image_2,cor1,cor2,trans_form);
    case 'Union'
        [I1_r,I2_r,I1_rs,I2_rs,I3,I4] = Transform_union...
            (image_1,image_2,cor1,cor2,trans_form);
    case 'Inter'
        [I1_r,I2_r,I1_rs,I2_rs,I3,I4] = Transform_inter...
            (image_1,image_2,cor1,cor2,trans_form);
end
    str=['Done: Image tranformation, time cost: ',num2str(toc),'s\n\n']; fprintf(str); tic
figure; imshow(I3,[]); title('Fusion Form'); pause(0.01)
figure; imshow(I4,[]); title('Mosaic Form'); pause(0.01)

%% Save results
if (exist('save_image','dir')==0) % If file folder does not exist
    mkdir('save_image');
end
Date = datestr(now,'yyyy-mm-dd_HH-MM-SS__');
correspond = cell(2,1); correspond{1} = cor1; correspond{2} = cor2;
str=['.\save_image\',Date,'0 correspond','.mat']; save(str,'correspond')
if isvalid(matchment)
    str=['.\save_image\',Date,'0 Matching Result','.jpg']; saveas(matchment,str);
end
switch output_form
    case 'Reference'
        str=['.\save_image\',Date,'1 Reference Image','.mat']; save(str,'image_1');
        str=['.\save_image\',Date,'1 Reference Image','.jpg']; imwrite(I1_s,str);
    otherwise
        str=['.\save_image\',Date,'1 Reference Image','.mat']; save(str,'I1_r');
        str=['.\save_image\',Date,'1 Reference Image','.jpg']; imwrite(I1_rs,str);
end
str=['.\save_image\',Date,'2 Registered Image','.mat']; save(str,'I2_r');
str=['.\save_image\',Date,'2 Registered Image','.jpg']; imwrite(I2_rs,str);
str=['.\save_image\',Date,'3 Fusion of results','.jpg']; imwrite(I3,str);
str=['.\save_image\',Date,'4 Mosaic of results','.jpg']; imwrite(I4,str);
    str='The results are saved in the save_image folder.\n\n'; fprintf(str);