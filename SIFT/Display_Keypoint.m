%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% Author: Gao Chenzhong
% Contact: gao-pingqi@qq.com
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

function Display_Keypoint(pyramid,keypoints)
%% display Image Pyramid
Display_Pyramid(pyramid,'Keypoint detected',0);

%% display keypoints
hold on;
theta = 0:pi/100:2*pi;
d = 4;
[M,N,~] = size(pyramid{1,1});
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
    
%     orient = key_point_array_1(i).angle;
    hist_width = 3*scale;
    r = round(hist_width*(d+1)*1.414/2);
    dx=r*cos(theta)+x; dy=r*sin(theta)+y;
    plot(dx,dy,'-')
end