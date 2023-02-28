%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% Author: Gao Chenzhong
% Contact: gao-pingqi@qq.com
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

function [I_s,I] = Preproscessing(img,resample,bands)
img = double(img);

%% Data fitting and normalization
if size(img,3)==1
    I_s = img;
    I = I_s;
elseif size(img,3)==3
    if isempty(bands) || size(bands,2)~=1
        I_s = img;
        I = ((img(:,:,1).^2.2+(1.5*img(:,:,2)).^2.2+(0.6*img(:,:,3)).^2.2)/(1+1.5^2.2+1.6^2.2)).^(1/2.2);
    else
        I_s = img(:,:,bands);
        I = I_s;
    end
else
    if isempty(bands) || (size(bands,2)~=3 && size(bands,2)~=1)
        I_s = sum(img,3);
        I = I_s;
    else
        I_s = img(:,:,bands);
        I = sum(img,3);
    end
end
I_s = Visual(double(I_s));

if isempty(resample)
    I = double(I);
elseif size(resample,2)==1
    I = double(imresize(I,resample,'bicubic'));
elseif size(resample,2)==2
    I = double(imresize(I,[round(size(I,1)*resample(1)),...
                               round(size(I,2)*resample(2))],'bicubic'));
else
    error('Parameters error');
end
I = Visual(I);

%% Gaussian denoising
sigma=0.5;
w=2*round(3*sigma)+1;
w=fspecial('gaussian',[w,w],sigma);
I=imfilter(I,w,'replicate');