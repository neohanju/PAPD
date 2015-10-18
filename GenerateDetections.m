function [listDetections] = GenerateDetections(listPartInfos, ...
    cellIndexAmongType, model, occlusionMap, occlusionOverlapRatio, ...
    configurations)

[numPartTypes, numComponents] = size(cellIndexAmongType);
if nargin < 6
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
end
if nargin < 5, occlusionOverlapRatio = 0.8; end
if nargin < 4
    bOcclusionPrior = false;
    occlusionMap = [];
else
    bOcclusionPrior = true; 
end

%==========================================
% COMBINATIONS
%==========================================
% (apart from configuration generation for the combinience of the code readability)
combinations = [];
for componentIdx = 1:numComponents
    fprintf('Component: %d/%d\n', componentIdx, numComponents);
    for cIdx = 1:size(configurations, 1)
        fprintf('Configuration: %d/%d:...', cIdx, size(configurations, 1));
        combinationsInCurConfiguration = zeros(1, numPartTypes);

        for typeIdx = 1:numPartTypes
            % bit check                        
            if 0 == configurations(cIdx,typeIdx), continue; end

            % generate new combinations with boxes of the current part type
            numNewCombinations = size(combinationsInCurConfiguration, 1)...
                *length(cellIndexAmongType{typeIdx,componentIdx});
            newCombinations = zeros(numNewCombinations, numPartTypes);
            newCombinationIdx = 0;    

            for combIdx = 1:size(combinationsInCurConfiguration, 1)
                curCombination = combinationsInCurConfiguration(combIdx,:);
                for partIdx = cellIndexAmongType{typeIdx,componentIdx}
                    % check associability between inserted and candidate parts
                    bAssociable = true;
                    for preInsertedPartIdx = curCombination                                    
                        if 0 == preInsertedPartIdx, continue; end
                        bAssociable = IsAssociable(...
                            listPartInfos(preInsertedPartIdx), listPartInfos(partIdx), model);
                        if ~bAssociable, break; end
                    end                                
                    if ~bAssociable, continue; end
                    
                    % check occlusion prior
                    newCombination = curCombination;
                    newCombination(typeIdx) = partIdx;
                    curListPartInfoIdx = newCombination(0 ~= newCombination);
                    curListPartInfo = listPartInfos(curListPartInfoIdx);
                    if bOcclusionPrior && ~CheckPartOcclusion(...
                            curListPartInfo, model, occlusionMap, occlusionOverlapRatio);
                        continue;
                    end
                    
                    % save combination for propagation
                    newCombinationIdx = newCombinationIdx + 1;
                    newCombinations(newCombinationIdx,:) = newCombination;
                end
            end                    
            combinationsInCurConfiguration = newCombinations(1:newCombinationIdx, :);
        end
        fprintf('%d sets are made\n', size(combinationsInCurConfiguration, 1));
        combinations = [combinations; combinationsInCurConfiguration];
    end
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

function bPartOccluded = CheckPartOcclusion(partList, model, occlusionMap, occlusionOverlapRatio)

bPartOccluded = true;
% input check
if isempty(occlusionMap), return; end

% anchor to pixel dimension
anchorHead = model.defs{1}.anchor;
anchorW = 6;
anchorH = 6;
partW = round(partList(1).a2p * anchorW);
partH = round(partList(1).a2p * anchorH);
partArea = partW * partH;
headPos = partList(1).coords(1:2);

% get missing part info
currentParts = [partList.type];
missingParts = 1:9; missingParts(currentParts) = []; missingParts(1) = [];

% occlusion check
for typeIdx = missingParts
    curAnchor =  model.defs{typeIdx-1}.anchor;
    vecPixelDiff = partList(1).a2p * (curAnchor - anchorHead);
    candidatePos = round(headPos + vecPixelDiff);
    occludedArea = sum(sum(occlusionMap(...
        candidatePos(2):candidatePos(2)+partH-1,...
        candidatePos(1):candidatePos(1)+partW-1)));
    if occlusionOverlapRatio > occludedArea / partArea
        bPartOccluded = false;
        return;
    end
end

end

%()()
%('')HAANJU.YOO