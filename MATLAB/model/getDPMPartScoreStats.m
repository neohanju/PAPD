%==========================================================================
% getDPMPartScoreStats.m
% 
% This function compute score normalization parameter according to each 
% configuration. This code adopted dpm source code (cascade_model.m) to
% get dpm's part score statistics.
% 
%==========================================================================
function getDPMPartScoreStats()
%========================
% SETTINGS
%========================
% set paths
DPM_path = 'D:\work\DPM\voc-release4.01';
addpath(genpath(DPM_path));
model_path = 'model';
% set stats file
inffile = fullfile(DPM_path, 'star-cascade', 'data', ...
    'inriaperson_2007_cascade_data_pca0_2007.inf');
negInffile = fullfile('model', 'inriaperson_2007_cascade_neg_data_pca0_2007.inf');
% Load DPM model
load(fullfile(model_path, 'INRIAPERSON_star.mat'));


%====================================
% READ STATISTICS AND PRE-PROCESSING
%====================================
% get block score statistics from info file
[vals, blocks] = readscorestats(inffile, model);
[negVals, negBlocks] = readscorestats(negInffile, model);
% restrict the data to only those positive examples with score >= thresh
I = find(vals >= model.thresh);
blocks = blocks(I,:);
vals = vals(I,:);
scoresCell = parse_scores(model, vals, blocks);
negScoresCell = parse_scores(model, negVals, negBlocks);
% get order using score statistics (this order is the same as cascade-dpm
% model)
for c = 1:model.numcomponents
  order{c} = getorder(model, scoresCell, c);
end



%========================
% GET SCORE STATISTICS
%========================
nParts = length(model.components{1}.parts);
% Construct configuration (head 반드시 포함, root는 고려 X)
numPartTypes = nParts + 1 ;
configurations = zeros(2^(numPartTypes-2), numPartTypes);
for cIdx = 1:size(configurations, 1)
    flags = ['01', dec2bin(cIdx-1, numPartTypes-2)];
    for typeIdx = 1:numPartTypes
        configurations(cIdx,typeIdx) = str2double(flags(typeIdx));
    end
end

numConfigurations = size(configurations, 1);
for c = 1 : model.numcomponents
    %-------------------------
    % Positive sample scores 
    %-------------------------
    % get total score (def + filter response) of part_i
    tmp = scoresCell{c}(:, 3:end);
    posScores = zeros(size(scoresCell{c}, 1),nParts);
    % P(:,i) = 
    for i = 1:nParts
        posScores(:,i) = sum(tmp(:,2*i-1:2*i),2);
    end        
    % set order
    posScores = posScores(:,order{c}(2:2+nParts-1));
    
    %-------------------------
    % Negative sample scores
    %-------------------------
    tmp = negScoresCell{c}(:, 3:end);
    negScores = zeros(size(negScoresCell{c}, 1),nParts);
    % P(:,i) = 
    for i = 1:nParts
        negScores(:,i) = sum(tmp(:,2*i-1:2*i),2);
    end        
    % set order
    negScores = negScores(:,order{c}(2:2+nParts-1));
    
    
    %---------------------------------------------------
    % Score statistics corresponding to configurations
    % (지금은 positive sample만 고려함.)
    %---------------------------------------------------    
    sz = size(posScores, 1);
    sz_neg = size(negScores, 1);
    normParam{c} = [];
    for confIdx = 1 : numConfigurations
        curConf = configurations(confIdx, :);
        curConf(1) = [];                     % ex)     1 * 8
        curConfMat = repmat(curConf, sz, 1); % ex)  2180 * 8
        % find min, max
        scoreSum = sum(curConfMat.*posScores, 2);        
        scoreMax = max(scoreSum);
        scoreMin = min(scoreSum);        
        normParam{c}(confIdx).max = scoreMax;
        normParam{c}(confIdx).min = scoreMin; 
        
        
        % positive & negative scores
        posScoreSum{confIdx} = sum(curConfMat.*posScores, 2);
        curNegConfMat = repmat(curConf, sz_neg, 1);
        negScoreSum{confIdx} = sum(curNegConfMat.*negScores, 2);
        %
    end
end
scoreStats.posScoreSum  = posScoreSum;
scoreStats.negScoreSum  = negScoreSum;
scoreStats.posScores    = posScores;
scoreStats.negScores    = negScores;

%==========================
% SAVE NORMALIZATION PARAM
%==========================
save(fullfile(model_path, 'ConfigurationScoreStats.mat'),'normParam', ...
    'scoreStats');











function scores = parse_scores(model, vals, blocks)
% reorganize blocks so they are in part order rather than blocklabel order:
% rootdef, rootscore, partdef_1, partscore_1, ..., partdef_K, partscore_K
rows = size(blocks, 1);
nparts = length(model.components{1}.parts);
scores = cell(model.numcomponents,1);
for i = 1:model.numcomponents
  % build arrays of part and deformation block indexes
  prt = zeros(1, 2*nparts);
  for j = 1:nparts
    pind = model.components{i}.parts{j}.partindex;
    dind = model.components{i}.parts{j}.defindex;
    prt(2*j-1) = model.defs{dind}.blocklabel;
    prt(2*j)   = model.partfilters{pind}.blocklabel;
  end
  % The block holding the offset will always have a non-zero score in 
  % the inffile, so we use the offset's block to infer which component 
  % a row from blocks corresponds to.
  offsetbl = model.offsets{model.components{i}.offsetindex}.blocklabel;
  rootbl  = model.rootfilters{model.components{i}.rootindex}.blocklabel;
  I = find(blocks(:,offsetbl) ~= 0);
  tmp = zeros(size(I,1), 2*nparts+2);
  tmp(:,2) = blocks(I,rootbl);
  tmp(:,3:end) = blocks(I,prt);
  scores{i} = tmp;
end

function ord = getorder(model, scores, c)
numparts = length(model.components{c}.parts);
% non-root part scores
l = size(scores{c},1);
tmp = scores{c}(:, 3:end);
P = zeros(l,numparts);
% P(:,i) = total score (def + filter response) of part_i
for i = 1:numparts
  P(:,i) = sum(tmp(:,2*i-1:2*i),2);
end

% select part order
ord = [];
for i = 1:numparts
  best = inf;
  bbest = 0;
  % j \in {set of remaining parts}
  for j = setdiff(1:numparts, ord)
    % s = {remaining parts IF we pick j in this round}
    s = setdiff(1:numparts, [ord j]);
    % compute variance of the scores of the remaining parts
    b = var(sum(P(:,s), 2));
    % pick the j that makes the score variance of s smallest
    if b < best
      best = b;
      bbest = j;
    end
  end
  ord(end+1) = bbest;
end
% root part goes first for simplicity
ord = [0 ord 0 ord];