function  [listDetections] = GenerateDetectionsFromFullParts(listPartInfos, ...
    partsIndices, numPartTypes)
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


numDetections = size(partsIndices, 1);
numConfiguration = size(configurations, 1);

%==========================================
% COMBINATIONS
%==========================================
combinations = [];
for curDetIdx = 1 : numDetections
    curPartsIdxs = partsIndices(curDetIdx, :);                 %   1 x 9
    curPartsIdxs = repmat( curPartsIdxs, numConfiguration, 1); % 128 x 9
    % element-wise multiplication 
    combinations = [combinations; configurations .* curPartsIdxs];    
end

%==========================================
% COMBINATIONS -> DETECTIONS
%==========================================
listDetections = CDetection.empty();
numCombinations = size(combinations, 1);
fprintf('>> total %d sets are made\n', numCombinations);
for cIdx = 1:numCombinations
    curCombination = combinations(cIdx,:);    
    curListPartInfo = listPartInfos(curCombination(0 ~= curCombination));
    curScore = sum([curListPartInfo.score]);
    listDetections(cIdx) = CDetection(curCombination, curScore);
end
end