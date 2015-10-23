function [cellCombinationCluster, listSingleHeadCluster] = HeadClustering(...
    FullbodyCombinations, listCParts, partOverlapRatio)
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

%==========================================
% HEAD CLUSTERING
%==========================================
[numHeads, numTypes] = size(FullbodyCombinations);
clusterLabels = zeros(1, numHeads);
nextLabel = 0;
for headIdx1 = 1:numHeads
    curCombination1 = FullbodyCombinations(headIdx1,:);
    curLabel = clusterLabels(headIdx1);
    if 0 == curLabel
        nextLabel = nextLabel + 1;
        curLabel = nextLabel;
        clusterLabels(headIdx1) = curLabel;        
    end
    
    for headIdx2 = headIdx1+1:numHeads
        if curLabel == clusterLabels(headIdx2), continue; end
        curCombination2 = FullbodyCombinations(headIdx2,:);
        % check adjacency
        bNeighbor = CheckCombinationOverlap(...
            curCombination1, curCombination2, listCParts, 0.0);
        if ~bNeighbor, continue; end
        
        % assign label
        if 0 == clusterLabels(headIdx2)
            clusterLabels(headIdx2) = curLabel;
            continue;
        end
        % entire label refresh
        if curLabel < clusterLabels(headIdx2)
            clusterLabels(clusterLabels == clusterLabels(headIdx2)) = curLabel;
        else
            clusterLabels(clusterLabels == curLabel) = clusterLabels(headIdx2);
            curLabel = clusterLabels(headIdx2);
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
    
    
    curHeadIdxs = headIdxSet(uniqueLabels(clusterIdx) == clusterLabels);
    numCurHeads = length(curHeadIdxs);
    
    
    bSoleHead = true;
    for headIdx1 = 1:numCurHeads-1
        curHead1Idx = headIdxSet(head1Idx);
        for headIdx2 = headIdx1+1:numCurHeads
            curHead2Idx = headIdxSet(head2Idx);
            if listCParts(curHead1Idx).component == listCParts(curHead2Idx).component ...
                || ~CheckOverlap(listCParts(curHead1Idx).coords, listCParts(curHead2Idx).coords, partOverlapRatio)
                bSoleHead = false;
                break;
            end
        end
        if ~bSoleHead, break; end
    end    
    listSoleHeadCluster(clusterIdx) = bSoleHead;
end

end