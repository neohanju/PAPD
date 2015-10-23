function  [cellListDetections] = GenerateDetections(listCParts, cellHeadCluster, listSoleHeadCluster)

numCluster = length(cellHeadCluster);
rootIDs = [listCParts.rootID];
cellFullbodyCombination = cell(numCluster, 1);
for clusterIdx = 1:numCluster
    % head indices of the head cluster
    curHeadIdxs = cellHeadCluster{clusterIdx};
    curHeadRootID = [listCParts(curHeadIdxs).rootID];
    for headIdx = 1:length(curHeadIdxs)
        partsWithCurHead = 
    end
    
    
    
    curHeadComponent = [listCParts(curHeadIdxs).component];    
    
    curNumDetections = length(curHeadRootID);
    
    %==========================================
    % SINGLE HEAD CLUSTER
    %==========================================
    if listSoleHeadCluster(clusterIdx)
        maxCombinationScore = 0.0;
        maxCombinationIdx = 0;
        for curDetIdx = 1 : curNumDetections
            curPartsIdxs = partsIndices(curDetIdx,:);
            curListPartInfo = listPartInfos(curPartsIdxs);
            curScore = sum([curListPartInfo.score]);
            if curScore < maxCombinationScore
                continue;
            end
            maxCombinationScore = curScore;
            maxCombinationIdx = curDetIdx;        
        end

        if 0 == maxCombinationIdx, return; end
        maxCombination = partsIndices(maxCombinationIdx,:);
        listDetections(1) = CDetection(maxCombination, maxCombinationScore);
        return;
    end
    
end

numDetections = size(partsIndices, 1);
listDetections = CDetection.empty();

if bSoleHead
end


%==========================================
% CONFIGURATIONS
%==========================================
% (head 반드시 포함되게 할 것, root는 고려하지 않을 것)
configurations = zeros(2^(numPartTypes-2), numPartTypes);
for cIdx = 1:size(configurations, 1)
    flags = ['01', dec2bin(cIdx-1, numPartTypes-2)];
    for typeIdx = 1:numPartTypes
        configurations(cIdx,typeIdx) = str2double(flags(typeIdx));
    end
end
numConfiguration = size(configurations, 1);

%==========================================
% COMBINATIONS
%==========================================
combinations = [];
for curDetIdx = 1 : numDetections
    curPartsIdxs = partsIndices(curDetIdx,:);                  %   1 x 9
    curPartsIdxs = repmat(curPartsIdxs, numConfiguration, 1);  % 128 x 9
    % element-wise multiplication 
    combinations = [combinations; configurations .* curPartsIdxs];    
end

%==========================================
% COMBINATIONS -> DETECTIONS
%==========================================
numCombinations = size(combinations, 1);
fprintf('total %d sets are made\n', numCombinations);
for cIdx = 1:numCombinations
    curCombination = combinations(cIdx,:);    
    curListPartInfo = listPartInfos(curCombination(0 ~= curCombination));
    curScore = sum([curListPartInfo.score]);
    listDetections(cIdx) = CDetection(curCombination, curScore);
end
end