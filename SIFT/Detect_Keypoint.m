%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% Author: Gao Chenzhong
% Contact: gao-pingqi@qq.com
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

function keypoints = Detect_Keypoint....
    (DoG_pyramid,nOctaves,nLayers,...
     sigma,contrast_thr,edge_thr,gradient,angle)

keypoints = struct('x',{},'y',{},'octave',{},'layer',{},'oL',{},'size',{},'angle',{},'gradient',{});
num = 0;

border = 2; % Boundary constant
threshold = contrast_thr/nLayers;
NBO = 36; % bin nums
o_thr = 0.8; % Histogram peak ratio

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
    
    % Fine judge local extreme point, adjust the location in x,y, and layer
    [keypoint,is_local_extreme] = Adjust_Local_Extreme...
        (DoG_pyramid,octave,layer,x,y,nLayers,sigma,...
    	 contrast_thr,edge_thr);
    if ~is_local_extreme
       continue;
    end
	py = round(keypoint.y/(2^(octave-1)));
	px = round(keypoint.x/(2^(octave-1)));
	scale = keypoint.size/(2^(octave-1));
    
    %The direction histogram of points
    [o_hist,max_value] = calc_Orientation_Hist...
    	(px,py,scale,...
         gradient{octave,keypoint.layer-1},...
         angle{octave,keypoint.layer-1},...
         NBO);

    mag_thr = max_value * o_thr;
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
            num = num+1;
            keypoints(num) = keypoint;
        end
    end
end
            end
        end
    end
end