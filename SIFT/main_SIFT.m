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

%% Parameters
Gsigma = 1.6;          % Scale unit in the Gaussian pyramid
nLayers = 3;           % Number of DoG center layers
contrast_thr_1 = 0.03; % Contrast threshold in keypoint detection
contrast_thr_2 = 0.03;
edge_thr = 10;         % Edge threshold in keypoint detection
type_des = 'SIFT';     % Type of descriptor: 'SIFT' or 'LogPolar'
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

%% The number of octaves in Gaussian pyramid
nOctaves_1 = floor(log2(min(size(I1,1),size(I1,2)))-2);
nOctaves_2 = floor(log2(min(size(I2,1),size(I2,2)))-2);

%%
warning off
    fprintf('\n** Registration starts, have fun\n\n'); ts=cputime;

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%% Reference

%% Gaussian pyramid of reference image
tic;
[I1_gauss,I1_grad,I1_angle] = ...
    Build_Gaussian_Pyramid(I1,nOctaves_1,nLayers,Gsigma);
disp(['参考图像创建Gauss Pyramid花费时间是：',num2str(toc),'s']);

%% DoG pyramid of reference image
tic;
I1_DoG = Build_DoG_Pyramid(I1_gauss,nOctaves_1,nLayers);
disp(['参考图像创建DoG Pyramid花费时间是：',num2str(toc),'s']);

%% Display the pyramids of reference image
% Display_Pyramid(I1_gauss,I1_DoG,I1_grad,I1_angle,...
%     nOctaves_1,nLayers,'Reference image');

%% Reference image DoG pyramid local extreme point detection
tic;
keypoints_1 = Detect_Keypoint...
    (I1_DoG,nOctaves_1,nLayers,Gsigma,...
     contrast_thr_1,edge_thr,I1_grad,I1_angle);
disp(['参考图像关键点定位花费时间是：',num2str(toc),'s']);
clear I1_DoG;

% Display_Keypoint(I1_gauss,nOctaves_1,nLayers,keypoints_1)
clear I1_gauss;

%% Descriptor generation of the reference image 
tic;
descriptors_1 = Generate_Descriptor(I1_grad,I1_angle,...
	keypoints_1,type_des);
disp(['参考图像描述符生成花费时间是：',num2str(toc),'s']); 
clear I1_grad;
clear I1_angle;

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%% Sensed

%% Gaussian pyramid of the image to be registered
tic;
[I2_gauss,I2_grad,I2_angle] = ...
    Build_Gaussian_Pyramid(I2,nOctaves_2,nLayers,Gsigma);
disp(['待配准图像创建Gauss Pyramid花费时间是：',num2str(toc),'s']);

%% DoG of the image to be registered
tic;
I2_DoG = Build_DoG_Pyramid(I2_gauss,nOctaves_2,nLayers);
disp(['待配准图像创建DoG Pyramid花费时间是：',num2str(toc),'s']);

%% Display the pyramids of image to be registered
% Display_Pyramid(I2_gauss,I2_DoG,I2_grad,...
% 	I2_angle,nOctaves_2,nLayers,'Image to be registered');

%% Image to be registered DoG pyramid local extreme point detection
tic;
keypoints_2 = Detect_Keypoint...
    (I2_DoG,nOctaves_2,nLayers,Gsigma,...
     contrast_thr_2,edge_thr,I2_grad,I2_angle);
disp(['待配准图像关键点定位花费时间是：',num2str(toc),'s']);
clear I2_DoG;

% Display_Keypoint(I2_gauss,nOctaves_1,nLayers,keypoints_2)
clear I2_gauss;

%% Descriptor generation of the Image to be registered
tic;
descriptors_2 = Generate_Descriptor(I2_grad,I2_angle,...
	keypoints_2,type_des);
disp(['待配准图像描述符生成花费时间是：',num2str(toc),'s']); 
clear I2_grad;
clear I2_angle;

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%% Match

%% Keypoint matching
tic;
[cor1,cor2,solution,rmse] = ...
    Match_Keypoint(descriptors_1,descriptors_2,trans_form);
disp(['特征点匹配花费时间是：',num2str(toc),'s']);

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