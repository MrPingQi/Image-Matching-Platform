%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% Author: Gao Chenzhong
% Contact: gao-pingqi@qq.com
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

function Display_Pyramid(gaussian,DoG,gradient,angle,...
	nOctaves,nLayers,str)
size_image = zeros(nOctaves,2);
for i = 1:nOctaves
    size_image(i,1:2) = size(gaussian{i,1});
end

%% display Gaussian Pyramid
ROW_size = sum(size_image);
ROW_size = ROW_size(1);
COL_size = size_image(1,1)*(nLayers+3);
image_gaussian_pyramid = zeros(ROW_size,COL_size);
accumulate_ROW = 0;
for i = 1:nOctaves
    accumulate_ROW = accumulate_ROW+size_image(i,1);
    accumulate_COL = 0;
    for j = 1:nLayers+3
        accumulate_COL = accumulate_COL+size_image(i,2);
        image_gaussian_pyramid(accumulate_ROW-size_image(i,1)+1:accumulate_ROW,...
           accumulate_COL-size_image(i,2)+1:accumulate_COL) = mat2gray(gaussian{i,j});
    end
end
str1 = ['.\save_image\',str,' Gaussian Pyramid','.jpg'];
imwrite(image_gaussian_pyramid,str1,'jpg');
figure;
imshow(image_gaussian_pyramid,[]);
title([str,'--Gaussian Pyramid',]);

%% display DOG Pyramid
ROW_size = sum(size_image);
ROW_size = ROW_size(1);
COL_size = size_image(1,1)*(nLayers+2);
image_dog_pyramid = zeros(ROW_size,COL_size);
accumulate_ROW = 0;
for i = 1:nOctaves
    accumulate_ROW = accumulate_ROW+size_image(i,1);
    accumulate_COL = 0;
    for j = 1:nLayers+2
        accumulate_COL = accumulate_COL+size_image(i,2);
        image_dog_pyramid(accumulate_ROW-size_image(i,1)+1:accumulate_ROW,...
           accumulate_COL-size_image(i,2)+1:accumulate_COL) = mat2gray(DoG{i,j});
    end
end
str1 = ['.\save_image\',str,' DoG Pyramid','.jpg'];
imwrite(image_dog_pyramid,str1,'jpg');
figure;%
imshow(image_dog_pyramid,[]);
title([str,'--DoG Pyramid',]);

%% display gradient image
ROW_size = sum(size_image);
ROW_size = ROW_size(1);
COL_size = size_image(1,1)*(nLayers);
image_gaussian_gradient = zeros(ROW_size,COL_size);
accumulate_ROW = 0;
for i = 1:nOctaves
    accumulate_ROW = accumulate_ROW+size_image(i,1);
    accumulate_COL = 0;
    for j = 1:nLayers
        accumulate_COL = accumulate_COL+size_image(i,2);
        image_gaussian_gradient(accumulate_ROW-size_image(i,1)+1:accumulate_ROW,...
           accumulate_COL-size_image(i,2)+1:accumulate_COL) = mat2gray(gradient{i,j});
    end
end
str1 = ['.\save_image\',str,' gradient','.jpg'];
imwrite(image_gaussian_gradient,str1,'jpg');
figure;
imshow(image_gaussian_gradient,[]);
title([str,'--Gradient',]);

%% display orientation image
ROW_size = sum(size_image);
ROW_size = ROW_size(1);
COL_size = size_image(1,1)*(nLayers);
image_gaussian_angle = zeros(ROW_size,COL_size);
accumulate_ROW = 0;
for i = 1:nOctaves
    accumulate_ROW = accumulate_ROW+size_image(i,1);
    accumulate_COL = 0;
    for j = 1:nLayers
        accumulate_COL = accumulate_COL+size_image(i,2);
        image_gaussian_angle(accumulate_ROW-size_image(i,1)+1:accumulate_ROW,...
           accumulate_COL-size_image(i,2)+1:accumulate_COL) = mat2gray(angle{i,j});
    end
end
str1 = ['.\save_image\',str,' orientation','.jpg'];
imwrite(image_gaussian_angle,str1,'jpg');
figure;
imshow(image_gaussian_angle,[]);
title([str,'--Orientation']);