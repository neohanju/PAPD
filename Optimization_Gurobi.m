function [solution] = Optimization_Gurobi(detections, listCParts, model, ...
    rootMaxOverlap, partMaxOverlap, partOccMinOverlap, timelimit)
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

tic;
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
    scoreUnary(dIdx) = scoreUnary(dIdx) + numVisiblePart - defaultVisiblePartScore;
end
fprintf('done!!\n');

% try
    %==========================================
    % PAIRWISE CHECK
    %==========================================
    % construct Q (pairwise score)
    fprintf('construct Q and constraints...');
    scorePairwise = zeros(numVariables*(numVariables-1)/2, 3);
    constraints = zeros(numVariables^2, 2);
    numScorePairwise = 0;
    numConstraints = 0;
    numLoops = numVariables*(numVariables-1)/2;
    curLoop = 0;
    nchar = fprintf('%d/%d', curLoop, numLoops);
    for d1 = 1:numVariables-1
        for d2 = d1+1:numVariables
            curLoop = curLoop + 1;
            fprintf(repmat('\b', 1, nchar));
            nchar = fprintf('%d/%d', curLoop, numLoops);
            % constraints
            if ~IsCompatible(detections(d1), detections(d2), listCParts, ...
                    rootMaxOverlap, partMaxOverlap)
                numConstraints = numConstraints + 1;
                constraints(numConstraints,:) = [d1, d2];
                continue;
            end

            % pairwise score
            numOccludedParts = NumOccludedParts( ...
                detections(d1), ...
                detections(d2), ...
                listCParts, model, partOccMinOverlap);

            if 0 == numOccludedParts, continue; end
            numScorePairwise = numScorePairwise + 1;
            scorePairwise(numScorePairwise,:) = [d1, d2, numOccludedParts];
        end
    end
    constraints = constraints(1:numConstraints,:);
    scorePairwise = scorePairwise(1:numScorePairwise,:);
    fprintf('...done!!\n');
    fprintf('%d constraints / %d pairwise scores\n', numConstraints, numScorePairwise);

    %==========================================
    % MODEL
    %==========================================    
    % set objectives
    if 0 < numScorePairwise
        scores = [scorePairwise(:,3); scorePairwise(:,3)]/2.0; % important!!
        rowIndices = [scorePairwise(:,1); scorePairwise(:,2)];
        colIndices = [scorePairwise(:,2); scorePairwise(:,1)];
        if max(rowIndices) < numVariables || max(colIndices) < numVariables
            rowIndices(end+1) = numVariables;
            colIndices(end+1) = numVariables;
            scores(end+1) = 0.0;
        end
        grb_model.Q = sparse(rowIndices, colIndices, scores);
    end
    grb_model.obj = scoreUnary;
    grb_model.modelsense = 'max';
    clear rowIndices colIndices scores scoreUnary scorePairwise;

    % set constraints to the model
    if 0 < numConstraints
        constraints = constraints(1:numConstraints,:);
        rowIndices = [1:numConstraints, 1:numConstraints];
        colIndices = [constraints(:,1); constraints(:,2)];
        grb_model.A = sparse(rowIndices', colIndices, ones(1, 2*numConstraints));
        grb_model.rhs = ones(1, numConstraints);
        grb_model.sense = '<';  % single value -> same all
    end
    grb_model.vtype = 'B';
    
    %==========================================
    % INITIAL SOLUTION
    %==========================================
    % set initial solution with root nms result
    fullbodyIdx = 1:numVariables;
    listIsFullBody = false(1, numVariables);
    for dIdx = 1:numVariables
        if 0 < length(find(0 == detections(dIdx).combination)), continue; end
        listIsFullBody(dIdx) = true;
    end    
    fullbodyIdx = fullbodyIdx(listIsFullBody);
    numFullBodies = length(fullbodyIdx);
    matFullbodyNMS = zeros(numFullBodies, 5);
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
    for d1 = pickedIdx;        
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

end

%()()
%('')HAANJU.YOO