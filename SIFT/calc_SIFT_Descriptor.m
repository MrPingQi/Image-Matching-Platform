%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% Author: Gao Chenzhong
% Contact: gao-pingqi@qq.com
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

function descriptor = calc_SIFT_Descriptor(gradient,angle,x,y,scale,orient,NBS,NBO)

ss = 3*scale; % Ð¡·½¸ñ³ß´ç
radius = round(ss*(NBS+1)*1.414/2);
[M,N] = size(gradient);
radius = min(radius,round(sqrt(M*M+N*N)));

x1 = max(1,x-radius); x2 = min(x+radius,N);
y1 = max(1,y-radius); y2 = min(y+radius,M);
X = -(x-x1):(x2-x);
Y = -(y-y1):(y2-y);
[XX,YY] = meshgrid(X,Y);

cos_p = cos(-orient);
sin_p = sin(-orient);
Xr = XX*cos_p - YY*sin_p;
Yr = XX*sin_p + YY*cos_p;
Ybin = Yr/ss + NBS/2 + 0.5;
Xbin = Xr/ss + NBS/2 + 0.5;

temp_gradient = gradient(y1:y2,x1:x2);
temp_angle = mod(angle(y1:y2,x1:x2)-orient,2*pi);

descriptor = zeros(NBS,NBS,NBO);
for i = 1:length(Y)
    for j = 1:length(X)
        ybin = Ybin(i,j); xbin = Xbin(i,j);
        if(ybin<=0 || ybin>=NBS+1 || xbin<=0 || xbin>=NBS+1)
            continue;
        end
        mag = temp_gradient(i,j);
        obin = temp_angle(i,j)*NBO/pi/2; % [0,NBO-1)
        
        y0 = floor(ybin); ybin = ybin-y0;
        x0 = floor(xbin); xbin = xbin-x0;
        o0 = floor(obin); obin = obin-o0;
        
        for dybin = 0:1
            for dxbin = 0:1
                for dobin = 0:1
                    ybin_t = y0 + dybin;
                    xbin_t = x0 + dxbin;
                    if(ybin_t<1 || ybin_t>NBS || xbin_t<1 || xbin_t>NBS)
                        continue
                    end
                    obin_t = mod(o0 + dobin,NBO)+1; % [1,NBO]
%                     weight = mag * abs(1 - ybin - dybin)...
%                                  * abs(1 - xbin - dxbin)...
%                                  * abs(1 - obin - dobin);
                    weight = mag * abs((1-ybin-dybin)*(1-xbin-dxbin)*(1-obin-dobin));
                    descriptor(ybin_t,xbin_t,obin_t) = ...
                        descriptor(ybin_t,xbin_t,obin_t) + weight;
                end
            end
        end
    end
end
descriptor = descriptor(:)';

%% Feature vector normalization
descriptor = descriptor/sqrt(descriptor*descriptor');
descriptor(descriptor>=0.2) = 0.2;
descriptor = descriptor/sqrt(descriptor*descriptor');