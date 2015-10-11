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
configurations = zeros(numComponents*2^(numPartTypes-2), numPartTypes);
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
                    
                    % check occlusion prior
                    curListPartInfoIdx = curCombination(0 ~= curCombination);
                    curListPartInfo = listPartInfos(curListPartInfoIdx);
                    if bOcclusionPrior && CheckMissingWithoutOcclusion(...
                            curListPartInfo, model, occlusionMap, occlusionOverlapRatio);
                        continue;
                    end
                    
                    % save combination for propagation
                    newCombinationIdx = newCombinationIdx + 1;
                    newCombinations(newCombinationIdx,:) = curCombination;
                    newCombinations(newCombinationIdx,typeIdx) = partIdx;
                    
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

function bMissingWOOc = CheckMissingWithoutOcclusion(partList, model, occlusionMap, occlusionOverlapRatio)

bMissingWOOc = false;
if isempty(occlusionMap), return; end

numParts = length(partList);
CPHead = partList(1);
anchorHead = model.defs{1}.anchor;
pixelTo

for partIdx = 1:numParts
    
end

end

%()()
%('')HAANJU.YOO