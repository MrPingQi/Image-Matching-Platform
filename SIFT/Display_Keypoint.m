%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% Author: Gao Chenzhong
% Contact: gao-pingqi@qq.com
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

function Display_Keypoint(gaussian,nOctaves,nLayers,keypoints)
size_image = zeros(nOctaves,2);
for i = 1:nOctaves
    size_image(i,1:2) = size(gaussian{i,1});
end
%% display Gaussian Pyramid
ROW_size = sum(size_image);
ROW_size = ROW_size(1);
COL_size = size_image(1,1)*(nLayers+3);
gauss_pyramid = zeros(ROW_size,COL_size);
accumulate_ROW = 0;
for i = 1:nOctaves
    accumulate_ROW = accumulate_ROW+size_image(i,1);
    accumulate_COL = 0;
    for j = 1:nLayers+3
        accumulate_COL = accumulate_COL+size_image(i,2);
        gauss_pyramid(accumulate_ROW-size_image(i,1)+1:accumulate_ROW,...
           accumulate_COL-size_image(i,2)+1:accumulate_COL) = mat2gray(gaussian{i,j});
    end
end
figure;
imshow(gauss_pyramid,[]);

%% display keypoints
hold on;
theta = 0:pi/100:2*pi;
d = 4;
[M,N,~] = size(gaussian{1,1});
for i=1:size(keypoints,2)
    octave = keypoints(i).octave-1;
    layer = keypoints(i).layer-1;
    scale = keypoints(i).size/(2^octave);
    
    x = keypoints(i).x/(2^octave) + layer*N/(2^(octave));
    yy=0;
    for j=1:octave
        yy = yy+M/(2^(j-1));
    end
    y = keypoints(i).y/(2^octave) + yy;
    plot(x,y,'r+');
    
% %     orient = key_point_array_1(i).angle;
%     hist_width = 3*scale;
%     r = round(hist_width*(d+1)*1.414/2);
%     dx=r*cos(theta)+x; dy=r*sin(theta)+y;
%     plot(dx,dy,'-')
end