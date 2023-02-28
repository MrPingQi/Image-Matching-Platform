%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% Author: Gao Chenzhong
% Contact: gao-pingqi@qq.com
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

function descriptors = Generate_Descriptor...
    (gradient,angle,keypoints,is_sift_or_gloh)

SIFT_DESCR_WIDTH = 4;
SIFT_HIST_BINS = 8;
LOG_POLAR_DESCR_WIDTH = 8;
LOG_POLAR_HIST_BINS = 8;

N = size(keypoints,2);
kps = zeros(N,6);
if(strcmp(is_sift_or_gloh,'SIFT'))
    NBS = SIFT_DESCR_WIDTH;
    NBO = SIFT_HIST_BINS;
    des = zeros(N,NBS*NBS*NBO);
    for i = 1:N
        kpt = keypoints(i);
        octave = kpt.octave;
        layer = kpt.layer;
        x = kpt.xt;
        y = kpt.yt;
        scale = kpt.size;
        orient = kpt.angle;

        temp_gradient = gradient{octave,layer-1};
        temp_angle = angle{octave,layer-1};

        des(i,:) = calc_SIFT_Descriptor(temp_gradient,temp_angle,...
        	round(x),round(y),scale,orient,NBS,NBO);
        kps(i,1) = kpt.x;
        kps(i,2) = kpt.y;
        kps(i,3) = kpt.octave;
        kps(i,4) = kpt.layer;
        kps(i,5) = kpt.size;
        kps(i,6) = kpt.angle;
    end
    
elseif(strcmp(is_sift_or_gloh,'LogPolar'))
    NBS = LOG_POLAR_DESCR_WIDTH;
    NBO = LOG_POLAR_HIST_BINS;
    des = zeros(N,(2*NBS+1)*NBO);
    for i = 1:N
        kpt = keypoints(i);
        octave = kpt.octave;
        layer = kpt.layer;
        x = kpt.xt;
        y = kpt.yt;
        scale = kpt.size;
        orient = kpt.angle;

        temp_gradient = gradient{octave,layer-1};
        temp_angle = angle{octave,layer-1};

        des(i,:) = calc_LogPolar_Descriptor(temp_gradient,temp_angle,...
            round(x),round(y),scale,orient,NBS,NBO);
        kps(i,1) = kpt.x;
        kps(i,2) = kpt.y;
        kps(i,3) = kpt.octave;
        kps(i,4) = kpt.layer;
        kps(i,5) = kpt.size;
        kps(i,6) = kpt.angle;
    end
end

descriptors = struct('kps', kps, 'des', des);