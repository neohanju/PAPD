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
addpath c:/gurobi605/win64/matlab % for Gurobi solver

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%% PARAMETER AND PRESET, INPUT
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

% mode
DO_BATCH_GEN_DETECTIONS = true;

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
        pickedIdx = nms2([curCoords; curScores]', PART_NMS_OVERLAP);
        
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
            listCParts(numParts) = ...
                CPart(componentIdx, typeIdx, curCoord, curScore, curPyraLevel, curScale, curA2p);
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
[cellHeadCluster, listSoleHeadCluster, headIdxSet] = HeadClustering(...
    listCParts, cellIndexAmongType, model, CLUSTER_OVERLAP, PART_NMS_OVERLAP);
numHeads = length(headIdxSet);
numCluster = length(cellHeadCluster);

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%% GENERATE DETECTIONS
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

if DO_BATCH_GEN_DETECTIONS
    load(['data/' INPUT_FILE_NAME '_detections.mat']);
else
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
        if listSoleHeadCluster(clusterIdx)
            cellListDetections{clusterIdx} = GenerateDetections(...
                listCParts, curCellIndexAmongType, model, partMap, PART_OCC_OVERLAP, ...
                fullBodyConfiguration);
        else
            cellListDetections{clusterIdx} = GenerateDetections(...
                listCParts, curCellIndexAmongType, model, partMap, PART_OCC_OVERLAP);    
        end    
    end
    t_d = toc;
    fprintf(['>> elapsed time for generating detections: ' ...
        datestr(datenum(0,0,0,0,0,t_d),'HH:MM:SS') '\n']);

    tic;
    fprintf('>> saving detections...');
    save(['data/' INPUT_FILE_NAME '_detections.mat'], '-v6', ...
        'cellListDetections', 'listCParts', 'cellIndexAmongType', ...
        'cellHeadCluster', 'listSoleHeadCluster', 'headIdxSet');
    fprintf('done!!\n');
    t_s = toc;
    fprintf(['>> elapsed time for generating detections: ' ...
        datestr(datenum(0,0,0,0,0,t_s),'HH:MM:SS') '\n']);
end

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