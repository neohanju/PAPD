function  [listDetections] = GenerateDetectionsFromFullParts(...
    listPartInfos, partsIndices, numPartTypes, bSoleHead)

if nargin < 4, bSoleHead = false; end

numDetections = size(partsIndices, 1);
listDetections = CDetection.empty();
%==========================================
% SINGLE HEAD CLUSTER
%==========================================
if bSoleHead
    maxCombinationScore = 0.0;
    maxCombinationIdx = 0;
    for curDetIdx = 1 : numDetections
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