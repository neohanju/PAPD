%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% Name : PART ASSOCIATION
% Date : 2015.09.22
% Author : HaanJu.Yoo
% Version : 0.9
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%                                            ....
%                                           W$$$$$u
%                                           $$$$F**+           .oW$$$eu
%                                           ..ueeeWeeo..      e$$$$$$$$$
%                                       .eW$$$$$$$$$$$$$$$b- d$$$$$$$$$$W
%                           ,,,,,,,uee$$$$$$$$$$$$$$$$$$$$$ H$$$$$$$$$$$~
%                        :eoC$$$$$$$$$$$C""?$$$$$$$$$$$$$$$ T$$$$$$$$$$"
%                         $$$*$$$$$$$$$$$$$e "$$$$$$$$$$$$$$i$$$$$$$$F"
%                         ?f"!?$$$$$$$$$$$$$$ud$$$$$$$$$$$$$$$$$$$$*Co
%                         $   o$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$
%                 !!!!m.*eeeW$$$$$$$$$$$f?$$$$$$$$$$$$$$$$$$$$$$$$$$$$$U
%                 !!!!!! !$$$$$$$$$$$$$$  T$$$$$$$$$$$$$$$$$$$$$$$$$$$$$
%                  *!!*.o$$$$$$$$$$$$$$$e,d$$$$$$$$$$$$$$$$$$$$$$$$$$$$$:
%                 "eee$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$C
%                b ?$$$$$$$$$$$$$$**$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$!
%                Tb "$$$$$$$$$$$$$$*uL"$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$'
%                 $$o."?$$$$$$$$F" u$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$
%                  $$$$en ```    .e$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$'
%                   $$$B*  =*"?.e$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$F
%                    $$$W"$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$"
%                     "$$$o#$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$"
%                    R: ?$$$W$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$" :!i.
%                     !!n.?$???""``.......,``````"""""""""""``   ...+!!!
%                      !* ,+::!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!*`
%                      "!?!!!!!!!!!!!!!!!!!!~ !!!!!!!!!!!!!!!!!!!~`
%                      +!!!!!!!!!!!!!!!!!!!! !!!!!!!!!!!!!!!!!!?!`
%                    .!!!!!!!!!!!!!!!!!!!!!' !!!!!!!!!!!!!!!, !!!!
%                   :!!!!!!!!!!!!!!!!!!!!!!' !!!!!!!!!!!!!!!!! `!!:
%                .+!!!!!!!!!!!!!!!!!!!!!~~!! !!!!!!!!!!!!!!!!!! !!!.
%               :!!!!!!!!!!!!!!!!!!!!!!!!!.`:!!!!!!!!!!!!!!!!!:: `!!+
%               "~!!!!!!!!!!!!!!!!!!!!!!!!!!.~!!!!!!!!!!!!!!!!!!!!.`!!:
%                   ~~!!!!!!!!!!!!!!!!!!!!!!! ;!!!!~` ..eeeeeeo.`+!.!!!!.
%                 :..    `+~!!!!!!!!!!!!!!!!! :!;`.e$$$$$$$$$$$$$u .
%                 $$$$$$beeeu..  `````~+~~~~~" ` !$$$$$$$$$$$$$$$$ $b
%                 $$$$$$$$$$$$$$$$$$$$$UU$U$$$$$ ~$$$$$$$$$$$$$$$$ $$o
%                !$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$. $$$$$$$$$$$$$$$~ $$$u
%                !$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$! $$$$$$$$$$$$$$$ 8$$$$.
%                !$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$X $$$$$$$$$$$$$$`u$$$$$W
%                !$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$! $$$$$$$$$$$$$".$$$$$$$:
%                 $$$$$$$$$$$$$$$$$$$$$$$$$$$$$$  $$$$$$$$$$$$F.$$$$$$$$$
%                 ?$$$$$$$$$$$$$$$$$$$$$$$$$$$$f $$$$$$$$$$$$' $$$$$$$$$$.
%                  $$$$$$$$$$$$$$$$$$$$$$$$$$$$ $$$$$$$$$$$$$  $$$$$$$$$$!
%                  "$$$$$$$$$$$$$$$$$$$$$$$$$$$ ?$$$$$$$$$$$$  $$$$$$$$$$!
%                   "$$$$$$$$$$$$$$$$$$$$$$$$Fib ?$$$$$$$$$$$b ?$$$$$$$$$
%                     "$$$$$$$$$$$$$$$$$$$$"o$$$b."$$$$$$$$$$$  $$$$$$$$'
%                    e. ?$$$$$$$$$$$$$$$$$ d$$$$$$o."?$$$$$$$$H $$$$$$$'
%                   $$$W.`?$$$$$$$$$$$$$$$ $$$$$$$$$e. "??$$$f .$$$$$$'
%                  d$$$$$$o "?$$$$$$$$$$$$ $$$$$$$$$$$$$eeeeee$$$$$$$"
%                  $$$$$$$$$bu "?$$$$$$$$$ 3$$$$$$$$$$$$$$$$$$$$*$$"
%                 d$$$$$$$$$$$$$e. "?$$$$$:`$$$$$$$$$$$$$$$$$$$$8
%         e$$e.   $$$$$$$$$$$$$$$$$$+  "??f "$$$$$$$$$$$$$$$$$$$$c
%        $$$$$$$o $$$$$$$$$$$$$$$F"          `$$$$$$$$$$$$$$$$$$$$b.
%       M$$$$$$$$U$$$$$$$$$$$$$F"              ?$$$$$$$$$$$$$$$$$$$$$u
%       ?$$$$$$$$$$$$$$$$$$$$F                   "?$$$$$$$$$$$$$$$$$$$$u
%        "$$$$$$$$$$$$$$$$$$"                       ?$$$$$$$$$$$$$$$$$$$$o
%          "?$$$$$$$$$$$$$F                            "?$$$$$$$$$$$$$$$$$$
%             "??$$$$$$$F                                 ""?3$$$$$$$$$$$$F
%                                                       .e$$$$$$$$$$$$$$$$'
%                                                      u$$$$$$$$$$$$$$$$$
%                                                     `$$$$$$$$$$$$$$$$"
%                                                      "$$$$$$$$$$$$F"
%                                                        ""?????""
%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

dbstop if error

fprintf('=======================================\n');
timeStart = clock;
fprintf(['PAPD starts at: ' ...
    datestr(datenum(0,0,0,timeStart(4),timeStart(5),timeStart(6)),'HH:MM:SS') '\n']);
fprintf('=======================================\n');

% init
papd_init;

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%% PARAMETER AND PRESET, INPUT
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
image              = imread(['data/' INPUT_FILE_NAME '.jpg']);
imageScale         = 2.0;
[imgH, imgW, imgC] = size(image);

% load deformable part model
load model/INRIAPERSON_star.mat;

% load part detection results
load(['data/' INPUT_FILE_NAME '_part_candidates.mat']);
[numPartTypes, numDetections] = size(partscores);
numPartTypes = numPartTypes - 1; % exclude "pyramidLevel"
numComponent = length(unique(coords(end-1,:)));

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%% PART RESPONSES AND PRE-PROCESSING
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

%==========================================
% NON MAXIMAL SUPPRESSION WITH HEAD PART
%==========================================
pickedIdx = cell(1, numComponent);
numRoots = 0;
for componentIdx = 1:numComponent    
    % get data of current component
    curComponentIdx    = find(componentIdx == coords(end-1,:));
    curComponents      = coords(:,curComponentIdx);
    curComponentScores = partscores(:,curComponentIdx);      
    typeIdx    = 2; % head = 2
    typeOffset = 5;
    headCoords = curComponents(typeOffset:typeOffset+3,:);
    headScores = curComponentScores(typeIdx,:);    
    % nms    
    pickedIdx{componentIdx} = ...
        curComponentIdx(nms2([headCoords; headScores]', PART_MAX_OVERLAP));
    numRoots = numRoots + length(pickedIdx{componentIdx});
end 

%==========================================
% MAKE LISTCPARTS
%==========================================
fprintf('Make part list...');

numParts = 0;
listCParts = CPart.empty();

numFullbodies = 0;
FullbodyCombinations = zeros(numRoots, numPartTypes);

% occlusion prior
partMap = zeros(imageScale * imgH, imageScale * imgW);

% array positions of a specific part and component
cellIndexAmongType = cell(numPartTypes, numComponent); 
for componentIdx = 1:numComponent
    % get data of current component
    curComponentIdx    = pickedIdx{componentIdx};
    curComponents      = coords(:,curComponentIdx);
    curComponentScores = partscores(:,curComponentIdx);    
    
    for rootIdx = pickedIdx{componentIdx}              
        curPyramidLevel = partscores(end,rootIdx);
        % note that scale and a2p are fit to root scale
        curScale      = 2^(-(curPyramidLevel-1)/model.interval);
        curA2p        = model.sbin / curScale;        
        curScore      = partscores(1:end-1,rootIdx);             
        typeOffset    = 1;
        numFullbodies = numFullbodies + 1;
        for typeIdx = 1:numPartTypes
            curCoord = coords(typeOffset:typeOffset+3,rootIdx)';
            typeOffset = typeOffset + 4;
            % save candidates part into 'CPart' class instances
            numParts = numParts + 1;
            listCParts(numParts) = CPart( ...
                componentIdx, typeIdx, curCoord, ...
                partscores(typeIdx,rootIdx), ...
                curPyramidLevel, curScale, curA2p, rootIdx);            
            % save index
            FullbodyCombinations(numFullbodies,typeIdx) = numParts;            
            % occlusion prior
            imageRect = round(curCoord);
            partMap(imageRect(2):imageRect(4),imageRect(1):imageRect(3)) = 1.0;
            % enlarge scale and a2p for parts
            if 1 == typeIdx
                curScale = 2.0 * curScale;
                curA2p = 2.0 * curA2p; 
            end
        end
    end
end
fprintf('done!\n');

%==========================================
% HEAD CLUSTERING
%==========================================
fprintf('Head clustering...');
[cellCombinationCluster, listSingleHeadCluster] = ...
    ClusterHeads(FullbodyCombinations, listCParts);
numClusters = length(cellCombinationCluster);
fprintf('done!\n');


%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%% CANDIDATE DETECTIONS
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

%==========================================
% GENERATE DETECTIONS
%==========================================
fprintf('Generate Detections...');
tic;
cellListDetections = GenerateDetections(listCParts, cellCombinationCluster, PART_OCC_OVERLAP);
t_d = toc;
fprintf(['done!\nelapsed time for generating detections: ' ...
    datestr(datenum(0,0,0,0,0,t_d),'HH:MM:SS') '\n']);

%==========================================
% CLASSIFY DETECTIONS
%==========================================
% SVM
load(fullfile('model', 'ConfigurationClassifiers.mat'));
cellListDetections = ClassifyDetetions_SVM(cellListDetections, SVMModels);

% % thresholding
% load(fullfile('model', 'ConfigurationThresholds.mat'));
% cellListDetections = ClassifyDetetions_Threshold(cellListDetections, cellThresholds);

% %==========================================
% % NORMALIZE SCORES
% %==========================================
% % score normalization (mean - 3 std ~ mean + 3 std -> 0 to 1)
% fprintf('score normalization...');
% normScores = cell(numClusters, 1);
% for clusterIdx = 1:numClusters
%     numCurDetections = length(cellListDetections{clusterIdx});
%     for dIdx = 1:length(cellListDetections{clusterIdx})        
%         curTotalScore  = cellListDetections{clusterIdx}(dIdx).score;
%         curFullScores  = cellListDetections{clusterIdx}(dIdx).fullScores;
%         % configuration
%         curCombination = cellListDetections{clusterIdx}(dIdx).combination;
%         scoreIdx = find(0 < curCombination); 
%         scoreIdx(1 == scoreIdx) = []; % except root
%         curConfigurationString = repmat('0', 1, numPartTypes);
%         curConfigurationString(scoreIdx) = '1';        
%         configurationIdx = bin2dec(curConfigurationString(3:end))+1; % except head and root       
%         % subtract root filter response
%         curTotalScore = curTotalScore - curFullScores(1); 
%         newScore = (curTotalScore - positiveScoreMean(configurationIdx)) ...
%             / (6*positiveScoreStd(configurationIdx)) + 0.5;        
%         newScore = newScore + curFullScores(1);
%         % add root filter response
%         cellListDetections{clusterIdx}(dIdx).score = newScore;
%     end    
%     normScores{clusterIdx} = [cellListDetections{clusterIdx}.score];
% end
% % remove detections having negative scores
% numDeletedDetections = 0;
% for clusterIdx = 1:numClusters
%     numCurDetections = length(cellListDetections{clusterIdx});
%     deathNote = false(1, numCurDetections);
%     for dIdx = 1:numCurDetections
%         if 0 > cellListDetections{clusterIdx}(dIdx).score
%             deathNote(dIdx) = true;
%             numDeletedDetections = numDeletedDetections + 1;
%         end
%     end
%     aliveIdx = 1:numCurDetections;
%     aliveIdx(deathNote) = [];
%     cellListDetections{clusterIdx} = cellListDetections{clusterIdx}(aliveIdx);
% end
% fprintf('done!\nthe number of deleted detections: %d\n', numDeletedDetections);

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%% OPTIMIZATION
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% solve MWCP with the graph
figDebug = figure(100); imshow(image, 'border', 'tight');
cellSolutions = cell(numClusters, 2); % {detection list}{objective value}
for clusterIdx = 1:numClusters
    fprintf('----------SOLVING CLUSTER %03d----------\n', clusterIdx);
    if listSingleHeadCluster(clusterIdx)
        % find and save only the combination which has the maximum score
        fprintf('get the detection having the maximum score\n');
        maxScore = 0.0;
        maxIdx   = 0;
        for dIdx = 1:length(cellListDetections{clusterIdx})
            if 0 < length(find(0 == cellListDetections{clusterIdx}(dIdx).combination))
                % skip non-fullbody
                continue;
            end
            if cellListDetections{clusterIdx}(dIdx).score < maxScore
                continue;
            end
            maxScore = cellListDetections{clusterIdx}(dIdx).score;
            maxIdx   = dIdx;
        end
        if 0 < maxIdx
            cellSolutions{clusterIdx,1} = cellListDetections{clusterIdx}(maxIdx);
            cellSolutions{clusterIdx,2} = maxScore;
        end
    else
        if BATCH_GUROBI
            clear grb_model;
            load(sprintf('data/%s_grb_model_%03d.mat', INPUT_FILE_NAME, clusterIdx));
            [cellSolutions(clusterIdx,:)] = ...
                Optimization_Gurobi_batch(cellListDetections{clusterIdx}, ...
                grb_model, SOVLER_TIMELIMIT);
        else
            % optimize to associate parts
            [cellSolutions(clusterIdx,:), grb_model] = ...
                Optimization_Gurobi(cellListDetections{clusterIdx}, ...
                listCParts, model, ...
                ROOT_MAX_OVERLAP, PART_MAX_OVERLAP, PART_OCC_OVERLAP, ...
                SOVLER_TIMELIMIT);
            save(sprintf('data/%s_grb_model_%03d.mat', INPUT_FILE_NAME, clusterIdx), 'grb_model');
            clear grb_model;
        end
    end
    % DEBUG
    for dIdx = 1:length(cellSolutions{clusterIdx,1})
        figure(figDebug); hold on;
        ShowDetection(cellSolutions{clusterIdx,1}(dIdx), listCParts, 0, 0.5);
        hold off;
    end
    pause(0.01);
end
% save variables needed for result reconstruction
save(['data/' INPUT_FILE_NAME '_result.mat'], ...    
    'cellSolutions', ...
    'listCParts');


%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%% VISUALIZATION
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
CDC = CDistinguishableColors();

%==========================================
% DRAW DETECTION RESULT
%==========================================
% draw full-body combinations (each part)
figResult = figure(10);
imshow(image, 'border', 'tight');
figResultBB = figure(11);
imshow(image, 'border', 'tight');
resultID = 0;
for clusterIdx = 1:numClusters
    for dIdx = 1:length(cellSolutions{clusterIdx,1})
        resultID = resultID + 1;
        curColor = GetColor(CDC, resultID);
        
        % draw results with distinguishable colors
        figure(figResult);
        hold on;
        curDetection = cellSolutions{clusterIdx,1}(dIdx);        
        curRoot = GetBox(listCParts(curDetection.combination(1)))/imageScale;
        rectangle('Position', curRoot, 'EdgeColor', curColor);
        curParts = curDetection.combination(0 < curDetection.combination);
        for pIdx = curParts(2:end)
            curPart = GetBox(listCParts(pIdx))/imageScale;
            rectangle('Position', curPart, 'EdgeColor', curColor);
        end
        hold off;
        
        % draw bounding boxes
        figure(figResultBB);
        hold on;
        rectangle('Position', curRoot, 'EdgeColor', [1,0,0]);
        hold off;
    end   
end
hold off;

%===========================================================
% ROOTS DRAWING
%===========================================================
% draw roots (before nms)
roots = coords(1:4,:);
rootRects = roots' / imageScale;
rootRects(:,3) = rootRects(:,3) - rootRects(:,1) + 1;
rootRects(:,4) = rootRects(:,4) - rootRects(:,2) + 1;
figure(20); imshow(image, 'border', 'tight'); hold on;
for rectIdx = 1:size(rootRects, 1)
    rectangle('Position', rootRects(rectIdx,:), 'EdgeColor', GetColor(CDC, 2));
end
hold off;

% %==========================================
% % SCORE DISTRIBUTION
% %==========================================
% figure(30);
% for c = 1:numClusters
%     subplot(ceil(numClusters/4), 4, c);
%     hist(normScores{c});
% end

% %===========================================================
% % HEAD CLUSTERING
% %===========================================================
% % draw head clustering result
% headMap = zeros(imgH, imgW, 3);
% for clusterIdx = 1:numClusters
%     curHeads = cellCombinationCluster{clusterIdx};
%     for headIdx = 1:length(curHeads)
%         curCoords = round(listCParts(curHeads(headIdx)).coords / 2);
%         xRange = curCoords(1):curCoords(3);
%         yRange = curCoords(2):curCoords(4);
%         curColor = GetColor(CDC, clusterIdx);
%         headMap(yRange,xRange,1) = curColor(1);
%         headMap(yRange,xRange,2) = curColor(2);
%         headMap(yRange,xRange,3) = curColor(3);
%     end
% end
% figure(31); imshow(headMap, 'border', 'tight');
% % draw cluster label colors
% labelList = zeros(20, 20*numClusters, 3);
% preX = 0;
% for idx = 1:numClusters
%     x = preX+1:preX+20;
%     preX = max(x);
%     curColor = GetColor(CDC, idx);
%     labelList(:,x,1) = curColor(1);
%     labelList(:,x,2) = curColor(2);
%     labelList(:,x,3) = curColor(3);
% end
% figure(131); imshow(labelList, 'border', 'tight');

%===========================================================
% END-UP MESSAGE
%===========================================================
fprintf('=======================================\n');
timeEnd = clock;
fprintf(['PAPD ends at: ' ...
    datestr(datenum(0,0,0,timeEnd(4),timeEnd(5),timeEnd(6)),'HH:MM:SS') '\n']);
timeElapsed = timeEnd - timeStart;
fprintf(['Total elapsed time: ' datestr(datenum(...
    timeElapsed(1),timeElapsed(2),timeElapsed(3),timeElapsed(4),timeElapsed(5),timeElapsed(6)), ...
    'HH:MM:SS') '\n']);
fprintf('=======================================\n');
%()()
%('') HAANJU.YOO