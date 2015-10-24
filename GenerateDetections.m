function  [cellListDetections] = GenerateDetections(listCParts, cellCombinationCluster)

%==========================================
% CONFIGURATIONS
%==========================================
% (head 반드시 포함되게 할 것, head로부터 configuration 내 모든 part로 path 존재하게끔)
% part adjacency matrix
Ap = [0 0 0 0 0 0 0 0 0; %     2
      0 0 0 1 0 1 0 0 0; %  4     6
      0 0 0 0 1 0 0 1 1; %  7     8
      0 1 0 0 0 1 1 0 0; %     5
      0 0 1 0 0 0 1 1 1; %   9   3
      0 1 0 1 0 0 0 1 0; 
      0 0 0 1 1 0 0 0 1; 
      0 0 1 0 1 1 0 0 0;
      0 0 1 0 1 0 1 0 0];
numPartTypes = size(Ap, 1);
configurations = zeros(2^(numPartTypes-2), numPartTypes);
numConfigurations = 0;
for cIdx = 1:size(configurations, 1)
    curBinaryString = ['11', dec2bin(cIdx-1, numPartTypes-2)];
    curConfiguration = zeros(1, numPartTypes);
    for typeIdx = 1:numPartTypes
        curConfiguration(typeIdx) = str2double(curBinaryString(typeIdx));
    end
    % check connectivity (except root and head)
    if ~CheckConnectivity(2, curConfiguration, Ap, [1, 2]), continue; end
    numConfigurations = numConfigurations + 1;
    configurations(numConfigurations,:) = curConfiguration;
end
configurations = configurations(1:numConfigurations,:);

%==========================================
% COMBINATIONS
%==========================================
numCluster = length(cellCombinationCluster);
cellListDetections = cell(numCluster, 1);
for clusterIdx = 1:numCluster
    curClusterCombinations = cellCombinationCluster{clusterIdx};
    numCurCombinations = size(curClusterCombinations, 1);
    cellListDetections{clusterIdx} = CDetection.empty();
    numCurClusterDetections = 0;
    for cIdx = 1:numCurCombinations
        curCombination = curClusterCombinations(cIdx,:);                     % dim: 1x9
        repmatCurCombination = repmat(curCombination, numConfigurations, 1); % dim: 128x9
        % element-wise multiplication 
        generatedCombinations = [configurations .* repmatCurCombination];
        % make CDetection instance
        for dIdx = 1:numConfigurations
            curGeneratedCombination = generatedCombinations(dIdx,:);
            curListCParts = ...
                listCParts(curGeneratedCombination(0 ~= curGeneratedCombination));
            curScore = sum([curListCParts.score]);
            numCurClusterDetections = numCurClusterDetections + 1;
            cellListDetections{clusterIdx}(numCurClusterDetections) = ...
                CDetection(curGeneratedCombination, curScore);
        end
    end 
%     %==========================================
%     % SINGLE HEAD CLUSTER
%     %==========================================
%     if listSoleHeadCluster(clusterIdx)
%         % find and save only the combination which has the maximum score
%         maxCombinationScore = 0.0;
%         maxCombinationIdx = 0;
%         for cIdx = 1:size(curClusterCombinations, 1)
%             curCombination = curClusterCombinations(cIdx,:);
%             curCParts = listCParts(curCombination);
%             curScore = sum([curCParts.score]);
%             if curScore < maxCombinationScore
%                 continue;
%             end
%             maxCombinationScore = curScore;
%             maxCombinationIdx = cIdx;        
%         end
%         if 0 == maxCombinationIdx, continue; end
%         maxCombination = curClusterCombinations(cIdx,:);
%         cellListDetections{clusterIdx}(1) = CDetection(maxCombination, maxCombinationScore);
%         continue;
%     end
end
end