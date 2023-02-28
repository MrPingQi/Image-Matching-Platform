%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% Author: Gao Chenzhong
%   Beijing Key Laboratory of Fractional Signals and Systems,
%   Multi-Dimensional Signal and Information Processing Laboratory,
%   School of Information and Electronics, Beijing Institute of Technology
% Contact: gao-pingqi@qq.com
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

function [cor1,cor2] = A_SIFT_matching(I1,I2)
%% Parameters
Gsigma = 1.6;          % Scale unit in the Gaussian pyramid
nLayers = 3;           % Number of DoG center layers
contrast_thr_1 = 0.03; % Contrast threshold in keypoint detection
contrast_thr_2 = 0.03;
edge_thr = 10;         % Edge threshold in keypoint detection
type_des = 'SIFT';     % Type of descriptor: 'SIFT' or 'LogPolar'
nOctaves_1 = floor(log2(min(size(I1,1),size(I1,2)))-2);
nOctaves_2 = floor(log2(min(size(I2,1),size(I2,2)))-2);

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
Display_Pyramid(I1_gauss,'Reference image--Gaussian Pyramid',1);
Display_Pyramid(I1_DoG,'Reference image--DoG Pyramid',1);
Display_Pyramid(I1_grad,'Reference image--Gradient',1);
Display_Pyramid(I1_angle,'Reference image--Orientation',1);

%% Reference image DoG pyramid local extreme point detection
tic;
keypoints_1 = Find_Scale_Extreme...
    (I1_DoG,Gsigma,contrast_thr_1,edge_thr,I1_grad,I1_angle);
disp(['参考图像关键点定位花费时间是：',num2str(toc),'s']);
clear I1_DoG;

Display_Keypoint(I1_gauss,keypoints_1)
clear I1_gauss;

%% Descriptor generation of reference image 
tic;
descriptors_1 = Generate_Descriptor(I1_grad,I1_angle,keypoints_1,type_des);
disp(['参考图像描述符生成花费时间是：',num2str(toc),'s']); 
clear I1_grad;
clear I1_angle;

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%% Sensed
%% Gaussian pyramid of sensed image
tic;
[I2_gauss,I2_grad,I2_angle] = ...
    Build_Gaussian_Pyramid(I2,nOctaves_2,nLayers,Gsigma);
disp(['待配准图像创建Gauss Pyramid花费时间是：',num2str(toc),'s']);

%% DoG of sensed image
tic;
I2_DoG = Build_DoG_Pyramid(I2_gauss,nOctaves_2,nLayers);
disp(['待配准图像创建DoG Pyramid花费时间是：',num2str(toc),'s']);

%% Display the pyramids of sensed image
Display_Pyramid(I2_gauss,'Sensed image--Gaussian Pyramid',1);
Display_Pyramid(I2_DoG,'Sensed image--DoG Pyramid',1);
Display_Pyramid(I2_grad,'Sensed image--Gradient',1);
Display_Pyramid(I2_angle,'Sensed image--Orientation',1);

%% Sensed image DoG pyramid local extreme point detection
tic;
keypoints_2 = Find_Scale_Extreme...
    (I2_DoG,Gsigma,contrast_thr_2,edge_thr,I2_grad,I2_angle);
disp(['待配准图像关键点定位花费时间是：',num2str(toc),'s']);
clear I2_DoG;

Display_Keypoint(I2_gauss,keypoints_2)
clear I2_gauss;

%% Descriptor generation of the Sensed image
tic;
descriptors_2 = Generate_Descriptor(I2_grad,I2_angle,keypoints_2,type_des);
disp(['待配准图像描述符生成花费时间是：',num2str(toc),'s']); 
clear I2_grad;
clear I2_angle;

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%% Match
%% Keypoint matching
tic;
[cor1,cor2] = Match_Keypoint(descriptors_1,descriptors_2);
disp(['特征点匹配花费时间是：',num2str(toc),'s']);