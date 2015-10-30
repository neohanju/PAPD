function [bboxs, pboxs, solutionDeteils, listCParts]...
    = PAPD(image, partDetections, model, ...
    rootMaxOverlap, headMaxOverlap, partMaxOverlap, partOccOverlap, ...
    classifiers, normalizationInfos, ...
    solverTimeLimit)
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

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%% PARAMETER AND PRESET, INPUT
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
[imgH, imgW, ~] = size(image);

% load part detection results
partscores = partDetections.partscores;
coords     = partDetections.coords;
partScale  = partDetections.scale;
[numPartTypes, ~] = size(partscores);
numPartTypes      = numPartTypes - 1; % exclude "pyramidLevel"
numComponent      = length(unique(coords(end-1,:)));

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
        curComponentIdx(nms2([headCoords; headScores]', headMaxOverlap));
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
partMap = zeros(partScale * imgH, partScale * imgW);
% generate CPart instances
for componentIdx = 1:numComponent
    for rootIdx = pickedIdx{componentIdx}              
        curPyramidLevel = partscores(end,rootIdx);
        % note that scale and a2p are fit to root scale
        curScale   = 2^(-(curPyramidLevel-1)/model.interval);
        curA2p     = model.sbin / curScale;        
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
            partMap(max(1,imageRect(2)): min(size(partMap, 1), imageRect(4)),...
                max(1,imageRect(1)): min(size(partMap, 2), imageRect(3))) = 1.0;
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
cellListDetections = GenerateDetections(listCParts, cellCombinationCluster, partOccOverlap);
t_d = toc;
fprintf(['done! ' datestr(datenum(0,0,0,0,0,t_d),'HH:MM:SS') ' elapsed\n']);

%==========================================
% CLASSIFY DETECTIONS
%==========================================
% SVM
cellListDetections = ClassifyDetetions_SVM(cellListDetections, classifiers);

%==========================================
% NORMALIZE SCORES
%==========================================
% score normalization (mean - 3 std ~ mean + 3 std -> 0 to 1)
fprintf('score normalization...');
for clusterIdx = 1:numClusters
    for dIdx = 1:length(cellListDetections{clusterIdx})        
        curTotalScore  = cellListDetections{clusterIdx}(dIdx).score;
        curFullScores  = cellListDetections{clusterIdx}(dIdx).fullScores;
        % configuration
        curCombination = cellListDetections{clusterIdx}(dIdx).combination;
        scoreIdx = find(0 < curCombination); 
        scoreIdx(1 == scoreIdx) = []; % except root
        curConfigurationString = repmat('0', 1, numPartTypes);
        curConfigurationString(scoreIdx) = '1';        
        configurationIdx = bin2dec(curConfigurationString(3:end))+1; % except head and root       
        % subtract root filter response
        curTotalScore = curTotalScore - curFullScores(1); 
        newScore = (curTotalScore - normalizationInfos.positiveScoreMean(configurationIdx)) ...
            / (6*normalizationInfos.positiveScoreStd(configurationIdx)) + 0.5;        
        newScore = newScore + curFullScores(1);
        % add root filter response
        cellListDetections{clusterIdx}(dIdx).normalizedScore = newScore;
    end
end
fprintf('done!\n');

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%% OPTIMIZATION
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% solve MWCP with the graph
cellSolutions = cell(numClusters, 3); % {detection list}{detection index}{objective value}
sizeSolution = 0;
for clusterIdx = 1:numClusters
    fprintf('----- Optimize cluster %03d/%03d -----\n', clusterIdx, numClusters);
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
            cellSolutions{clusterIdx,2} = maxIdx;
            cellSolutions{clusterIdx,3} = maxScore;            
        end
    else
        % optimize to associate parts
        cellSolutions(clusterIdx,:) = Optimization_Gurobi( ...
            cellListDetections{clusterIdx}, ...
            listCParts, ...
            model, ...
            rootMaxOverlap, partMaxOverlap, partOccOverlap, ...
            solverTimeLimit);        
    end    
    sizeSolution = sizeSolution + length(cellSolutions{clusterIdx,2});
end


%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%% RESULT PACKAGING
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

solutionDeteils.clusterCombinations = cellCombinationCluster;
solutionDeteils.clusterDetections = cellListDetections;
solutionDeteils.clusterSolutions = cellSolutions;
solutionDeteils.singleHeadCluster = listSingleHeadCluster;

%==========================================
% BBOXS and PBOXS
%==========================================
bboxs = zeros(sizeSolution, 6);   % [x,y,w,h,score,normalized score]
pboxs = zeros(sizeSolution, 5, numPartTypes); % [x,y,w,h,part score]
boxIdx = 0;
for clusterIdx = 1:numClusters
    for dIdx = 1:length(cellSolutions{clusterIdx,1})        
        curDetection = cellSolutions{clusterIdx,1}(dIdx);
        curRoot = GetBox(listCParts(curDetection.combination(1)))/partScale;        
        % bbox
        boxIdx = boxIdx + 1;
        bboxs(boxIdx,1:4) = curRoot;
        bboxs(boxIdx,5)   = curDetection.score;
        bboxs(boxIdx,6)   = curDetection.normalizedScore;
        % pbox        
        curParts = curDetection.combination(0 < curDetection.combination);
        for pIdx = curParts
            pboxs(boxIdx,1:4,pIdx) = GetBox(listCParts(pIdx))/partScale;
            pboxs(boxIdx,5,pIdx)   = listCParts(pIdx).score;
        end
    end
end

%()()
%('') HAANJU.YOO