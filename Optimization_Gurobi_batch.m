function [solution] = Optimization_Gurobi_batch(detections, grb_model, ...
    timelimit)
%     .__                           __.
%       \ `\~~---..---~~~~~~--.---~~| /   
%        `~-.   `                   .~         _____ 
%            ~.   BATCHMODE    .--~~    .---~~~    /
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
if length(grb_model) ~= numVariables, error('wrong model!!'); end;

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
solution = cell(1, 2);
solution{1} = CDetection.empty();
solution{2} = grb_result.objval;
numDetectionInSolution = 0;
for v = 1:numVariables
    if 0 == grb_result.x(v), continue; end
    numDetectionInSolution = numDetectionInSolution + 1;
    solution{1}(numDetectionInSolution) = detections(v);
end

end

%()()
%('')HAANJU.YOO