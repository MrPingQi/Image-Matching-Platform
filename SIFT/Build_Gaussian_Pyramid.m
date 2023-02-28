%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% Author: Gao Chenzhong
% Contact: gao-pingqi@qq.com
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

function [gaussian,gradient,angle] = ...
    Build_Gaussian_Pyramid(I,nOctaves,nLayers,sigma)
%% Pyramid basic image
I = Create_Initial_Image(I,sigma);

%% Fast computation
sig = zeros(1,nLayers+3);
sig(1) = sigma;
k = 2^(1.0/nLayers);
for i = 2:1:(nLayers+3)
    sig_prev = k^(i-2)*sigma;
    sig_curr = k*sig_prev;
    sig(i) = sqrt(sig_curr^2-sig_prev^2);
end

%% Build pyramid
gaussian = cell(nOctaves,nLayers+3);
gradient = cell(nOctaves,nLayers+3);
angle = cell(nOctaves,nLayers+3);
h = [-1,0,1;-2,0,2;-1,0,1];

for o = 1:nOctaves
    for i = 1:(nLayers+3)
        if(o==1 && i==1)
            gaussian{1,1}(:,:) = I;
        elseif(i==1)
            temp = gaussian{(o-1),nLayers+1}(:,:);
            gaussian{o,1}(:,:) = imresize(temp,1/2,'bilinear');
        else
            window_gaussian = 2*round(2*sig(i))+1;
            w = fspecial('gaussian',[window_gaussian,window_gaussian],sig(i));
            temp = gaussian{o,i-1}(:,:);
            gaussian{o,i} = imfilter(temp,w,'replicate');
            
            if(i>=2 && i<=nLayers+1)
                Gx = imfilter(gaussian{o,i}(:,:),h,'replicate');
                Gy = imfilter(gaussian{o,i}(:,:),h','replicate');
                gradient{o,i-1}(:,:) = sqrt(Gx.^2+ Gy.^2); 
                
                angle_t = atan2(Gy,Gx);
                angle_t(angle_t<0) = angle_t(angle_t<0)+2*pi;
                angle{o,i-1}(:,:) = angle_t;
            end
        end
    end
end


function image = Create_Initial_Image(I,sigma)
init_sigma = 0.5;  % 认为最原始的图像尺度为σ=0.5
window_gauss = 5;

sig_diff = sqrt(max(sigma*sigma-init_sigma^2,0.01));
w = fspecial('gaussian',[window_gauss,window_gauss],sig_diff);
image = imfilter(I,w,'replicate');