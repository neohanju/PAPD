%==========================================================================
% evaluate other methods (DPM, channel filter)
% 
% 
%==========================================================================


main_init;
DETECTOR_NAME = 'ACF_INRIA';
evalMinOverlap = 0.5;

% load ground truth
load(fullfile(GROUNDTRUTH_DIR, GROUNDTRUTH_NAME));
% load detections
load(fullfile(RESULT_DIR, sprintf('result_%s_%s.mat', DATASET_NAME, ...
    DETECTOR_NAME)));
cellBBoxs = cellBBoxsACF;


t_main = tic;
tic;
%===========================
% Gathering Annotations
%===========================
% initialize
detBBoxs     = [];
detBBoxIds   = [];
detConfs     = [];
gtBBoxs      = [];
gtIds        = [];
numPositives = 0;
cellIdx      = 0;
for frameIdx = START_FRAME_IDX : END_FRAME_IDX
    if toc > 1
        fprintf('Read Annotation: %d/%d\n', frameIdx, END_FRAME_IDX);
        drawnow;
        tic;
    end
    cellIdx = cellIdx + 1;
    %================================
    % load detections and GTs
    %================================
    bboxs = cellBBoxs{cellIdx};
    % sorting detections    
    conf = bboxs(:,end)';
    [sortConf, sortI] = sort(conf, 'descend');    
    % concatenate annotations
    detBBoxs = [detBBoxs; bboxs(sortI, 1:4)];        % [x1, y1, w, h]
    detConfs = [detConfs; sortConf'];

    % gts
    curGTs = cellGroundTruths{cellIdx};  % frame starts from 0 (CAUTION!)
    curGTs(:,1:2) = [curGTs(:,1) - curGTs(:,3)/2, curGTs(:,2) - curGTs(:,4)/2]; % [centerx, centery, width, height]
    gtBBoxs = [gtBBoxs; curGTs];
    
    % attach frame indices
    detBBoxIds = [detBBoxIds; frameIdx * ones(length(sortI),1)];
    gtIds   = [gtIds; frameIdx * ones(size(curGTs,1),1)];
    numPositives = numPositives + size(curGTs,1);
end
fprintf('==========================================\n');


%==============================
% RUN EVALUATION
%==============================
TruePositive    = zeros(length(detConfs), 1);
FalsePositive   = zeros(length(detConfs), 1);
% checking variable whether gt is already detected
gtDetected      = zeros(numPositives, 1);
% sorting detections and frame indices
[~, detSortI]   = sort(-detConfs);
detBBoxs        = detBBoxs(detSortI, :);
detBBoxIds      = detBBoxIds(detSortI);

for detIdx = 1 : length(detConfs)
    if toc > 1
        fprintf('evaluation: %d/%d\n', detIdx, length(detConfs));
        drawnow;
        tic;
    end    
    % get current frame index
    frameIdx = detBBoxIds(detIdx);
    % get corresponding ground truths
    corrGts = find(gtIds==frameIdx);
    gtBBs   = gtBBoxs(corrGts, :);
    % current bbox
    bb      = detBBoxs(detIdx, :) / 2.0;
    % convert [x1 y1 x2 y2];
    bb      = [bb(1), bb(2), bb(1)+bb(3), bb(2)+bb(4)];    
    ovMax   = -inf;
    for gtIdx = 1 : size(gtBBs, 1)
        curGTBB = gtBBs(gtIdx, :);
        % convert [x1 y1 x2 y2]
        gtbb = [curGTBB(1), curGTBB(2), ...
            curGTBB(1)+curGTBB(3), curGTBB(2)+curGTBB(4)];        
        % check overlap is larger than evalMinOverlap
        bi = [max(bb(1),gtbb(1)); max(bb(2),gtbb(2));...
            min(bb(3),gtbb(3)); min(bb(4),gtbb(4))];
        iw = bi(3)-bi(1)+1;
        ih = bi(4)-bi(2)+1;
        if iw>0 && ih>0
            % compute overlap
            ua = (bb(3)-bb(1)+1)*(bb(4)-bb(2)+1)+...
                (gtbb(3)-gtbb(1)+1) *(gtbb(4)-gtbb(2)+1)-...
                iw*ih;
            overlap = iw*ih/ua;
            if overlap > ovMax
                ovMax    = overlap;
                gtIdxMax = corrGts(gtIdx);
            end
        end
    end
    
    % assign detection as true positive / false positive
    if ovMax > evalMinOverlap
        if ~gtDetected(gtIdxMax)
            % true positive
            gtDetected(gtIdxMax) = true;
            TruePositive(detIdx) = 1;
        else
            % false positive (multiple detection)
            FalsePositive(detIdx) = 1;
        end
    else
        % false positive
        FalsePositive(detIdx) = 1;
    end
end
t_eval = toc(t_main);
fprintf('==========================================\n');
fprintf(' DONE! Evaluation time: %f \n', t_eval);
fprintf('==========================================\n');


%==============================
% compute precision/recall
%==============================
fprintf(' COMPUTE PRECISION / RECALL \n')
FP   = cumsum(FalsePositive);
TP   = cumsum(TruePositive);
rec  = TP / numPositives;
prec = TP ./ (FP+TP);
AP   = 0;
for t=0:0.1:1
    p=max(prec(rec>=t));
    if isempty(p)
        p=0;
    end
    AP=AP+p/11;
end

figure(2000); hold on;
hold on;
plot(rec,prec,'c-');
grid;
xlabel 'recall'
ylabel 'precision'
title(sprintf('AP = %.3f',AP));

%==============================
% compute FPPI/missrate
%==============================
nFrames = END_FRAME_IDX - START_FRAME_IDX + 1;
FPPI=FP/nFrames; 
MISSRATE=TP/numPositives; 
xs1=[-inf; FPPI]; 
ys1=[0; MISSRATE];
ref = 10.^(-2:.25:1);
for i=1:length(ref);
    j=find(xs1<=ref(i));
    ref(i)=ys1(j(end));
end
figure(2001); hold on;
plot(FPPI, 1-MISSRATE, 'c-');
miss=exp(mean(log(max(1e-10,1-ref))));
title(sprintf('log-average miss rate = %.2f%%',miss*100));

