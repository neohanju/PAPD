function [cellHeadCluster, listSoleHeadCluster, headIdxSet] = HeadClustering(...
    listCParts, cellIndexAmongType, model, clusterOverlapRatio, partOverlapRatio)
% <description>
% - clustering heads with connectivity by parts overlap
% <input>
% - listCParts: list of part class instances
% - cellIndexAmongType: part index set among types and components
% - model: deformable part model
% - clusterOverlapRatio: cluster merging criteria
% - partOverlapRatio: sole head cluster decision criteria
% <output>
% - cellHeadCluster: set of head indices of each cluster
% - listSoleHeadCluster: flags indicate whether the cluster contains sole head
% - headIdxSet: head indices

%==========================================
% HEAD CLUSTERING
%==========================================
headIdxSet = [];
numComponent = size(cellIndexAmongType, 2);
for componentIdx = 1:numComponent
    headIdxSet = [headIdxSet, cellIndexAmongType{2, componentIdx}];
end
numHeads = length(headIdxSet);
clusterLabels = zeros(1, numHeads);

nextLabel = 1;
for head1Idx = 1:numHeads
    curLabel = clusterLabels(head1Idx);
    if 0 == curLabel
        curLabel = nextLabel;
        clusterLabels(head1Idx) = curLabel;
        nextLabel = nextLabel + 1;
    end
    
    for head2Idx = head1Idx+1:numHeads
        if curLabel == clusterLabels(head2Idx), continue; end
        
        % check adjacency
        if ~IsNeighbor(listCParts(headIdxSet(head1Idx)), ...
                listCParts(headIdxSet(head2Idx)), model, clusterOverlapRatio, image)
            continue;
        end
        if 0 == clusterLabels(head2Idx)
            clusterLabels(head2Idx) = curLabel;
            continue;
        end
        
        % label update
        if curLabel < clusterLabels(head2Idx)
            clusterLabels(clusterLabels == clusterLabels(head2Idx)) = curLabel;
        else
            clusterLabels(clusterLabels == curLabel) = clusterLabels(head2Idx);
            curLabel = clusterLabels(head2Idx);
        end
    end
end

% label refresh
[clusterLabels, sortedIdx] = sort(clusterLabels, 'ascend');
headIdxSet = headIdxSet(sortedIdx);
uniqueLabels = unique(clusterLabels);
numCluster = length(uniqueLabels);
for labelIdx = 1:numCluster
    clusterLabels(clusterLabels == uniqueLabels(labelIdx)) = labelIdx;
end
uniqueLabels = unique(clusterLabels);

% cluster collecting
cellHeadCluster = cell(1, numCluster);
for labelIdx = 1:numCluster
    cellHeadCluster{labelIdx} = headIdxSet(clusterLabels == uniqueLabels(labelIdx));
end

%==========================================
% SOLE HEAD PICK
%==========================================
listSoleHeadCluster = false(1, numCluster);
for clusterIdx = 1:numCluster
    curHeadIdxs = headIdxSet(uniqueLabels(clusterIdx) == clusterLabels);
    numCurHeads = length(curHeadIdxs);
    
    % heads of same components, or non-overlapped heads -> not sole head cluseter
    bSoleHead = true;
    for head1Idx = 1:numCurHeads-1
        curHead1Idx = headIdxSet(head1Idx);
        for head2Idx = head1Idx+1:numCurHeads
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