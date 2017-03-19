function [solution] = Optimization_Gurobi_batch(detections, ...
    grb_model, timelimit)
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

numVariables = length(detections);
if length(grb_model.obj) ~= numVariables, error('wrong model!'); end

%==========================================
% SYSTEM PARAMETERS
%==========================================
grb_params.outputflag = 0;
grb_params.timelimit = timelimit;

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