function [listDetections] = GenerateDetections(listPartInfos, cellIndexAmongType, model)

[numPartTypes, numComponents] = size(cellIndexAmongType);

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

                    % save combination
                    newCombinationIdx = newCombinationIdx + 1;
                    newCombinations(newCombinationIdx,:) = curCombination;
                    newCombinations(newCombinationIdx,typeIdx) = partIdx;
                end
            end                    
            combinationsInCurConfiguration = newCombinations(1:newCombinationIdx, :);
        end
        fprintf('%d sets are made\n', size(combinationsInCurConfiguration, 1));
        combinations = [combinations; combinationsInCurConfiguration];
    end

end

%==========================================
% RESULT PACKAGING
%==========================================
numCombinations = size(combinations, 1);
listDetections = CDetections.empty();
for cIdx = 1:numCombinations
    curListPartInfoIdx = combinations(cIdx,:);                
    curListPartInfoIdx = curListPartInfoIdx(0 ~= curListPartInfoIdx);
    curListPartInfo = listPartInfos(curListPartInfoIdx);                
    listDetections(cIdx) = CDetection(combinations(cIdx,:), curListPartInfo, 0.0);
end

end

%()()
%('')HAANJU.YOO