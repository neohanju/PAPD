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

% init
papd_init;

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%% PARAMETER AND PRESET, INPUT
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

% parameters
PART_NMS_OVERLAP = 0.3;
PART_OCC_OVERLAP = 0.8;
CLUSTER_OVERLAP  = 0.1;

% load input frame
INPUT_FILE_NAME = 'img5';
image      = imread(['data/' INPUT_FILE_NAME '.jpg']);
imageScale = 2.0;
[imgH, imgW, imgC] = size(image);

% load deformable part model
load model/INRIAPERSON_star.mat;

% load part detection results
load(['data/' INPUT_FILE_NAME '_part_candidates.mat']);
[numPartTypes, numDetections] = size(partscores);
numPartTypes = numPartTypes - 1; % exclude "pyramidLevel"
numComponent = length(unique(coords(end-1,:)));

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%% PART RESPONSE AND PRE-PROCESSING
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
        curComponentIdx(nms2([headCoords; headScores]', PART_NMS_OVERLAP));
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
        curScale  = 2^(-(curPyramidLevel-1)/model.interval);
        curA2p    = model.sbin / curScale;        
        curScore  = partscores(1:end-1,rootIdx);             
        typeOffset = 1;
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
%     for typeIdx = 1:numPartTypes
%         % get component infos
%         curCoords = curComponents(typeOffset:typeOffset+3,:);
%         curScores = curComponentScores(typeIdx,:);
%         numCurCandidates = size(curCoords, 2);
%         curArrayIndex    = zeros(1, numCurCandidates);        
%         for candidateIdx = 1 : numCurCandidates            
%             % get part infos
%             curPyraLevel = curComponentScores(end,candidateIdx);
%             curScore     = curComponentScores(typeIdx,candidateIdx);
%             curCoord     = curCoords(:,candidateIdx)';
%             curScale     = 2 / ( 2 ^ ( 1 / model.interval ) )^(curPyraLevel-1);
%             
%             if 1 ~= typeIdx, curA2p = 0.5 * curA2p; end            
%             % save candidates part into 'CPart' class instances
%             numParts = numParts + 1;
%             listCParts(numParts) = ...
%                 CPart(componentIdx, typeIdx, curCoord, curScore, ...
%                 curPyraLevel, curScale, curA2p, ...
%                 curComponentIdx(candidateIdx));            
%             % save index            
%             curArrayIndex(candidateIdx) = numParts;
%             % occlusion prior
%             imageRect = round(curCoord);
%             partMap(imageRect(2):imageRect(4),imageRect(1):imageRect(3)) = 1.0;
%         end        
%         % save specific part positions locations in the array of class
%         cellIndexAmongType{typeIdx,componentIdx} = curArrayIndex;
%         
%         typeOffset = typeOffset + 4;
%     end
end
fprintf('done!\n');

%==========================================
% HEAD CLUSTERING
%==========================================
fprintf('Head clustering...');
[cellHeadCluster, listSoleHeadCluster, headIdxSet] = HeadClustering(...
    listCParts, cellIndexAmongType, model, CLUSTER_OVERLAP, PART_NMS_OVERLAP);
numHeads = length(headIdxSet);
numCluster = length(cellHeadCluster);
fprintf('done!\n');


%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%% GENERATE DETECTIONS
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

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
fprintf(['elapsed time for generating detections: ' ...
    datestr(datenum(0,0,0,0,0,t_d),'HH:MM:SS') '\n']);


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