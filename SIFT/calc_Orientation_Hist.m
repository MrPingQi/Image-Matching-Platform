%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% Author: Gao Chenzhong
% Contact: gao-pingqi@qq.com
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

function [hist,max_value] = calc_Orientation_Hist(x,y,scale,gradient,angle,n)

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

bin = mod(round(p_angle*n/pi/2),n);

temp_hist = zeros(1,n);
[row,col] = size(p_angle);
for i = 1:row
    for j = 1:col
        temp_hist(bin(i,j)+1) = temp_hist(bin(i,j)+1)+W(i,j);
    end
end

%% 让分界没那么明显（值得学习）
    % 思路：
    % temp_hist(-1) = temp_hist(35)
    % temp_hist(0) = temp_hist(36)
    
% hist = zeros(1,n);
% hist(1) = (temp_hist(35)+temp_hist(3))/16+...
%     4*(temp_hist(36)+temp_hist(2))/16+temp_hist(1)*6/16;
% hist(2) = (temp_hist(36)+temp_hist(4))/16+...
%     4*(temp_hist(1)+temp_hist(3))/16+temp_hist(2)*6/16;
% % for j = 3:1:n-2
% %     hist(j) = (temp_hist(j-2)+temp_hist(j+2))/16+...
% %     4*(temp_hist(j-1)+temp_hist(j+1))/16+temp_hist(j)*6/16;
% % end
% hist(3:n-2) = (temp_hist(1:n-4)+temp_hist(5:n))/16+...
%     4*(temp_hist(2:n-3)+temp_hist(4:n-1))/16+temp_hist(3:n-2)*6/16;
% hist(n-1) = (temp_hist(n-3)+temp_hist(1))/16+...
%     4*(temp_hist(n-2)+temp_hist(n))/16+temp_hist(n-1)*6/16;
% hist(n) = (temp_hist(n-2)+temp_hist(2))/16+...
%     4*(temp_hist(n-1)+temp_hist(1))/16+temp_hist(n)*6/16;

% temp_hist = [temp_hist(n-1:n), temp_hist, temp_hist(1:2)];
h = [1/16, 4/16, 6/16, 4/16, 1/16];
hist = imfilter(temp_hist,h,'circular');

%% acquire main orientation
max_value = max(hist);