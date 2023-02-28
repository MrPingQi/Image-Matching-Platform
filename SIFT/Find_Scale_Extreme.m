%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% Author: Gao Chenzhong
% Contact: gao-pingqi@qq.com
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

function keypoints = Find_Scale_Extreme....
    (DoG_pyramid,sigma,contrast_thr,edge_thr,gradient,angle)

keypoints = struct('x',{},'y',{},'xt',{},'yt',{},'octave',{},'layer',{},...
                   'oL',{},'size',{},'angle',{},'gradient',{});
keypoint = struct('x',0,'y',0,'xt',0,'yt',0,'octave',0,'layer',0,...
                  'oL',0,'size',0,'angle',0,'gradient',0);
num = 0;
border = 2; % Boundary constant
NBO = 36; % bin nums
o_thr = 0.8; % Histogram peak ratio

[nOctaves,nLayers] = size(DoG_pyramid); nLayers = nLayers-2;
threshold = contrast_thr/nLayers;

for octave = 1:nOctaves
    for layer = 2:nLayers+1
        curr_L = DoG_pyramid{octave,layer};
        prev_L = DoG_pyramid{octave,layer-1};
        next_L = DoG_pyramid{octave,layer+1};
        [M,N] = size(curr_L);
        
        for y = border:M-border % row
            for x = border:N-border % col
                p = curr_L(y,x);
if(abs(p)>threshold && ...
   ((p>0 && p>curr_L(y  ,x-1) && p>curr_L(y  ,x+1)...
         && p>curr_L(y-1,x-1) && p>curr_L(y-1,x) && p>curr_L(y-1,x+1)...
         && p>curr_L(y+1,x-1) && p>curr_L(y+1,x) && p>curr_L(y+1,x+1)...
         && p>prev_L(y  ,x-1) && p>prev_L(y  ,x) && p>prev_L(y,x+1)...
         && p>prev_L(y-1,x-1) && p>prev_L(y-1,x) && p>prev_L(y-1,x+1)...
         && p>prev_L(y+1,x-1) && p>prev_L(y+1,x) && p>prev_L(y+1,x+1)...
         && p>next_L(y  ,x-1) && p>next_L(y  ,x) && p>next_L(y  ,x+1)...
         && p>next_L(y-1,x-1) && p>next_L(y-1,x) && p>next_L(y-1,x+1)...
         && p>next_L(y+1,x-1) && p>next_L(y+1,x) && p>next_L(y+1,x+1)) || ...
    (p<0 && p<curr_L(y  ,x-1) && p<curr_L(y  ,x+1)...
         && p<curr_L(y-1,x-1) && p<curr_L(y-1,x) && p<curr_L(y-1,x+1)...
         && p<curr_L(y+1,x-1) && p<curr_L(y+1,x) && p<curr_L(y+1,x+1)...
         && p<prev_L(y-1,x-1) && p<prev_L(y-1,x) && p<prev_L(y-1,x+1)...
         && p<prev_L(y  ,x-1) && p<prev_L(y  ,x) && p<prev_L(y  ,x+1)...
         && p<prev_L(y+1,x-1) && p<prev_L(y+1,x) && p<prev_L(y+1,x+1)...
         && p<next_L(y-1,x-1) && p<next_L(y-1,x) && p<next_L(y-1,x+1)...
         && p<next_L(y  ,x-1) && p<next_L(y  ,x) && p<next_L(y  ,x+1)...
         && p<next_L(y+1,x-1) && p<next_L(y+1,x) && p<next_L(y+1,x+1))))
    
	keypoint.xt = x;
    keypoint.yt = y;
    keypoint.octave = octave;
    keypoint.layer = layer;
    
    % Fine judge local extreme point, adjust the location in x,y, and layer
    [keypoint,is_local_extreme] = Adjust_Local_Extreme...
        (DoG_pyramid,keypoint,nLayers,contrast_thr,edge_thr);
    if ~is_local_extreme
       continue;
    end
    keypoint.size = sigma*(2^((keypoint.layer-1+keypoint.oL)/nLayers));
    
    % Main orientation
    [o_hist,max_value] = calc_Orientation_Hist...
    	(round(keypoint.xt),...
         round(keypoint.yt),...
         keypoint.size,...
         gradient{octave,keypoint.layer-1},...
         angle{octave,keypoint.layer-1},...
         NBO);

    mag_thr = max_value*o_thr;
    for o = 1:NBO
        if(o==1)
            aa = o_hist(NBO);
        else
            aa = o_hist(o-1);
        end
        oo = o_hist(o);
        if(o==NBO)
            bb = o_hist(1);
        else
            bb = o_hist(o+1);
        end

        if(oo>aa && oo>bb && oo>mag_thr)
            bin = o-1+0.5*(aa-bb)/(aa+bb-2*oo);
            if(bin<0)
               bin = NBO+bin;
            elseif(bin>=NBO)
               bin = bin-NBO;
            end
            keypoint.angle = bin*2*pi/NBO; % [0,2pi)
            keypoint.gradient = oo;
            keypoint.x = keypoint.xt * (2^(octave-1));
            keypoint.y = keypoint.yt * (2^(octave-1));
            num = num+1;
            keypoints(num) = keypoint;
        end
    end
end
            end
        end
    end
end