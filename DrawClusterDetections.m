function DrawClusterDetections(detections, listCParts, image, figIdx)
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

if nargin < 4, figure; else figure(figIDx); end

imshow(image, 'border', 'tight'); hold on;
numDetection = length(detections);
fullbodyIdx = zeros(numDetection, 1);
numFullBodies = 0;
for d = 1:numDetection
    if 0 < length(find(0 == detections(d).combination)), continue; end
    numFullBodies = numFullBodies + 1;
    fullbodyIdx(numFullBodies) = d;
end
hold off;

end

%()()
%('')HAANJU.YOO
