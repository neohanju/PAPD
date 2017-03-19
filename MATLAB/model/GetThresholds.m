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
dbstop if error

% parameters
targetPrecision = 0.95;

load('ConfigurationScoreStats.mat'); 
% 'normParam'
% 'scoreStats': ''posScoreSum', 'negScoreSum', 'posScores', 'negScores'

numConfigurations = length(scoreStats.posScoreSum);
numPartTypes = size(scoreStats.posScores, 2);
numPosScores = size(scoreStats.posScores, 1);
numNegScores = size(scoreStats.negScores, 1);
numScores = numPosScores + numNegScores;
cellThresholds = cell(numConfigurations, 1);

% sample labels
fprintf('calculating threshold for configurations...');
nchar = fprintf('0/%d', numConfigurations);
for cIdx = 1:numConfigurations    
    fprintf(repmat('\b', 1, nchar));
    nchar = fprintf('%d/%d', cIdx, numConfigurations);
    
    % note that, there is no root consideration
    % head must be included
    curBinaryString = ['1', dec2bin(cIdx-1, numPartTypes-1)];
    curConfiguration = zeros(1, numPartTypes);
    for typeIdx = 1:numPartTypes
        curConfiguration(typeIdx) = str2double(curBinaryString(typeIdx));
    end
    idxs = find(1 == curConfiguration);
    numDim = length(idxs);
    
    Xp = sum(scoreStats.posScores(:,idxs), 2);
    Xn = sum(scoreStats.negScores(:,idxs), 2);   
    Xn = sort(Xn, 'descend');
    
    thresholdIdx = 1;
    for i = 1:numNegScores
        nTP = length(find(Xp > Xn(i)));
        nFP = i - 1;
        precision = nTP/(nTP + nFP);
        if precision < targetPrecision, break, end;
        thresholdIdx = i;
    end
    cellThresholds{cIdx} = Xn(thresholdIdx);
end
fprintf(repmat('\b', 1, nchar));
fprintf('done!\n');

save('ConfigurationThresholds.mat', ... %'-v6', ...
    'cellThresholds');

%()()
%('')HAANJU.YOO