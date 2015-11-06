function [stEvaluationResult] = Evaluate(stDetectionResult, cellGroundTruths, evalMinOverlap)
%==========================================================================
% Input arguments
%--------------------------------------------------------------------------
%   stDetectionResult (struct)
%       cellBBox{cellIdx} = bboxs; 
%           - bboxs: [left, top, width, height]
%           - cellIdx: frameIdx - START_FRAME_IDX + 1
%   cellGroundTruth (struct)
%       cellGroundTruths{frameIdx}
%           - [centerx, centery, width, height]
%--------------------------------------------------------------------------
% 
% 
%                              /~\
%                             |oo )   Did you hear that?
%                             _\=/_
%             ___        #   /  _  \
%            / ()\        \\//|/.\|\\
%          _|_____|_       \/  \_/  ||
%         | | === | |         |\ /| ||
%         |_|  O  |_|         \_ _/  #
%          ||  O  ||          | | |
%          ||__*__||          | | |
%         |~ \___/ ~|         []|[]
%         /=\ /=\ /=\         | | |
%         [_] [_] [_]        /_]_[_\
% 
% 
% 
%==========================================================================

%==============================
% Settings
%==============================
% main_init;
% Output argument: structure for evaluation (example)
stEvaluationResult = struct(...
    'precision', 0, ...
    'recall', 0, ...
    'missRate', 0, ...
    'FPPI', 0);
% Get ground truths and detected bboxs
cellGTs = cellGroundTruths;
cellBBoxs = stDetectionResult.cellBBoxs;
% Get start and end frames
START_FRAME_IDX = stDetectionResult.startFrame;
END_FRAME_IDX   = stDetectionResult.endFrame;

%==============================
% Run evaluation
%==============================
% initialize
sumTruePositive     = 0;
sumFalsePositive    = 0;
numPositives        = 0;

% run loop
fprintf('==========================================\n');
fprintf(' START EVALUATION \n');
fprintf(' Dataset DIR: %s\n', stDetectionResult.dataset);
fprintf('==========================================\n');
% time setting
t_main = tic;
tic;
%===========================
% Gathering Annotations
%===========================
detBBoxs     = [];
detBBoxIds   = [];
detConfs     = [];
gtBBoxs      = [];
gtIds        = [];
numPositives = 0;
for frameIdx = START_FRAME_IDX : END_FRAME_IDX
    if toc > 1
        fprintf('Read annotation: %d/%d\n', frameIdx, END_FRAME_IDX);
        drawnow;
        tic;
    end
    %================================
    % Read Detections and GTs
    %================================
    curBBoxs = cellBBoxs{frameIdx - START_FRAME_IDX + 1};
    % frame starts from 0 (CAUTION!)
    curGTs = cellGTs{frameIdx+1}; % [centerx, centery, width, height]
    curGTs(:,1:2) = [curGTs(:,1) - curGTs(:,3)/2, curGTs(:,2) - curGTs(:,4)/2]; 
    
    
    % concatenate annotations
    detBBoxs    = [detBBoxs; curBBoxs(:,1:4)];        % [x1, y1, x2, y2]
    gtBBoxs     = [gtBBoxs; curGTs];
    detConfs    = [detConfs; curBBoxs(:, end-1)];       % normalized score (end-1: score)
    % attach frame indices
    detBBoxIds  = [detBBoxIds; frameIdx * ones(size(curBBoxs,1),1)];
    gtIds       = [gtIds; frameIdx * ones(size(curGTs,1),1)];
    numPositives = numPositives + size(curGTs,1);    
    
%     % VISUALIZE
%     main_init;
%     figure(frameIdx+1);
%     imagePath = fullfile(IMAGE_DIR, sprintf([IMAGE_NAMEFORM, '.', IMAGE_FORMATE], frameIdx));
%     image = imread(imagePath);
%     imshow(image, 'border', 'tight'); hold on;
%     for k = 1 : size(curBBoxs, 1)
%         rectangle('Position', curBBoxs(k,1:4), 'EdgeColor', 'r');
%     end
%     for k = 1 : size(curGTs, 1)
%         rectangle('Position', curGTs(k,1:4), 'EdgeColor', 'b');
%     end     
    
    
end
fprintf(' Read annotation DONE.\n');
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
    bb      = detBBoxs(detIdx, :);
    bb      = [bb(1), bb(2), bb(1)+bb(3), bb(2)+bb(4)]; % convert [x1 y1 x2 y2]
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

figure(2000); clf;
plot(rec,prec,'-');
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
figure(2001); clf;
plot(FPPI, 1-MISSRATE);
xlabel 'FPPI'
ylabel 'MISSRATE'
% lims = [0 10 0 1];
% plotRoc([FPPI, MISSRATE],'logx',1,'logy',0,'xLbl','fppi',...
%   'lims',lims,'color','g','smooth',1,'fpTarget',ref);
miss=exp(mean(log(max(1e-10,1-ref))));
title(sprintf('log-average miss rate = %.2f%%',miss*100));


%==============================
% SAVE AND END
%==============================
stEvaluationResult.FPPI      = FPPI;
stEvaluationResult.missRate  = MISSRATE;
stEvaluationResult.precision = prec;
stEvaluationResult.recall    = rec;
fprintf('==========================================\n');

% for frameIdx = START_FRAME : END_FRAME
%     if toc > 1
%         fprintf('evaluation: %d/%d\n', START_FRAME, END_FRAME);
%         drawnow;
%         tic;
%     end
%     curGTs = cellGTs{frameIdx+1}; % frame starts from 0 (IMPORTANT!)
%     % cellGT: [centerx, centery, width, height]    
%     curGTs(:,1:2) = [curGTs(:,1) - curGTs(:,3)/2, curGTs(:,2) - curGTs(:,4)/2];
%     curBBoxs = cellBBoxs{frameIdx - START_FRAME + 1};    
% 
%     %==============================
%     % PRECISION & RECALL
%     %==============================
%     % checking variable whether gt is already detected
%     gtDetected      = zeros(size(curGTs, 1), 1);
%     truePositive    = zeros(size(curBBoxs, 1), 1);
%     falsePositive   = zeros(size(curBBoxs, 1), 1);
%     numPositives    = numPositives + size(curGTs, 1);
%     for bbIdx = 1 : size(curBBoxs, 1)
%         curDetBB = curBBoxs(bbIdx,1:4);
%         ovMax = -inf;
%         for gtIdx = 1 : size(curGTs, 1)
%             curGTBB = curGTs(gtIdx, :);
%             
%             % convert [x1 y1 x2 y2]
%             bb = [curDetBB(1), curDetBB(2), ...
%                 curDetBB(1)+curDetBB(3), curDetBB(2)+curDetBB(4)];
%             gtbb = [curGTBB(1), curGTBB(2), ...
%                 curGTBB(1)+curGTBB(3), curGTBB(2)+curGTBB(4)];            
%             
%             % check overlap is larger than evalMinOverlap
%             bi = [max(bb(1),gtbb(1)); max(bb(2),gtbb(2));...
%                   min(bb(3),gtbb(3)); min(bb(4),gtbb(4))];
%             iw = bi(3)-bi(1)+1;
%             ih = bi(4)-bi(2)+1;
%             if iw>0 && ih>0   
%                 % compute overlap
%                 ua = (bb(3)-bb(1)+1)*(bb(4)-bb(2)+1)+...
%                       (gtbb(3)-gtbb(1)+1) *(gtbb(4)-gtbb(2)+1)-...
%                     iw*ih;
%                 overlap = iw*ih/ua;
%                 if overlap > ovMax
%                     ovMax    = overlap;
%                     gtIdxMax = gtIdx;
%                 end
%             end
%         end
%         
%         % assign detection as true positive / false positive
%         if ovMax > evalMinOverlap
%             if ~gtDetected(gtIdxMax)
%                 % true positive
%                 gtDetected(gtIdxMax) = true;
%                 truePositive(bbIdx) = 1;
%             else 
%                 % false positive (multiple detection)
%                 falsePositive(bbIdx) = 1;
%             end
%         else
%             % false positive
%             falsePositive(bbIdx) = 1;
%         end        
%     end    
%     sumTruePositive = sumTruePositive + sum(truePositive);
%     sumFalsePositive = sumFalsePositive + sum(falsePositive);
%     
%     %==============================
%     % MISS RATE & FPPI
%     %==============================
%     
%     
%     
%     
%     
% %     % VISUALIZE
% %     figure(frameIdx+1);
% %     imagePath = fullfile(IMAGE_DIR, sprintf([IMAGE_NAMEFORM, '.', IMAGE_FORMATE], frameIdx));
% %     image = imread(imagePath);
% %     imshow(image, 'border', 'tight'); hold on;
% %     for k = 1 : size(curBBoxs, 1)
% %         rectangle('Position', curBBoxs(k,1:4), 'EdgeColor', 'r');
% %     end
% %     for k = 1 : size(curGTs, 1)
% %         rectangle('Position', curGTs(k,1:4), 'EdgeColor', 'b');
% %     end    
%     
% end
% t_eval = toc(t_main);
% fprintf(' DONE! Evaluation time: %f \n', t_eval);
% prec    = sumTruePositive/ (sumTruePositive+sumFalsePositive);
% rec     = sumTruePositive/ numPositives;
% fprintf(' precision: %f\n', prec);
% fprintf(' recall   : %f\n', rec);
% fprintf('==========================================\n');
% 
% stEvaluationResult.precision = prec;
% stEvaluationResult.recall    = rec;






















