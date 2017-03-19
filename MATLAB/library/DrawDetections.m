function [targetCombination] = ...
    DrawDetections(detections, listCParts, image, rescale, pedestrianIdx, figNum)
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

if nargin < 6
    figT = figure;
    figD = figure;    
else
    figT = figure(figNum); 
    figD = figure(figNum+1);
end

numDetections = length(detections);
if 0 == numDetections, return, end;
numParts = length(detections(1).combination);

% find fullbody idxs
numFullbodies = 0;
fullbodyIdxs  = zeros(1, numDetections);
rootIdxs      = zeros(1, numDetections);
for d = 1:numDetections
    if 0 < length(find(0 == detections(d).combination)), continue; end
    numFullbodies = numFullbodies + 1;
    fullbodyIdxs(numFullbodies) = d;
    rootIdxs(numFullbodies)     = detections(d).combination(1);
end

if pedestrianIdx > numFullbodies
    fprintf('[WARNING] too large index for the pedestrian!\n');
    return;
end
fullbodyIdxs = fullbodyIdxs(1:numFullbodies);
targetIdx    = fullbodyIdxs(pedestrianIdx);
targetCombination = detections(targetIdx).combination;

% find target combinations
numCombinations = 0;
combinationIdxs = zeros(1, numDetections);
for d = 1:numDetections
    if detections(d).combination(1) ~= targetCombination(1), continue; end
    numCombinations = numCombinations + 1;
    combinationIdxs(numCombinations) = d;
end
combinationIdxs = combinationIdxs(1:numCombinations);

%=======================================
% DRAW TARGET PEDESTRIAN
%=======================================

figure(figT); imshow(image, 'border', 'tight');
hold on;
rectangle('position', rescale*GetBox(listCParts(detections(targetIdx).combination(1))), 'EdgeColor', [1,0,0]);
for p = 2:numParts
    rectangle('position', rescale*GetBox(listCParts(detections(targetIdx).combination(p))), 'EdgeColor', [1,1,1]);
end
hold off;

%=======================================
% DRAW COMBINATIONS
%=======================================

% image crop
[imgH,imgW,~] = size(image);
cropZoneMargin = 10;
cropZone = rescale * listCParts(detections(targetIdx).combination(1)).coords;
cropZone(1) = max(0, round(cropZone(1) - cropZoneMargin));
cropZone(2) = max(0, round(cropZone(2) - cropZoneMargin));
cropZone(3) = min(imgW, round(cropZone(3) + cropZoneMargin));
cropZone(4) = min(imgH, round(cropZone(4) + cropZoneMargin));
cropImage = image(cropZone(2):cropZone(4),cropZone(1):cropZone(3),:);


figure(figD);
numSubCol = 10;
numSubRow = ceil(numCombinations / numSubCol);
for c = 1:numCombinations
    cIdx = combinationIdxs(c);
    subplot(numSubRow, numSubCol, c);
    imshow(cropImage, 'border', 'tight'); 
    title(sprintf('ID:%d/score:%f', cIdx, detections(cIdx).score));
    hold on;    
    for p = 2:numParts
        if 0 == detections(cIdx).combination(p), continue; end
        curBox = rescale*GetBox(listCParts(detections(cIdx).combination(p)));
        curBox(1) = curBox(1) - cropZone(1) + 1;
        curBox(2) = curBox(2) - cropZone(2) + 1;
        rectangle('position', curBox, 'EdgeColor', [1,1,1]);
    end
    hold off;
end

end