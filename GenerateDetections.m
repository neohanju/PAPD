function [listDetections] = GenerateDetections(listPartInfos, cellIndexAmongType, model, occlusionMap, occlusionOverlapRatio)

if nargin < 5, occlusionOverlapRatio = 0.8; end
if nargin < 4
    bOcclusionPrior = false;
    occlusionMap = [];
else
    bOcclusionPrior = true; 
end

[numPartTypes, numComponents] = size(cellIndexAmongType);
numDetection = 0;
listDetections = CDetection.empty();

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
                    
                    % check compatibility between parts
                    bIsCompatible = true;
                    for preInsertedPartIdx = curCombination                                    
                        if 0 == preInsertedPartIdx, continue; end
                        bIsCompatible = IsAssociable(...
                            listPartInfos(preInsertedPartIdx), listPartInfos(partIdx), model);
                        if ~bIsCompatible, break; end
                    end                                
                    if ~bIsCompatible, continue; end                    
                    newCombination = curCombination;
                    newCombination(typeIdx) = partIdx;
                    
                    % check occlusion prior
                    curListPartInfoIdx = newCombination(0 ~= newCombination);
                    curListPartInfo = listPartInfos(curListPartInfoIdx);
                    if bOcclusionPrior && ~CheckPartOcclusion(...
                            curListPartInfo, model, occlusionMap, occlusionOverlapRatio);
                        continue;
                    end
                    
                    % save combination for propagation
                    newCombinationIdx = newCombinationIdx + 1;
                    newCombinations(newCombinationIdx,:) = newCombination;
                    
                    % save combination as a detection
                    numDetection = numDetection + 1;
                    listDetections(numDetection) = CDetection(curCombination, curListPartInfo, 0.0);
                end
            end                    
            combinationsInCurConfiguration = newCombinations(1:newCombinationIdx, :);
        end
        fprintf('%d sets are made\n', size(combinationsInCurConfiguration, 1));
        combinations = [combinations; combinationsInCurConfiguration];
    end

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