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
addpath library;
addpath d:/gurobi605/win64/matlab % for Gurobi solver

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%% PARAMETER AND PRESET, INPUT
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

% mode
DO_BATCH_GEN_DETECTIONS = false;

% parameters
PART_NMS_OVERLAP = 0.3;
PART_OCC_OVERLAP = 0.8;
CLUSTER_OVERLAP = 0.1;

% load input frame
INPUT_FILE_NAME = 'img5';
image = imread(['data/' INPUT_FILE_NAME '.jpg']);
[imgH, imgW, imgC] = size(image);
imageScale = 2.0;

% load deformable part model
load model/INRIAPERSON_star.mat;

% load part detection results
load(['data/' INPUT_FILE_NAME '_part_candidates.mat']);
numComponent = length(unique(coords(end-1,:)));
[numPartTypes, numDetections] = size(partscores);
numPartTypes = numPartTypes - 1; % since the last row of partscores is "pyramidLevel"

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%% PART RESPONSE AND PRE-PROCESSING
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

%==========================================
% MAKE LISTCPARTS
%==========================================
fprintf('Make part list..');
numParts = 0;
listCParts = CPart.empty();
cellIndexAmongType = cell(numPartTypes, numComponent); % array positions of a specific part and component
partMap = zeros(imageScale * imgH, imageScale * imgW);
for componentIdx = 1:numComponent
    
    % get data of current component
    curComponentIdx = find(componentIdx == coords(end-1,:));
    curComponents = coords(:,curComponentIdx);
    curComponentScores = partscores(:,curComponentIdx);   
    
    typeOffset = 1;
    for typeIdx = 1:numPartTypes        
        % non-maximal suppression
        curCoords = curComponents(typeOffset:typeOffset+3,:);
        curScores = curComponentScores(typeIdx,:);
        numCurCandidates = size(curCoords, 2);
        
        % save candidates part into 'CPart' class instances
        curArrayIndex = [];
        for candidateIdx = 1 : numCurCandidates
            curScore = curComponentScores(typeIdx,candidateIdx);
            curCoord = curCoords(:,candidateIdx)';
            curPyraLevel =  curComponentScores(end, candidateIdx);
            curScale = 2 / ( 2 ^ ( 1 / model.interval ) )^(curPyraLevel-1);
            numParts = numParts + 1;
            curA2p = model.sbin / curScale;
            if 1 ~= typeIdx, curA2p = 0.5 * curA2p; end            
            listCParts(numParts) = ...
                CPart(componentIdx, typeIdx, curCoord, curScore, ...
                curPyraLevel, curScale, curA2p, ...
                curComponentIdx(candidateIdx));
            curArrayIndex = [curArrayIndex, numParts];
            
            imageRect = round(curCoord);
            partMap(imageRect(2):imageRect(4),imageRect(1):imageRect(3)) = 1.0;
        end    
        
        % save specific part positions locations in the array of class
        cellIndexAmongType{typeIdx,componentIdx} = curArrayIndex;
        
        typeOffset = typeOffset + 4;
    end
end
fprintf('done!\n');

%==========================================
% NON MAXIMAL SUPPRESSION WITH HEAD PART
%==========================================
pickedHeadRootIdx = [];
for componentIdx = 1:numComponent    
    % get data of current component
    curComponentIdx = find(componentIdx == coords(end-1,:));
    curComponents = coords(:,curComponentIdx);
    curComponentScores = partscores(:,curComponentIdx);      
    % head index = 2    
    typeIdx    = 2;
    typeOffset = 5;
    headCoords = curComponents(typeOffset:typeOffset+3,:);
    headScores = curComponentScores(typeIdx,:);    
    % nms
    nmsHeadIdx = curComponentIdx(nms2([headCoords; headScores]', PART_NMS_OVERLAP));
    pickedHeadRootIdx = [pickedHeadRootIdx; nmsHeadIdx'];    
    % 'pickedHeadRootIdx' means 'CPart.rootID'
end


%==========================================
% HEAD CLUSTERING
%==========================================
headIdxSet = [];
numComponent = size(cellIndexAmongType, 2);
for componentIdx = 1:numComponent
    curHeadCellIndex = cellIndexAmongType{2, componentIdx};
    curHeadCellRootID = [listCParts(curHeadCellIndex).rootID];
    isPicked = ismember(curHeadCellRootID, pickedHeadRootIdx);
    headIdxSet = [headIdxSet, curHeadCellIndex(0~=isPicked)];
end

fprintf('Head clustering..');
[cellHeadCluster, listSoleHeadCluster] = HeadClusteringNMS(...
    headIdxSet, listCParts, model, CLUSTER_OVERLAP, PART_NMS_OVERLAP);
numHeads = length(headIdxSet);
numCluster = length(cellHeadCluster);
fprintf('done!\n');
%----------------------------
% Not used any longer...
%----------------------------
% % select heads only in NMS-picked indices
% prevCellHeadCluster = cellHeadCluster;
% for clusterIdx = 1:numCluster
%     curHeadClusterIdx = cellHeadCluster{clusterIdx};
%     curHeadRootID = [listCParts(curHeadClusterIdx).rootID];
%     % select head indices whose root ids equal to pickedHeadIdx (nms results)
%     newHeadClusterIdx = curHeadClusterIdx((0~=ismember(curHeadRootID, pickedHeadRootIdx)));    
%     % store new head cluster indices
%     cellHeadCluster{clusterIdx} = newHeadClusterIdx;
% end




%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%% GENERATE DETECTIONS
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
if DO_BATCH_GEN_DETECTIONS
    load(['data/' INPUT_FILE_NAME '_detections_using_root.mat']);
else
    fprintf('Generate Detections..\n');
    tic;
    %==========================================
    % DETECTIONS FROM EACH CLUSTER
    %==========================================
    cellListDetections = cell(1, numCluster);
    fullBodyConfiguration = ones(1, numPartTypes); fullBodyConfiguration(1) = 0;
    for clusterIdx = 1:numCluster
        % head indices of the head cluster
        curHeadIdxs = cellHeadCluster{clusterIdx};
        curHeadComponents = [listCParts(curHeadIdxs).component];
        curHeadRootID = [listCParts(curHeadIdxs).rootID];
        % get combinations
        partsInCluster = [];
        for headIdx = curHeadIdxs
            curHeadIdxInCell = find([cellIndexAmongType{2,:}]==headIdx);
            curParts = [];
            % find full parts corresponding to current heads.
            for k = 1: size(cellIndexAmongType,1)
                curPartIdxs = [cellIndexAmongType{k,:}];
                curParts = [curParts, curPartIdxs(curHeadIdxInCell)];
            end
            partsInCluster = [partsInCluster; curParts];            
        end
        
        % generate Combinations and Detections
        fprintf('Cluster (%2d/%2d): ', clusterIdx, numCluster);
        cellListDetections{clusterIdx} = ...
            GenerateDetectionsFromFullParts(listCParts, partsInCluster, ...
            numPartTypes);
    end
    t_d = toc;
    fprintf(['>> elapsed time for generating detections: ' ...
        datestr(datenum(0,0,0,0,0,t_d),'HH:MM:SS') '\n']);

    tic;
    fprintf('>> saving detections...');
    save(['data/' INPUT_FILE_NAME '_detections_using_root.mat'], '-v6', ...
        'cellListDetections', 'listCParts', 'cellIndexAmongType', ...
        'cellHeadCluster', 'listSoleHeadCluster', 'headIdxSet');
    fprintf('done!!\n');
    t_s = toc;
    fprintf(['>> elapsed time for saving detections: ' ...
        datestr(datenum(0,0,0,0,0,t_s),'HH:MM:SS') '\n']);
end


%===========================================================
% RE-SCORING THE DETECTION WITH NORMALIZATION (-0.5 ~ 0.5)
%===========================================================
load(fullfile('model', 'ConfigurationScoreStats.mat'));
norm = norm{1};
scores = [];

% Run normalization
fprintf('Normalize the detection scores..');
for i = 1 : length(cellListDetections)        
    for j = 1 : length(cellListDetections{i})
        det = cellListDetections{i}(j);        
        % find det's configuration
        conf = zeros(size(det.combination));
        conf((0~=det.combination)) = 1;
        confStr = [];
        for k = 1 : length(conf)
            confStr = [confStr, num2str(conf(k))];
        end
        confStr(1:2) = []; % remove root and head flag (always 0 and 1)
        confVal = bin2dec(confStr)+1;
        
        maxVal = norm(confVal).max;
        minVal = norm(confVal).min;
        
        newScore = (det.score - minVal) / ( maxVal - minVal) - 0.5 ;
        cellListDetections{i}(j).score = newScore;
    end    
    scores = [scores, cellListDetections{i}.score];

end
fprintf('done!\n');
hist(scores);


%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%% OPTIMIZATION
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% solve MWCP with the graph
figure(12321); imshow(image, 'border', 'tight');
cellSolutions = cell(numCluster, 2); % {detection list}{objective value}
% for clusterIdx = 1:numCluster
for clusterIdx = 8
    cellSolutions(clusterIdx,:) = ...
        Optimization_Gurobi(cellListDetections{clusterIdx}, listCParts, model, ...
        PART_NMS_OVERLAP, PART_OCC_OVERLAP);
    for dIdx = 1:length(cellSolutions{clusterIdx,1})
        ShowDetection(cellSolutions{clusterIdx,1}(dIdx), listCParts, 0, 0.5, 12321);
    end
    pause;
end

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%% REFINEMENT
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%


%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%% VISUALIZATION
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
CDC = CDistinguishableColors();

%==========================================
% PART NMS DRAWING
%==========================================
% draw roots (before nms)
roots = coords(1:4,:);
rootRects = roots' / imageScale;
rootRects(:,3) = rootRects(:,3) - rootRects(:,1) + 1;
rootRects(:,4) = rootRects(:,4) - rootRects(:,2) + 1;
figure(1000); imshow(image, 'border', 'tight'); hold on;
for rectIdx = 1:size(rootRects, 1)
    rectangle('Position', rootRects(rectIdx,:), 'EdgeColor', GetColor(CDC, 2));
end
hold off;

% draw each parts
for typeIdx = 1:2
% for typeIdx = 1:numPartTypes
    curListCParts = CPart.empty();
    for componentIdx = 1:numComponent
        curListCParts = [curListCParts, listCParts(cellIndexAmongType{typeIdx,componentIdx})];
    end
    DrawPart(image, curListCParts, CDC, imageScale, typeIdx);
end

%==========================================
% HEAD CLUSTERING
%==========================================
% draw head clustering result
headMap = zeros(imgH, imgW, 3);
for clusterIdx = 1:numCluster
    curHeads = cellHeadCluster{clusterIdx};
    for headIdx = 1:length(curHeads)
        curCoords = round(listCParts(curHeads(headIdx)).coords / 2);
        xRange = curCoords(1):curCoords(3);
        yRange = curCoords(2):curCoords(4);
        curColor = GetColor(CDC, clusterIdx);
        headMap(yRange,xRange,1) = curColor(1);
        headMap(yRange,xRange,2) = curColor(2);
        headMap(yRange,xRange,3) = curColor(3);
    end
end
% for idx = 1:numHeads
%     curCoords = round(listCParts(headIdxSet(idx)).coords / 2);
%     xRange = curCoords(1):curCoords(3);
%     yRange = curCoords(2):curCoords(4);
%     curColor = GetColor(CDC, clusterLabels(idx));
%     headMap(yRange,xRange,1) = curColor(1);
%     headMap(yRange,xRange,2) = curColor(2);
%     headMap(yRange,xRange,3) = curColor(3);
% end
figure(100); imshow(headMap, 'border', 'tight');

% draw cluster label colors
labelList = zeros(20, 20*numCluster, 3);
preX = 0;
for idx = 1:numCluster
    x = preX+1:preX+20;
    preX = max(x);
    curColor = GetColor(CDC, idx);
    labelList(:,x,1) = curColor(1);
    labelList(:,x,2) = curColor(2);
    labelList(:,x,3) = curColor(3);
end
figure(200); imshow(labelList, 'border', 'tight');

% %==========================================
% % FULL-BODY COMBINATIONS
% %==========================================
% % draw full-body combinations (each part)
% figure(98);
% imshow(image, 'border', 'tight');
% hold on;
% BBs = [];
% for combIdx = 1:size(cellListDetections{curCellIdx},2)
%     curCombination = cellListDetections{curCellIdx}(combIdx).combination;
%     curPartBoxes = [];
%     if length(nonzeros(curCombination)) < 8, continue; end;
%     for typeIdx = 2:9
%         curBox = GetBox(listCParts(curCombination(typeIdx))) / imageScale;
%         rectangle('Position', curBox, 'EdgeColor', GetColor(CDC, typeIdx));
%         curPartBoxes = [curPartBoxes; curBox];
%     end
%     % Save bounding boxes of full body
%     %   should be modified when consider partial body.
%     BB = []; % [x y w h]
%     BB(1) = min(curPartBoxes(:,1));
%     BB(2) = min(curPartBoxes(:,2));
%     BB(3) = max(curPartBoxes(:,1) + curPartBoxes(:,3)) - BB(1);
%     BB(4) = max(curPartBoxes(:,2) + curPartBoxes(:,4)) - BB(2);
%     BBs = [BBs; BB]; 
% end
% hold off;
% 
% % draw full-body combinations (bounding box)
% figure(99);
% imshow(image, 'border', 'tight');
% hold on;
% for combIdx = 1:size(BBs,1)    
%     rectangle('Position', BBs(combIdx,:), 'EdgeColor', GetColor(CDC, 10));
% end
% hold off;

%()()
%('') HAANJU.YOO