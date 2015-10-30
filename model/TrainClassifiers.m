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

% cost design
missClassificationCostMat = [0, 1; 1, 0]; % [TN, FP; FN, TP]
maxCostFP = 100;
minCostFP = 1;

load('ConfigurationScoreStats.mat'); 
% 'normParam'
% 'scoreStats': ''posScoreSum', 'negScoreSum', 'posScores', 'negScores'

numConfigurations = length(scoreStats.posScoreSum);
numPartTypes = size(scoreStats.posScores, 2);
numPosScores = size(scoreStats.posScores, 1);
numNegScores = size(scoreStats.negScores, 1);
numScores = numPosScores + numNegScores;
SVMModels = cell(numConfigurations, 1);
positiveScoreMean = zeros(numConfigurations, 1);
positiveScoreStd  = zeros(numConfigurations, 1);
negativeMaxScores = min(max(scoreStats.negScores), ...
    mean(scoreStats.negScores) + 3*std(scoreStats.negScores));

% % normalization
% sampleMean = mean([scoreStats.posScores; scoreStats.negScores], 1);
% sampleStd  = std([scoreStats.posScores; scoreStats.negScores], 1);
% Xp = (scoreStats.posScores - repmat(sampleMean, numPosScores, 1)) ...
%     ./ repmat(sampleStd, numPosScores, 1);
% Xn = (scoreStats.negScores - repmat(sampleMean, numNegScores, 1)) ...
%     ./ repmat(sampleStd, numNegScores, 1);

% sample labels
Y = [ones(1, numPosScores), -1*ones(1, numNegScores)]';
fprintf('traning SVM for configurations...');
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
    
    % missclassification cost
    costFP = 0;
    if numDim < numPartTypes
        costFP = (maxCostFP - minCostFP) * (1 - (numDim-1)/numPartTypes) + minCostFP;
    end
    missClassificationCostMat(1,2) = costFP;

    X = [scoreStats.posScores(:,idxs); scoreStats.negScores(:,idxs)];
    SVMModels{cIdx} = fitcsvm(...
        X, Y, ...
        'KernelFunction', 'rbf', ...
        'Standardize', true, ...
        'Cost', missClassificationCostMat);
    
    bPositive = false(1, numScores);
    for i = 1:numScores
        label = predict(SVMModels{cIdx}, X(i,:));
        if 1 == label, bPositive(i) = true; end
    end
    positives = X(bPositive,:);
    totalScorePositives = sum(positives,2);
    positiveScoreMean(cIdx) = mean(totalScorePositives);
    positiveScoreStd(cIdx)  = std(totalScorePositives);
    
    if ~isfinite(positiveScoreMean(cIdx)), error('invalid mean!'); end
    if ~isfinite(positiveScoreStd(cIdx)) || 0 == positiveScoreStd(cIdx)
        error('invalid std!'); 
    end
    
%     if 2 ~= numDim, continue; end
%     figure(1);
%     plot(scoreStats.negScores(:,idxs(1)), scoreStats.negScores(:,idxs(2)), 'rx');
%     hold on;
%     plot(scoreStats.posScores(:,idxs(1)), scoreStats.posScores(:,idxs(2)), 'g+');
%     hold off;    
%     figure(2);
%     plot(X(~bPositive,1), X(~bPositive,2), 'rx');
%     hold on;
%     plot(X(bPositive,1), X(bPositive,2), 'g+');
%     hold off;
end
fprintf(repmat('\b', 1, nchar));
fprintf('done!\n');

save('ConfigurationClassifiers.mat', ... %'-v6', ...
    'SVMModels', 'positiveScoreMean', 'positiveScoreStd', 'negativeMaxScores');

%()()
%('')HAANJU.YOO