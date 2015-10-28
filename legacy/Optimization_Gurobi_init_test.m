% function [solution, grb_model] = Optimization_Gurobi(detections, listCParts, ...
%     model, rootMaxOverlap, partMaxOverlap, partOccMinOverlap, timelimit)
%     .__                           __.
%       \ `\~~---..---~~~~~~--.---~~| /   
%        `~-.   `                   .~         _____ 
%            ~.                .--~~    .---~~~    /
%             / .-.      .-.      |  <~~        __/
%            |  |_|      |_|       \  \     .--'
%           /-.      -       .-.    |  \_   \_
%           \-'   -..-..-    `-'    |    \__  \_ 
%            `.                     |     _/  _/
%              ~-                .,-\   _/  _/
%             /                 -~~~~\ /_  /_
%            |               /   |    \  \_  \_ 
%            |   /          /   /      | _/  _/
%            |  |          |   /    .,-|/  _/ 
%            )__/           \_/    -~~~| _/
%              \                      /  \
%               |           |        /_---` 
%               \    .______|      ./
%               (   /        \    /
%               `--'          /__/

numVariables = length(grb_model.obj);
detections = cellListDetections{2};
rootMaxOverlap = ROOT_MAX_OVERLAP;
partMaxOverlap = PART_MAX_OVERLAP;
partOccMinOverlap = PART_OCC_OVERLAP;
% constraints = zeros(size(grb_model.A, 1), 2);
% for c = 1:size(grb_model.A, 1)
%     idxs = find(1 == grb_model.A(c,:));
%     constraints(c,:) = [idxs(1), idxs(2)];
% end


%==========================================
% INITIAL SOLUTION
%==========================================
% set initial solution with root nms result
numFullbodies = 0;
fullbodyIdx = zeros(1, numVariables);
for dIdx = 1:numVariables
    if 0 < length(find(0 == detections(dIdx).combination)), continue; end
    numFullbodies = numFullbodies + 1;
    fullbodyIdx(numFullbodies) = dIdx;
end
fullbodyIdx = fullbodyIdx(1:numFullbodies);
matFullbodyNMS = zeros(numFullbodies, 5);
for dIdx = 1:length(fullbodyIdx)
    rootIdx = detections(fullbodyIdx(dIdx)).combination(1);
    rootCoords = listCParts(rootIdx).coords;
    rootScore = listCParts(rootIdx).score;
    matFullbodyNMS(dIdx,:) = [rootCoords, rootScore];
end
pickedIdx = nms2(matFullbodyNMS, partMaxOverlap)';
pickedScore = matFullbodyNMS(pickedIdx,5);

% feasibility check
[~, sortingOrder] = sort(pickedScore, 'descend');
pickedIdx = pickedIdx(sortingOrder);
initialSolution = zeros(1, numVariables);
numInitialSolution = 0;
for d1 = fullbodyIdx(pickedIdx);
    bIncompatible = false;
    for d2 = 1:numInitialSolution
        dPair = sort([d1, initialSolution(d2)], 'ascend');
        constraintIdx1 = find(constraints(:,1) == dPair(1));
        constraintIdx2 = find(constraints(:,2) == dPair(2));
        constraintIdx = intersect(constraintIdx1, constraintIdx2);
        if isempty(constraintIdx), continue; end
        bIncompatible = true;
        break;
    end
    if bIncompatible, continue; end
    numInitialSolution = numInitialSolution + 1;
    initialSolution(numInitialSolution) = d1;
end
for d1 = 1:numVariables
    if ~isempty(find(d1 == initialSolution, 1)), continue; end
    bIncompatible = false;
    for d2 = 1:numInitialSolution
        dPair = sort([d1, initialSolution(d2)], 'ascend');
        constraintIdx1 = find(constraints(:,1) == dPair(1));
        constraintIdx2 = find(constraints(:,2) == dPair(2));
        constraintIdx = intersect(constraintIdx1, constraintIdx2);
        if isempty(constraintIdx), continue; end
        
        totalNumParts = grb_model.obj(d1) + grb_model.obj(d2) + grb_model.Q(d1,d2) * 2.0;
        if 0 <= totalNumParts, continue; end
        
        bIncompatible = true;
        break;
    end
    if bIncompatible, continue; end
    numInitialSolution = numInitialSolution + 1;
    initialSolution(numInitialSolution) = d1;
end
initialSolution = initialSolution(1:numInitialSolution);
initialVector = zeros(1, numVariables);
initialVector(initialSolution) = 1.0;
grb_model.start = initialVector';

%==========================================
% SYSTEM PARAMETERS
%==========================================
grb_params.outputflag = 0;
grb_params.timelimit = timelimit;
t_const = toc;
fprintf(['construction time: ' datestr(datenum(0,0,0,0,0,t_const),'HH:MM:SS') '\n']);

%==========================================
% SOLVE
%==========================================
curTime = clock;
fprintf(['solve (start at ' ...
    datestr(datenum(0,0,0,curTime(4),curTime(5),curTime(6)),'HH:MM:SS') ...
    ' / time limit: %dsec)...'], grb_params.timelimit);
tic;
grb_result = gurobi(grb_model, grb_params);
t_solve = toc;
fprintf(['done!!\n' 'solving time: ' datestr(datenum(0,0,0,0,0,t_solve),'HH:MM:SS') '\n']);

%==========================================
% RESULT PACKAGING
%==========================================
solution = cell(1, 2);
solution{1} = CDetection.empty();
solution{2} = grb_result.objval;
numDetectionInSolution = 0;
for v = 1:numVariables
    if 0 == grb_result.x(v), continue; end
    numDetectionInSolution = numDetectionInSolution + 1;
    solution{1}(numDetectionInSolution) = detections(v);
end
% catch gurobiError
%     fprintf('Error reported\n');
% end


%()()
%('')HAANJU.YOO