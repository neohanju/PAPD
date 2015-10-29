function stDPMEvaluationResult = EvaluateDPM ()
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


% Output argument: structure for evaluation (example)
stDPMEvaluationResult = struct(...
    'precision', 0, ...
    'recall', 0, ...
    'missRate', 0, ...
    'FPPI', 0);

% init
main_init;

% load Ground Truths
load(fullfile(GROUNDTRUTH_DIR, GROUNDTRUTH_NAME));

%===========================
% run loop
%===========================
fprintf('==========================================\n');
fprintf(' START DPM EVALUATION \n');
fprintf(' Dataset DIR: %s\n', DATASET_PATH);
fprintf('==========================================\n');
% time setting
t_main = tic;
tic;
allTruePositive = [];
allFalsePositive = [];
numPositives = 0;
for frameIdx = START_FRAME_IDX : END_FRAME_IDX
    if toc > 1
        fprintf('evaluation: %d/%d\n', frameIdx, END_FRAME_IDX);
        drawnow;
        tic;
    end
    %=======================
    % load DPM detections
    %=======================
    partPath = fullfile(PARTCANDIDATE_DIR, sprintf(PARTCANDIDATE_FORM, frameIdx));
    load(partPath);  
    coords = coords / PARTCANDIDATE_SCALE;
    dets = coords([1:4 end-1 end],:)';
    I = nms(dets, EVAL_MIN_OVERLAP);
    curBBoxs = coords(1:4,I)'; % [x1, y1, x2, y2]    
    curGTs = cellGroundTruths{frameIdx+1}; % frame starts from 0 (IMPORTANT!)
    % cellGT: [centerx, centery, width, height]  
    curGTs(:,1:2) = [curGTs(:,1) - curGTs(:,3)/2, curGTs(:,2) - curGTs(:,4)/2];
        

    %==============================
    % PRECISION & RECALL
    %==============================
    % checking variable whether gt is already detected
    gtDetected      = zeros(size(curGTs, 1), 1);
    truePositive    = zeros(size(curBBoxs, 1), 1);
    falsePositive   = zeros(size(curBBoxs, 1), 1);
    numPositives    = numPositives + size(curGTs, 1);
    for bbIdx = 1 : size(curBBoxs, 1)
        curDetBB = curBBoxs(bbIdx,:);
        ovMax = -inf;
        for gtIdx = 1 : size(curGTs, 1)
            curGTBB = curGTs(gtIdx, :);
            
            % convert [x1 y1 x2 y2]
            bb = [curDetBB(1), curDetBB(2), curDetBB(3), curDetBB(4)];
            gtbb = [curGTBB(1), curGTBB(2), ...
                curGTBB(1)+curGTBB(3), curGTBB(2)+curGTBB(4)];            
            
            % check overlap is larger than EVAL_MIN_OVERLAP
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
                    gtIdxMax = gtIdx;
                end
            end
        end
        
        % assign detection as true positive / false positive
        if ovMax > EVAL_MIN_OVERLAP
            if ~gtDetected(gtIdxMax)
                % true positive
                gtDetected(gtIdxMax) = true;
                truePositive(bbIdx) = 1;
            else 
                % false positive (multiple detection)
                falsePositive(bbIdx) = 1;
            end
        else
            % false positive
            falsePositive(bbIdx) = 1;
        end        
    end    
    allTruePositive = [allTruePositive; truePositive];
    allFalsePositive = [allFalsePositive; falsePositive];
%     sumTruePositive = sumTruePositive + sum(truePositive);
%     sumFalsePositive = sumFalsePositive + sum(falsePositive);
    
    %==============================
    % MISS RATE & FPPI
    %==============================
    
%     % VISUALIZE
%     figure(frameIdx+1);
%     imagePath = fullfile(IMAGE_DIR, sprintf([IMAGE_NAMEFORM, '.', IMAGE_FORMATE], frameIdx));
%     image = imread(imagePath);
%     imshow(image, 'border', 'tight'); hold on;
%     for k = 1 : size(curBBoxs, 1)
%         bbs = [curBBoxs(k,1), curBBoxs(k,2), curBBoxs(k,3)-curBBoxs(k,1), curBBoxs(k,4)-curBBoxs(k,2)];
%         rectangle('Position', bbs, 'EdgeColor', 'r');
%     end
%     for k = 1 : size(curGTs, 1)
%         rectangle('Position', curGTs(k,:), 'EdgeColor', 'b');
%     end    
%     pause;
end
t_eval = toc(t_main);
fprintf('==========================================\n');
fprintf(' DONE! Evaluation time: %f \n', t_eval);
fprintf('==========================================\n');

%==============================
% compute precision/recall
%==============================
fprintf(' COMPUTE PRECISION / RECALL \n')
FP   = cumsum(allFalsePositive);
TP   = cumsum(allTruePositive);
rec  = TP / numPositives;
prec = FP ./ (FP+TP);
AP   = 0;
for t=0:0.1:1
    p=max(prec(rec>=t));
    if isempty(p)
        p=0;
    end
    AP=AP+p/11;
end

plot(rec,prec,'-');
grid;
xlabel 'recall'
ylabel 'precision'
title(sprintf('AP = %.3f',AP));

stDPMEvaluationResult.precision = prec;
stDPMEvaluationResult.recall    = rec;

save(fullfile(RESULT_DIR, sprintf('frame_%04d_DPM_result_%1.2f.mat', frameIdx, ...
            EVAL_MIN_OVERLAP)), '-v6', ...
            'stDPMEvaluationResult');


fprintf(' END ! \n');
fprintf('==========================================\n');

end