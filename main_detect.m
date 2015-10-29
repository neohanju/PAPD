%==========================================================================
% Name : MAIN_DETECT                                                         
% Date : 2015.10.29
% Author : Yoo & Yun
% Version : 0.9
%==========================================================================
%     .__                           __.
%       \ `\~~---..---~~~~~~--.---~~| /   
%        `~-.   `                   .~         _____ 
%            ~.                .--~~    .---~~~    /
%             / .-.      .-.      |  <~~        __/
%            |  |_|      |_|       \  \     .--'
%           /-.      -       .-.    |  \_   \_
%           \-'   -..-..-    `-'    |    \__  \_ 
%            `.                     |     _/  _/
%              ~-                .,-\   _/  _/
%             /                 -~~~~\ /_  /_
%            |               /   |    \  \_  \_ 
%            |   /          /   /      | _/  _/
%            |  |          |   /    .,-|/  _/ 
%            )__/           \_/    -~~~| _/
%              \                      /  \
%               |           |        /_---` 
%               \    .______|      ./
%               (   /        \    /
%               `--'          /__/
%==========================================================================

% initialization
main_init;

% structure for result
stDetectionResult = struct(...
    'dataset', '', ...
    'startFrame', 0, ...
    'endFrame', 0, ...
    'startingTime', 0, ...
    'solverTimeLimit', 0, ...
    'headNMSRatio', 0, ...
    'partNMSRatio', 0, ...
    'cellBBoxs', [], ...
    'cellPBoxs', [], ...
    'solvingTime', 0);

% ground truth
cellGroundTruths = load(fullfile(GROUNDTRUTH_DIR, GROUNDTRUTH_NAME));

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%% DETECTION LOOP
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
numExp         = 0;
numTotalExps   = numHNR * numPNR;
figFrameResult = figure;
figExpInfo     = figure;
for hnrIdx = 1:numHNR
    for pnrIdx = 1:numPNR
        %==========================================
        % EXPERIEMENT SETTING
        %==========================================
        numExp = numExp + 1;
        stDetectionResult(numExp).dataset         = DATASET_PATH;
        stDetectionResult(numExp).startFrame      = START_FRAME_IDX;
        stDetectionResult(numExp).endFrame        = END_FRAME_IDX;
        stDetectionResult(numExp).startingTime    = clock;
        stDetectionResult(numExp).solverTimeLimit = SOVLER_TIMELIMIT;
        stDetectionResult(numExp).headNMSRatio    = HEAD_NMS_RATIO(hnrIdx);
        stDetectionResult(numExp).partNMSRatio    = PART_NMS_RATIO(pnrIdx);
        stDetectionResult(numExp).cellBBoxs       = cell(numFrames, 1);
        stDetectionResult(numExp).cellPBoxs       = cell(numFrames, 1);
        stDetectionResult(numExp).solvingTime     = END_FRAME_IDX;
        figure(figExpInfo); imshow(zeros(20,300), 'border', 'tight'); hold on;
        text(10,10,...
            sprintf('parameter setting %03d/%03d >> hnr:%1.2f, pnr:%1.2f', ...
            numExp, numTotalExps, HEAD_NMS_RATIO(hnrIdx), PART_NMS_RATIO(pnrIdx)),...
            'color', [1,1,1]); 
        hold off;
        
        cellIdx = 0;
        for frameIdx = START_FRAME_IDX:END_FRAME_IDX
            fprintf('===================================================\n');
            fprintf(' FRAME: %04d\n', frameIdx);
            fprintf('===================================================\n');
            imagePath = fullfile(IMAGE_DIR, sprintf([IMAGE_NAMEFORM, '.', IMAGE_FORMATE], frameIdx));
            image = imread(imagePath);            
            
            %==========================================
            % PART DETECTION
            %==========================================
            partPath = fullfile(PARTCANDIDATE_DIR, sprintf(PARTCANDIDATE_FORM, frameIdx));
            load(partPath);
            partDetections.partscores = partscores;
            partDetections.coords     = coords;
            partDetections.scale      = PARTCANDIDATE_SCALE;
            
            %==========================================
            % PART DETECTION
            %==========================================d
            [bboxs, pboxs, solutionDetails, listCParts] = PAPD(...
                image, partDetections, model, ...
                ROOT_MAX_OVERLAP, ...
                stDetectionResult(numExp).headNMSRatio, ...
                stDetectionResult(numExp).partNMSRatio, ...
                stDetectionResult(numExp).partNMSRatio, ...
                stDetectionResult(numExp).solverTimeLimit);
            
            cellIdx = cellIdx + 1;
            stDetectionResult(numExp).cellBBoxs{cellIdx} = bboxs;
            stDetectionResult(numExp).cellPBoxs{cellIdx} = pboxs;
            
            %==========================================
            % FRAME RESULT VISUALIZATION
            %==========================================
            ShowFrameResult(image, frameIdx, stDetectionResult(numExp).cellPBoxs{cellIdx}, ...
                figFrameResult, CDC);
        end
        stDetectionResult(numExp).solvingTime = ...
            clock - stDetectionResult(numExp).startingTime;
        
        %==========================================
        % EVALUATION
        %==========================================
        % todo...
        % stEvaluationResult(numExp).averagePrecision = -1000;
        % stEvaluationResult(numExp).missRate = inf;
        stEvaluationResult(numExp) = Evaluate(stDetectionResult(numExp), cellGroundTruths);
        
        %==========================================
        % RESULT SAVING
        %==========================================
        curDetectionResult  = stDetectionResult(numExp);
        curEvaluationResult = stEvaluationResult(numExp);
        save(fullfile(RESULT_DIR, sprintf(RESULT_NAMEFORM, frameIdx, ...
            stDetectionResult(numExp).headNMSRatio, ...            
            stDetectionResult(numExp).partNMSRatio)), ...
            '-v6', ...
            'curDetectionResult', 'curEvaluationResult');
    end
end

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%% RESULT VISUALIZATION
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
PlotResults(stDetectionResult, stEvaluationResult);

%()()
%('')END_OF_DOCUMENT
