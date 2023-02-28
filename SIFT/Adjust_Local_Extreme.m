%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% Author: Gao Chenzhong
% Contact: gao-pingqi@qq.com
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

function [keypoint,is_local_extreme] = Adjust_Local_Extreme...
    (DoG_pyramid,keypoint,nLayers,contrast_thr,edge_thr)

x = keypoint.xt;
y = keypoint.yt;
octave = keypoint.octave;
layer = keypoint.layer;

border = 5;
iteration = 5; % Maximum number of iterations
is_local_extreme = false; % Extreme point judgement initialization
for k = 1:iteration
    curr_L = DoG_pyramid{octave,layer};
    prev_L = DoG_pyramid{octave,layer-1};
    next_L = DoG_pyramid{octave,layer+1};

    % First-order partial derivative
    dx = (curr_L(y,x+1)-curr_L(y,x-1))/2;
    dy = (curr_L(y+1,x)-curr_L(y-1,x))/2;
    dz = (next_L(y,x)-prev_L(y,x))/2;
     
    % Second-order partial derivative
    v2 = curr_L(y,x)*2;
    dxx = (curr_L(y,x+1)+curr_L(y,x-1)-v2);
    dyy = (curr_L(y+1,x)+curr_L(y-1,x)-v2);
    dzz = (next_L(y,x)+prev_L(y,x)-v2);

    % Second-order mixed partial derivative
    dxy = (curr_L(y-1,x-1)+curr_L(y+1,x+1)-curr_L(y-1,x+1)-curr_L(y+1,x-1))/4;
    dxz = (next_L(y,x+1)-next_L(y,x-1)-prev_L(y,x+1)+prev_L(y,x-1))/4;
    dyz = (next_L(y+1,x)-next_L(y-1,x)-prev_L(y+1,x)+prev_L(y-1,x))/4;
    
    % Hessian matrix
    H = [dxx,dxy,dxz;
         dxy,dyy,dyz;
         dxz,dyz,dzz];
     
    % formula: H * dX = -[dx,dy,dz]'
    dX = H\[-dx,-dy,-dz]';
    ox = dX(1); % Offset of the column direction, X direction
    oy = dX(2); % Offset of the row direction, Y direction
    oL = dX(3); % Offset of scale, Z (layer) direction
    
    if(abs(ox)<0.5 && abs(oy)<0.5 && abs(oL)<0.5)
        is_local_extreme = true; % Is the extreme point, exit cycle
        break;
    end
    
    % If the offset is too much, the extreme point is not stable, delete
    [M,N] = size(curr_L);
    msize = max(M,N);
    if(abs(ox)>msize/3 || abs(oy)>msize/3 || abs(oL)>msize/3 )
        is_local_extreme = false; % Not extreme point, exit cycle
        break;
    end
    
    % According to the offset from the above, refine the location of the interpolation center
    x = x+round(ox);
    y = y+round(oy);
    layer = layer+round(oL);
        
    % If the coordinate range is exceeded, the extreme point is not a feature point
    if(layer<2 || layer>nLayers+1 || ...
       x<border || x>= N-border || ...
       y<border || y>= M-border)
        is_local_extreme = false; % Not extreme point
        break;
    end
end

% If the above is the local extreme point, and then continue to judge
if(is_local_extreme == true)
    curr_L = DoG_pyramid{octave,layer};
    prev_L = DoG_pyramid{octave,layer-1};
    next_L = DoG_pyramid{octave,layer+1};
    
    % first-order partial derivative
    dx = (curr_L(y,x+1)-curr_L(y,x-1))/2;
    dy = (curr_L(y+1,x)-curr_L(y-1,x))/2;
    dz = (next_L(y,x)-prev_L(y,x))/2;
    
    contr = [dx,dy,dz]*[ox,oy,oL]'/2 + curr_L(y,x);
    if(abs(contr)<(contrast_thr/nLayers))
        is_local_extreme = false;
    end
end

%% Edge response
if(is_local_extreme == true)
    % Second-order partial derivative
    v2 = curr_L(y,x)*2;
    dxx = (curr_L(y,x+1)+curr_L(y,x-1)-v2);
    dyy = (curr_L(y+1,x)+curr_L(y-1,x)-v2);
    % Second-order mixed partial derivative
    dxy = (curr_L(y-1,x-1)+curr_L(y+1,x+1)-curr_L(y-1,x+1)-curr_L(y+1,x-1))/4;
    
    tr = dxx+dyy; % Trace
    det = dxx*dyy-dxy*dxy; % Determinant
    if(det<=0 || (tr*tr*edge_thr >= det*(edge_thr+1)^2))
        is_local_extreme = false;
    end
end
  
if(is_local_extreme == true)
    keypoint.xt = x+ox;
    keypoint.yt = y+oy;
    keypoint.layer = layer;
    keypoint.oL = oL;
end