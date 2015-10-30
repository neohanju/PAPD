function stDPMEvaluationResult = EvaluateDPM (datasetpath, cellGroundTruths, evalMinOverlap)
%==========================================================================
% This code evaluates DPM detection results on PETS 2009 datset,
% and automatically saves the evaluation results.
%
%==========================================================================
%
%
%              _-=-.          .*                            ====
%             ((___)         .*'          Stretch out      (o o")
%             _\ -/_        .*'      _     with your       _\- /_
%            /  \ / \      .*'      /o\    feelings!      / \  / \
%           //|  | |\\    .*'       \_/                  /   \/   \
%           \\|  | | \\  /*'                            / /| |  |\ |
%            \\  | |  \\//                              || | |  | ||
%             ')===|   <)                               (` | |  | `)
%             | || |                                       | |  |
%             (_)(_)                                       | |\ |
%             |_||_|                                      /  || \
%             |_||_|                                     /   ||_|\
% ___________/__][__\___________________________________/____|[_]_\__
%

global START_FRAME_IDX END_FRAME_IDX
global PARTCANDIDATE_DIR PARTCANDIDATE_FORM PARTCANDIDATE_SCALE

% Output argument: structure for evaluation (example)
stDPMEvaluationResult = struct(...
    'precision', 0, ...
    'recall', 0, ...
    'missRate', 0, ...
    'FPPI', 0);

fprintf('==========================================\n');
fprintf(' START DPM EVALUATION \n');
fprintf(' Dataset DIR: %s\n', datasetpath);
fprintf('==========================================\n');
% time setting
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
for frameIdx = START_FRAME_IDX : END_FRAME_IDX
    if toc > 1
        fprintf('Read Annotation: %d/%d\n', frameIdx, END_FRAME_IDX);
        drawnow;
        tic;
    end
    %================================
    % load DPM detections and GTs
    %================================
    partPath = fullfile(PARTCANDIDATE_DIR, sprintf(PARTCANDIDATE_FORM, frameIdx));
    load(partPath);
    coords = coords / PARTCANDIDATE_SCALE;
    % sorting detections
    detConf = coords(end,:)';
    [~, sortI] = sort(-detConf);
    dets = coords([1:4 end-1 end],sortI)';
    I = nms(dets, evalMinOverlap);
    % concatenate annotations
    detBBoxs = [detBBoxs; dets(I, 1:4)];        % [x1, y1, x2, y2]
    curGTs = cellGroundTruths{frameIdx+1};  % frame starts from 0 (CAUTION!)
    curGTs(:,1:2) = [curGTs(:,1) - curGTs(:,3)/2, curGTs(:,2) - curGTs(:,4)/2]; % [centerx, centery, width, height]
    gtBBoxs = [gtBBoxs; curGTs];
    detConfs = [detConfs; dets(I, end)];
    % attach frame indices
    detBBoxIds = [detBBoxIds; frameIdx * ones(length(I),1)];
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
    bb      = detBBoxs(detIdx, :);
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

figure(2001); clf;
plot(rec,prec,'-');
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
figure(3001); clf;
% plot(xs, 1-ys);
lims = [0 10 0 1];
plotRoc([FPPI, MISSRATE],'logx',1,'logy',0,'xLbl','fppi',...
  'lims',lims,'color','g','smooth',1,'fpTarget',ref);
miss=exp(mean(log(max(1e-10,1-ref))));
title(sprintf('log-average miss rate = %.2f%%',miss*100));


%==============================
% SAVE AND END
%==============================
stDPMEvaluationResult.FPPI      = FPPI;
stDPMEvaluationResult.missrate  = MISSRATE;
stDPMEvaluationResult.precision = prec;
stDPMEvaluationResult.recall    = rec;
fprintf('==========================================\n');




% 
% 
% for frameIdx = START_FRAME_IDX : END_FRAME_IDX
%     if toc > 1
%         fprintf('evaluation: %d/%d\n', frameIdx, END_FRAME_IDX);
%         drawnow;
%         tic;
%     end
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
%         curDetBB = curBBoxs(bbIdx,:);
%         ovMax = -inf;
%         for gtIdx = 1 : size(curGTs, 1)
%             curGTBB = curGTs(gtIdx, :);
%             
%             % convert [x1 y1 x2 y2]
%             bb = [curDetBB(1), curDetBB(2), curDetBB(3), curDetBB(4)];
%             gtbb = [curGTBB(1), curGTBB(2), ...
%                 curGTBB(1)+curGTBB(3), curGTBB(2)+curGTBB(4)];
%             
%             % check overlap is larger than evalMinOverlap
%             bi = [max(bb(1),gtbb(1)); max(bb(2),gtbb(2));...
%                 min(bb(3),gtbb(3)); min(bb(4),gtbb(4))];
%             iw = bi(3)-bi(1)+1;
%             ih = bi(4)-bi(2)+1;
%             if iw>0 && ih>0
%                 % compute overlap
%                 ua = (bb(3)-bb(1)+1)*(bb(4)-bb(2)+1)+...
%                     (gtbb(3)-gtbb(1)+1) *(gtbb(4)-gtbb(2)+1)-...
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
%     allTruePositive = [allTruePositive; truePositive];
%     allFalsePositive = [allFalsePositive; falsePositive];
%     %     sumTruePositive = sumTruePositive + sum(truePositive);
%     %     sumFalsePositive = sumFalsePositive + sum(falsePositive);
%     
%     %==============================
%     % MISS RATE & FPPI
%     %==============================
%     
% %     % VISUALIZE
% %     main_init;
% %     figure(frameIdx+1);
% %     imagePath = fullfile(IMAGE_DIR, sprintf([IMAGE_NAMEFORM, '.', IMAGE_FORMATE], frameIdx));
% %     image = imread(imagePath);
% %     imshow(image, 'border', 'tight'); hold on;
% %     for k = 1 : size(curBBoxs, 1)
% %         bbs = [curBBoxs(k,1), curBBoxs(k,2), curBBoxs(k,3)-curBBoxs(k,1), curBBoxs(k,4)-curBBoxs(k,2)];
% %         rectangle('Position', bbs, 'EdgeColor', 'r');
% %     end
% %     for k = 1 : size(curGTs, 1)
% %         rectangle('Position', curGTs(k,:), 'EdgeColor', 'b');
% %     end
% %     pause;
% end
% t_eval = toc(t_main);
% fprintf(' DONE! Evaluation time: %f \n', t_eval);

% %==============================
% % compute precision/recall
% %==============================
% fprintf(' COMPUTE PRECISION / RECALL \n')
% FP   = cumsum(allFalsePositive);
% TP   = cumsum(allTruePositive);
% rec  = TP / numPositives;
% prec = TP ./ (FP+TP);
% AP   = 0;
% for t=0:0.1:1
%     p=max(prec(rec>=t));
%     if isempty(p)
%         p=0;
%     end
%     AP=AP+p/11;
% end
% 
% figure(2001);
% plot(rec,prec,'-');
% grid;
% xlabel 'recall'
% ylabel 'precision'
% title(sprintf('AP = %.3f',AP));
% 
% stDPMEvaluationResult.precision = prec;
% stDPMEvaluationResult.recall    = rec;
% 
% % fprintf(' precision: %f\n', prec);
% % fprintf(' recall   : %f\n', rec);
% fprintf('==========================================\n');

end