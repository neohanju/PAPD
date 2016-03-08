
addpath(genpath('D:\work\PAPD'));

main_init;
load(fullfile(GROUNDTRUTH_DIR, GROUNDTRUTH_NAME));


%=====================
% EVALUATE DPM
%=====================
stInputSetting.datasetpath        = DATASET_PATH;
stInputSetting.startFrameIdx      = START_FRAME_IDX;
stInputSetting.endFrameIdx        = END_FRAME_IDX;
stInputSetting.partCandidateDir   = PARTCANDIDATE_DIR;
stInputSetting.partCandidateForm  = PARTCANDIDATE_FORM;
stInputSetting.partCandidateScale = PARTCANDIDATE_SCALE;
EvaluateDPM(stInputSetting, cellGroundTruths, EVAL_MIN_OVERLAP);



%=====================
% EVALUATE CPP RESULT
%=====================
detBBoxs        = [];
detBBoxIds      = [];
detConfs        = [];
gtBBoxs         = [];
gtIds           = [];
numPositives    = 0;
evalMinOverlap  = 0.5;
figNum = 2000;

CPP_RESULT_PATH = 'D:\work\PAPD_CPP\PAPD_CPP_Results\20160308_DPM_2';

for frameIdx = 0 : 435
    
    M = dlmread(fullfile(CPP_RESULT_PATH,sprintf('frame_%04d_result.txt',frameIdx)));
    curGTs = cellGroundTruths{frameIdx+1};
    curGTs(:,1:2) = [curGTs(:,1) - curGTs(:,3)/2, curGTs(:,2) - curGTs(:,4)/2];
    
    M(M(:,5)==0,:) = [];
    
    detBBoxs     = [detBBoxs; M(:,1:4)*0.5]; % x1 x2 y1 y2
    gtBBoxs      = [gtBBoxs; curGTs];
    detConfs     = [detConfs; M(:,5)];
    detBBoxIds   = [detBBoxIds; frameIdx * ones(size(M,1),1)];
    gtIds        = [gtIds; frameIdx * ones(size(curGTs,1),1)];
    numPositives = numPositives + size(curGTs,1);    
end
fprintf(' Read annotation DONE.\n');

%==============================
% RUN EVALUATION
%==============================
TruePositive    = zeros(length(detConfs), 1);
FalsePositive   = zeros(length(detConfs), 1);
gtDetected      = zeros(numPositives, 1);
[~, detSortI]   = sort(-detConfs);
detBBoxs        = detBBoxs(detSortI, :);
detBBoxIds      = detBBoxIds(detSortI);
tic;
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
    bb      = detBBoxs(detIdx, :);
%     bb      = [bb(1), bb(2), bb(1)+bb(3), bb(2)+bb(4)]; % convert [x1 y1 x2 y2]
    ovMax   = -inf;
    for gtIdx = 1 : size(gtBBs, 1)
        curGTBB = gtBBs(gtIdx, :);
        % convert [x1 y1 x2 y2]
        gtbb = [curGTBB(1), curGTBB(2), ...
            curGTBB(1)+curGTBB(3), curGTBB(2)+curGTBB(4)];        
        % compute overlap
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
fprintf(' Evaluation DONE.\n');

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

figure(figNum); hold on;
plot(rec,prec,'b-');
grid;
axis([0 1 0 1]);
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
figure(figNum+1); hold on;
plot(FPPI, 1-MISSRATE);
xlabel 'FPPI'
ylabel 'MISSRATE'
% lims = [0 10 0 1];
% plotRoc([FPPI, MISSRATE],'logx',1,'logy',0,'xLbl','fppi',...
%   'lims',lims,'color','g','smooth',1,'fpTarget',ref);
miss=exp(mean(log(max(1e-10,1-ref))));
title(sprintf('log-average miss rate = %.2f%%',miss*100));
