function [cellCombinationCluster, listSingleHeadCluster] = ...
    HeadClustering(FullbodyCombinations, listCParts)
% <description>
% - clustering heads with connectivity by parts overlap
% <input>
% - FullbodyCombinations: index combinations among full bodies
% - listCParts: list of part class instances
% - model: deformable part model
% - clusterOverlapRatio: cluster merging criteria
% - partOverlapRatio: single head cluster decision criteria
% <output>
% - cellHeadCluster: set of head indices of each cluster
% - listSoleHeadCluster: flags indicate whether the cluster contains sole head
% - headIdxSet: head indices
% .__                           __.
%   \ `\~~---..---~~~~~~--.---~~| /   
%    `~-.   `                   .~         _____ 
%        ~.                .--~~    .---~~~    /
%         / .-.      .-.      |  <~~        __/
%        |  |_|      |_|       \  \     .--'
%       /-.      -       .-.    |  \_   \_
%       \-'   -..-..-    `-'    |    \__  \_ 
%        `.                     |     _/  _/
%          ~-                .,-\   _/  _/
%         /                 -~~~~\ /_  /_
%        |               /   |    \  \_  \_ 
%        |   /          /   /      | _/  _/
%        |  |          |   /    .,-|/  _/ 
%        )__/           \_/    -~~~| _/
%          \                      /  \
%           |           |        /_---` 
%           \    .______|      ./
%           (   /        \    /
%           `--'          /__/

%==========================================
% HEAD CLUSTERING
%==========================================
numHeads = size(FullbodyCombinations, 1);
clusterLabels = zeros(1, numHeads);
nextLabel = 0;
for h1 = 1:numHeads
    curCombination1 = FullbodyCombinations(h1,:);
    curLabel = clusterLabels(h1);
    if 0 == curLabel
        nextLabel = nextLabel + 1;
        curLabel = nextLabel;
        clusterLabels(h1) = curLabel;        
    end
    
    for h2 = h1+1:numHeads
        if curLabel == clusterLabels(h2), continue; end
        curCombination2 = FullbodyCombinations(h2,:);
        % check adjacency
        bNeighbor = CheckCombinationOverlap(...
            curCombination1, curCombination2, listCParts, 0.0);
        if ~bNeighbor, continue; end
        
        % assign label
        if 0 == clusterLabels(h2)
            clusterLabels(h2) = curLabel;
            continue;
        end
        % entire label refresh
        if curLabel < clusterLabels(h2)
            clusterLabels(clusterLabels == clusterLabels(h2)) = curLabel;
        else
            clusterLabels(clusterLabels == curLabel) = clusterLabels(h2);
            curLabel = clusterLabels(h2);
        end
    end
end

% label refresh
[clusterLabels, sortedIdx] = sort(clusterLabels, 'ascend');
FullbodyCombinations = FullbodyCombinations(sortedIdx,:);
uniqueLabels = unique(clusterLabels);
numCluster = length(uniqueLabels);
for labelIdx = 1:numCluster
    clusterLabels(clusterLabels == uniqueLabels(labelIdx)) = labelIdx;
end
uniqueLabels = 1:numCluster;

% cluster collecting
cellCombinationCluster = cell(1, numCluster);
for labelIdx = 1:numCluster
    cellCombinationCluster{labelIdx} = ...
        FullbodyCombinations(clusterLabels == uniqueLabels(labelIdx),:);
end

%==========================================
% SINGLE HEAD CLUSTER PICK
%==========================================
listSingleHeadCluster = false(1, numCluster);
for clusterIdx = 1:numCluster
    % heads of same components, or non-overlapped heads -> not sole head cluseter
    curHeadIdxs = cellCombinationCluster{clusterIdx}(:,2)';
    numCurHeads = length(curHeadIdxs);
    bSoleHead = true;
    for h1 = 1:numCurHeads-1
        for h2 = h1+1:numCurHeads
            % check component
            if listCParts(curHeadIdxs(h1)).component == listCParts(curHeadIdxs(h2)).component
                bSoleHead = false;
                break;
            end
            
            % check overlap
            if ~CheckOverlap( ...
                    listCParts(curHeadIdxs(h1)).coords, ...
                    listCParts(curHeadIdxs(h2)).coords, ...
                    0.0)
                bSoleHead = false;
                break;
            end
        end
        if ~bSoleHead, break; end
    end    
    listSingleHeadCluster(clusterIdx) = bSoleHead;
end

end

%()()
%('')HAANJU.YOO