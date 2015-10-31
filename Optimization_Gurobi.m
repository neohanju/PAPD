function [solution, grb_model] = Optimization_Gurobi(detections, listCParts, ...
    model, rootMaxOverlap, partMaxOverlap, partOccMinOverlap, timelimit)
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

t_const = tic; tic;
clear grb_model grb_params;
numVariables = length(detections);
numPartTypes = floor(length(model.partfilters) / model.numcomponents);

%==========================================
% UNARI SCORES
%==========================================
fprintf('construct unary scorses...');
scoreUnary = [detections.score];
defaultVisiblePartScore = numPartTypes; % exclude root
for dIdx = 1:numVariables
    numVisiblePart = length(find(0 ~= detections(dIdx).combination(2:end)));
%     scoreUnary(dIdx) = scoreUnary(dIdx) ...         % filter score
%         + numVisiblePart - defaultVisiblePartScore; % occlusion penalty
    scoreUnary(dIdx) = ...
        scoreUnary(dIdx) * (numVisiblePart/numPartTypes)^2 ... % filter score
        + numVisiblePart - defaultVisiblePartScore;            % occlusion penalty
end
fprintf('done!!\n');

%==========================================
% PAIRWISE CHECK
%==========================================
% construct Q (pairwise score)
fprintf('construct Q and constraints...');
scorePairwise = zeros(numVariables*(numVariables+1)/2, 3);
constraints = zeros(numVariables^2, 2);
numScorePairwise = 0;
numConstraints = 0;
numLoops = numVariables*(numVariables+1)/2;
curLoop = 0;
nchar = fprintf('%d/%d', curLoop, numLoops);
for d1 = 1:numVariables-1
    for d2 = d1+1:numVariables
        curLoop = curLoop + 1;
        if toc > 1
            fprintf(repmat('\b', 1, nchar));
            nchar = fprintf('%d/%d', curLoop, numLoops);
            tic;
        end
        % constraints
        if ~IsCompatible(detections(d1), detections(d2), listCParts, ...
                rootMaxOverlap, partMaxOverlap)
            numConstraints = numConstraints + 1;
            constraints(numConstraints,:) = [d1, d2];
            continue;
        end
        % pairwise score
        numOccludedParts1 = NumOccludedParts( ...
            detections(d1), ...
            detections(d2), ...
            listCParts, partOccMinOverlap);
        numOccludedParts2 = NumOccludedParts( ...
            detections(d2), ...
            detections(d1), ...
            listCParts, partOccMinOverlap);

        if 0 < numOccludedParts1
            numScorePairwise = numScorePairwise + 1;
            scorePairwise(numScorePairwise,:) = [d1, d2, numOccludedParts1];
        end
        if 0 < numOccludedParts2
            numScorePairwise = numScorePairwise + 1;
            scorePairwise(numScorePairwise,:) = [d2, d1, numOccludedParts2];
        end
    end
end
constraints = constraints(1:numConstraints,:);
scorePairwise = scorePairwise(1:numScorePairwise,:);
fprintf(repmat('\b', 1, nchar));
fprintf('...done!!\n');
fprintf('%d constraints / %d pairwise scores\n', numConstraints, numScorePairwise);

%==========================================
% MODEL
%==========================================    
% set objectives
if 0 < numScorePairwise
    scores = scorePairwise(:,3);
    rowIndices = scorePairwise(:,1);
    colIndices = scorePairwise(:,2);
    if max(rowIndices) < numVariables || max(colIndices) < numVariables
        rowIndices(end+1) = numVariables;
        colIndices(end+1) = numVariables;
        scores(end+1) = 0.0;
    end
else
    rowIndices = numVariables;
    colIndices = numVariables;
    scores = 0.0;
end
grb_model.Q = sparse(rowIndices, colIndices, scores);
grb_model.obj = scoreUnary;
grb_model.modelsense = 'max';
clear rowIndices colIndices scores scoreUnary scorePairwise;

% set constraints to the model
if 0 < numConstraints
    constraints = constraints(1:numConstraints,:);
    rowIndices = [1:numConstraints, 1:numConstraints];
    colIndices = [constraints(:,1); constraints(:,2)];
    constOnes  = ones(1, 2*numConstraints);
    % exception handling // when colIndices does not include numVariable.
    if isempty(find(colIndices==numVariables, 1))
        rowIndices(end+1) = numConstraints;
        colIndices(end+1) = numVariables;
        constOnes(end+1)  = 0;
    end
    grb_model.A = sparse(rowIndices', colIndices, constOnes);
    grb_model.rhs = ones(1, numConstraints);
    grb_model.sense = '<';  % single value -> same all(< means <=, becuase gorubi does not support strict inequailities)
else
    % when numConstraints == 0
    grb_model.A = sparse(ones(numVariables, 1), [1:numVariables]', zeros(numVariables, 1));
    grb_model.rhs = ones(1, 1);
    grb_model.sense = '<';
end
grb_model.vtype = 'B';

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
toc_const = toc(t_const);
fprintf(['construction time: ' datestr(datenum(0,0,0,0,0,toc_const),'HH:MM:SS') '\n']);

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
solution = cell(1, 3);
solution{1} = CDetection.empty();     % detections in solution
solution{2} = zeros(1, numVariables); % index of solution variables
solution{3} = grb_result.objval;      % objective value
numDetectionInSolution = 0;
for v = 1:numVariables
    if 0 == grb_result.x(v), continue; end
    numDetectionInSolution = numDetectionInSolution + 1;
    solution{1}(numDetectionInSolution) = detections(v);    
    solution{2}(numDetectionInSolution) = v;
end
solution{2} = solution{2}(1:numDetectionInSolution);

end

%()()
%('')HAANJU.YOO