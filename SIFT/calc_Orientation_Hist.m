%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% Author: Gao Chenzhong
% Contact: gao-pingqi@qq.com
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

function [hist,max_value] = calc_Orientation_Hist(x,y,scale,gradient,angle,NBO)

radius = round(6*scale);
sigma = 1.5*scale;

x1 = max(1,x-radius); x2 = min(x+radius,size(gradient,2));
y1 = max(1,y-radius); y2 = min(y+radius,size(gradient,1));

p_gradient = gradient(y1:y2,x1:x2);
p_angle = angle(y1:y2,x1:x2);

X = -(x-x1):(x2-x);
Y = -(y-y1):(y2-y);
[XX,YY] = meshgrid(X,Y);

% W = p_gradient; % 无高斯权重
weight = 1/(sqrt(2*pi)*sigma)*exp(-(XX.^2+YY.^2)/(2*sigma^2));
W = p_gradient.*weight; % 有高斯权重

bin = mod(round(p_angle*NBO/pi/2),NBO)+1;

temp_hist = zeros(1,NBO);
[row,col] = size(p_angle);
for i = 1:row
    for j = 1:col
        temp_hist(bin(i,j)) = temp_hist(bin(i,j))+W(i,j);
    end
end

%% 让分界没那么明显
    % 思路：
    % temp_hist(-1) = temp_hist(35)
    % temp_hist(0) = temp_hist(36)
    
% hist = zeros(1,NBO);
% hist(1) = (temp_hist(35)+temp_hist(3))/16+...
%     4*(temp_hist(36)+temp_hist(2))/16+temp_hist(1)*6/16;
% hist(2) = (temp_hist(36)+temp_hist(4))/16+...
%     4*(temp_hist(1)+temp_hist(3))/16+temp_hist(2)*6/16;
% hist(3:NBO-2) = (temp_hist(1:NBO-4)+temp_hist(5:NBO))/16+...
%     4*(temp_hist(2:NBO-3)+temp_hist(4:NBO-1))/16+temp_hist(3:NBO-2)*6/16;
% hist(NBO-1) = (temp_hist(NBO-3)+temp_hist(1))/16+...
%     4*(temp_hist(NBO-2)+temp_hist(NBO))/16+temp_hist(NBO-1)*6/16;
% hist(NBO) = (temp_hist(NBO-2)+temp_hist(2))/16+...
%     4*(temp_hist(NBO-1)+temp_hist(1))/16+temp_hist(NBO)*6/16;

h = [1/16, 4/16, 6/16, 4/16, 1/16];
hist = imfilter(temp_hist,h,'circular');

%% acquire main orientation
max_value = max(hist);