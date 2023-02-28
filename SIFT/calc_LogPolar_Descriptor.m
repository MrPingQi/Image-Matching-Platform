%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% Author: Gao Chenzhong
% Contact: gao-pingqi@qq.com
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

function descriptor = calc_LogPolar_Descriptor(gradient,angle,x,y,scale,orient,NBS,NBO)

[M,N] = size(gradient);
radius = round(min(12*scale,min(M,N)/3));

x1 = max(1,x-radius); x2 = min(x+radius,N);
y1 = max(1,y-radius); y2 = min(y+radius,M);
X = -(x-x1):(x2-x);
Y = -(y-y1):(y2-y);
[XX,YY] = meshgrid(X,Y);

cos_p = cos(-orient);
sin_p = sin(-orient);
Xr = XX*cos_p-YY*sin_p;
Yr = XX*sin_p+YY*cos_p;

Rho = log2(sqrt(Xr.^2+Yr.^2));
r1 = log2(radius*0.73*0.25);
r2 = log2(radius*0.73);
Rho(Rho<=r1) = 1;
Rho(Rho>r1 & Rho<=r2) = 2;
Rho(Rho>r2) = 3;

Theta = atan2(Yr,Xr);
Theta = round(Theta*NBS/pi/2);
Theta(Theta<=0) = Theta(Theta<=0)+NBS;
Theta(Theta>NBS) = Theta(Theta>NBS)-NBS;

temp_gradient = gradient(y1:y2,x1:x2);
temp_angle = angle(y1:y2,x1:x2);
temp_angle = round((temp_angle-orient)*NBO/pi/2);
temp_angle = mod(temp_angle,NBO);
temp_angle(temp_angle==0) = NBO;

hist_middle = zeros(NBO,1);
hist_outer = zeros(2,NBS,NBO);
[row,col] = size(Theta);
for i = 1:row
    for j = 1:col
        if((Y(i)^2+X(j)^2)<=radius^2)
            mag = temp_gradient(i,j);
            angle_bin = temp_angle(i,j);
            Rho_bin = Rho(i,j)-1;
            if(Rho_bin==0)
                hist_middle(angle_bin) = hist_middle(angle_bin) + mag;
            else
                Theta_bin = Theta(i,j);
                hist_outer(Rho_bin,Theta_bin,angle_bin) = ...
                    hist_outer(Rho_bin,Theta_bin,angle_bin) + mag;
            end
        end
    end
end
descriptor = [hist_middle;hist_outer(:)]';

%% Feature vector normalization
descriptor = descriptor/sqrt(descriptor*descriptor');
descriptor(descriptor>0.2) = 0.2;
descriptor = descriptor/sqrt(descriptor*descriptor');