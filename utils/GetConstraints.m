function [constraints] = GetConstraints(detections, pedIdx1, pedIdx2, grb_model)

numDetections = length(detections);
if 0 == numDetections, return, end;

% find fullbody idxs
numFullbodies = 0;
fullbodyIdxs  = zeros(1, numDetections);
rootIdxs      = zeros(1, numDetections);
pedRootIdx1   = 0;
pedRootIdx2   = 0;
for d = 1:numDetections
    rootIdxs(d) = detections(d).combination(1);
    if 0 < length(find(0 == detections(d).combination)), continue; end
    numFullbodies = numFullbodies + 1;
    fullbodyIdxs(numFullbodies) = d;
    if numFullbodies == pedIdx1, pedRootIdx1 = detections(d).combination(1); end
    if numFullbodies == pedIdx2, pedRootIdx2 = detections(d).combination(1); end
end
% check validity of pedestrian indices
if 0 == pedRootIdx1 || 0 == pedRootIdx2
    fprintf('[WARNING] too large index for the pedestrian!\n');
    return;
end
if pedRootIdx1 > pedRootIdx2
    swap = pedRootIdx1;
    pedRootIdx1 = pedRootIdx2;
    pedRootIdx2 = swap;
end

ped1DetectionIdxs = find(pedRootIdx1 == rootIdxs);
ped2DetectionIdxs = find(pedRootIdx2 == rootIdxs);
numConstraints = 0;
constraints = zeros(numConstraints, 2);
for c = 1:size(grb_model.A, 1)
    idxs = find(1 == grb_model.A(c,:));
    idxs = sort(idxs, 'ascend');
    a = find(idxs(1) == ped1DetectionIdxs);
    b = find(idxs(2) == ped2DetectionIdxs);
    if isempty(a) || isempty(b), continue; end
    numConstraints = numConstraints + 1;
    constraints(numConstraints,:) = [ped1DetectionIdxs(a), ped2DetectionIdxs(b)];
end
constraints = constraints(1:numConstraints,:);

end

%()()
%('')HAANJU.YOO