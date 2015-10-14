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

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%% PARAMETER AND PRESET, INPUT
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

% parameters
PART_NMX_OVERLAP = 0.3;
PART_OCC_OVERLAP = 0.8;
CLUSTER_OVERLAP = 0.1;

% input
image = imread('data/frame_0062.jpg');
[imgH, imgW, imgC] = size(image);
imageScale = 2.0;


%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%% PART RESPONSE AND PRE-PROCESSING
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
load data/part_candidates.mat;
load model/INRIAPERSON_star.mat; % Load DPM model
numComponent = length(unique(coords(end-1,:)));
[numPartTypes, numDetections] = size(partscores);
numPartTypes = numPartTypes - 1; % since the last row of partscores is "pyramidLevel"

%==========================================
% NON-MAXIMAL SUPPRESSION WITH EACH PART
%==========================================
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
        pickedIdx = nms2([curCoords; curScores]', PART_NMX_OVERLAP);
        
        % save candidates part into 'CPart' class instances
        curArrayIndex = [];
        for candidateIdx = pickedIdx'
            curScore = curComponentScores(typeIdx,candidateIdx);
            curCoord = curCoords(:,candidateIdx)';
            curPyraLevel =  curComponentScores(end, candidateIdx);
            curScale = 2 / ( 2 ^ ( 1 / model.interval ) )^(curPyraLevel-1);            
            numParts = numParts + 1;
            curA2p = model.sbin / curScale;
            if 1 ~= typeIdx, curA2p = 0.5 * curA2p; end
            listCParts(numParts) = CPart(componentIdx, typeIdx, curCoord, curScore, curPyraLevel, curScale, curA2p);
            curArrayIndex = [curArrayIndex, numParts];
            
            imageRect = round(curCoord);
            partMap(imageRect(2):imageRect(4),imageRect(1):imageRect(3)) = 1.0;
        end
        
        % save specific part positions locations in the array of class
        cellIndexAmongType{typeIdx,componentIdx} = curArrayIndex;
        
        typeOffset = typeOffset + 4;
    end
end

%==========================================
% HEAD CLUSTERING
%==========================================
headIdxSet = [];
for componentIdx = 1:numComponent
    headIdxSet = [headIdxSet, cellIndexAmongType{2, componentIdx}];
end
numHeads = length(headIdxSet);
clusterLabels = zeros(1, numHeads);

nextLabel = 1;
for head1Idx = 1:numHeads
    curLabel = clusterLabels(head1Idx);
    if 0 == curLabel
        curLabel = nextLabel;
        clusterLabels(head1Idx) = curLabel;
        nextLabel = nextLabel + 1;
    end
    
    for head2Idx = head1Idx+1:numHeads
        if curLabel == clusterLabels(head2Idx), continue; end
        
        % check adjacency
        if ~IsNeighbor(listCParts(headIdxSet(head1Idx)), ...
                listCParts(headIdxSet(head2Idx)), model, CLUSTER_OVERLAP, image)
            continue;
        end
        if 0 == clusterLabels(head2Idx)
            clusterLabels(head2Idx) = curLabel;
            continue;
        end
        
        % label update
        if curLabel < clusterLabels(head2Idx)
            clusterLabels(clusterLabels == clusterLabels(head2Idx)) = curLabel;
        else
            clusterLabels(clusterLabels == curLabel) = clusterLabels(head2Idx);
            curLabel = clusterLabels(head2Idx);
        end
    end
end

% label refresh
[clusterLabels, sortedIdx] = sort(clusterLabels, 'ascend');
headIdxSet = headIdxSet(sortedIdx);
uniqueLabels = unique(clusterLabels);
numCluster = length(uniqueLabels);
for labelIdx = 1:numCluster
    clusterLabels(clusterLabels == uniqueLabels(labelIdx)) = labelIdx;
end
uniqueLabels = unique(clusterLabels);

% cluster collecting
cellHeadCluster = cell(1, numCluster);
for labelIdx = 1:numCluster
    cellHeadCluster{labelIdx} = headIdxSet(clusterLabels == uniqueLabels(labelIdx));
end

%==========================================
% SOLE HEAD PICK
%==========================================
clusterSoleHead = false(1, numCluster);
for clusterIdx = 1:numCluster
    curHeadIdxs = headIdxSet(uniqueLabels(clusterIdx) == clusterLabels);
    numCurHeads = length(curHeadIdxs);
    
    % heads of same components, or non-overlapped heads -> not sole head cluseter
    bSoleHead = true;
    for head1Idx = 1:numCurHeads-1
        curHead1Idx = headIdxSet(head1Idx);
        for head2Idx = head1Idx+1:numCurHeads
            curHead2Idx = headIdxSet(head2Idx);
            if listCParts(curHead1Idx).component == listCParts(curHead2Idx).component ...
                || ~CheckOverlap(listCParts(curHead1Idx).coords, listCParts(curHead2Idx).coords, PART_NMX_OVERLAP)
                bSoleHead = false;
                break;
            end
        end
        if ~bSoleHead, break; end
    end    
    clusterSoleHead(clusterIdx) = bSoleHead;
end


%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%% GENERATE DETECTIONS
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

tic;
%==========================================
% DETECTIONS FROM EACH CLUSTER
%==========================================
cellListDetections = cell(1, numCluster);
fullBodyConfiguration = ones(1, numPartTypes); fullBodyConfiguration(1) = 0;
for clusterIdx = 1:numCluster
    curCellIndexAmongType = cellIndexAmongType;
    curHeadIdx = cellHeadCluster{clusterIdx};
    curHeadComponents = [listCParts(curHeadIdx).component];
    for componentIdx = 1:numComponent
        curCellIndexAmongType{2,componentIdx} = curHeadIdx(componentIdx == curHeadComponents);
    end
    if clusterSoleHead(clusterIdx)
        cellListDetections{clusterIdx} = GenerateDetections(...
            listCParts, curCellIndexAmongType, model, partMap, PART_OCC_OVERLAP, fullBodyConfiguration);
    else
        cellListDetections{clusterIdx} = GenerateDetections(...
            listCParts, curCellIndexAmongType, model, partMap, PART_OCC_OVERLAP);    
    end    
end
t_d = toc

tic;
fprintf('>> saving detections...');
save('data/detections.mat', 'cellListDetections');
fprintf('done!!\n');
t_s = toc

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%% OPTIMIZATION
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% solve MWCP with the graph

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%% REFINEMENT
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%


%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%% VISUALIZATION
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
CDC = CDistinguishableColors();

% roots = coords(1:4,:);
% rootRects = roots' / imageScale;
% rootRects(:,3) = rootRects(:,3) - rootRects(:,1) + 1;
% rootRects(:,4) = rootRects(:,4) - rootRects(:,2) + 1;
% figure; imshow(image, 'border', 'tight'); hold on;
% for rectIdx = 1:size(rootRects, 1)
%     rectangle('Position', rootRects(rectIdx,:), 'EdgeColor', GetColor(CDC, 2));
% end
% hold off;

headMap = zeros(imgH, imgW, 3);
for idx = 1:numHeads
    curCoords = round(listCParts(headIdxSet(idx)).coords / 2);
    xRange = curCoords(1):curCoords(3);
    yRange = curCoords(2):curCoords(4);
    curColor = GetColor(CDC, clusterLabels(idx));
    headMap(yRange,xRange,1) = curColor(1);
    headMap(yRange,xRange,2) = curColor(2);
    headMap(yRange,xRange,3) = curColor(3);
end
figure(1); imshow(headMap, 'border', 'tight');

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
figure(2); imshow(labelList, 'border', 'tight');

% for typeIdx = 1:numPartTypes
%     curListCParts = CPart.empty();
%     for componentIdx = 2
% %     for componentIdx = 1:numComponent
%         curListCParts = [curListCParts, listCParts(cellIndexAmongType{typeIdx,componentIdx})];
%     end
%     DrawPart(image, curListCParts, CDC, imageScale, typeIdx);
% end

% numPartsInCombination = zeros(size(combinations, 1), 1);
% for combIdx = 1:size(combinations,1)
%     curCombination = combinations(combIdx,:);
%     numPartsInCombination(combIdx) = numel(curCombination(curCombination ~= 0));
% end
% 
% fullPartCombination = combinations(8 == numPartsInCombination,:);
% % draw all parts of the combination results 
% figure(100);
% imshow(image, 'border', 'tight');
% hold on;
% BBs = [];
% for combIdx = 1:size(fullPartCombination,1)
%     curCombination = fullPartCombination(combIdx,:);
%     curPartBoxes = [];
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
% % draw bounding boxes of the combination results
% figure(101);
% imshow(image, 'border', 'tight');
% hold on;
% for combIdx = 1:size(fullPartCombination,1)
%     rectangle('Position', BBs(combIdx,:), 'EdgeColor', GetColor(CDC, 10));
% end
% hold off;

%()()
%('') HAANJU.YOO