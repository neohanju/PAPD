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


%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% 파트 리스폰스 뽑기위한 부분
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

% init
main_init;
TARGET_FRAME = 216;
IMAGE_RESIZE = 1.5;
CROP_CENTER = [665, 337] * IMAGE_RESIZE;
CROP_ZONE = round([CROP_CENTER(1)-75, CROP_CENTER(1)+75-1, CROP_CENTER(2)-130, CROP_CENTER(2)+130-1]);
CROP_WIDTH = CROP_ZONE(2) - CROP_ZONE(1) + 1;
CROP_HEIGHT = CROP_ZONE(4) - CROP_ZONE(3) + 1;

% load target frame
image = imread(fullfile(IMAGE_DIR, sprintf([IMAGE_NAMEFORM, '.', IMAGE_FORMATE], TARGET_FRAME)));
cropImage = imresize(image, IMAGE_RESIZE);
cropImage = cropImage(CROP_ZONE(3):CROP_ZONE(4),CROP_ZONE(1):CROP_ZONE(2),:);

% load parts
partPath = fullfile(PARTCANDIDATE_DIR, sprintf(PARTCANDIDATE_FORM, TARGET_FRAME));
load(partPath);
partDetections.partscores = partscores;
partDetections.coords     = coords;
partDetections.scale      = PARTCANDIDATE_SCALE;

[numPartTypes, numRoots] = size(partscores);
numPartTypes = numPartTypes - 1; % exclude "pyramidLevel"
parts        = cell(numPartTypes, 1);
for rootIdx = 1:numRoots
    typeOffset = 1;    
    for typeIdx = 1:numPartTypes
        curCoord = coords(typeOffset:typeOffset+3,rootIdx)'/2.0 * IMAGE_RESIZE;
        parts{typeIdx} = [parts{typeIdx}; curCoord];
        typeOffset = typeOffset + 4;               
    end
    
end

% draw parts
for typeIdx = 1:numPartTypes
    figCurrent = figure(typeIdx); imshow(cropImage, 'border', 'tight'); hold on;
    set(figCurrent, 'position', [typeIdx*(CROP_WIDTH+4)-CROP_WIDTH, 400, CROP_WIDTH, CROP_HEIGHT]);
    for partIdx = 1:size(parts{typeIdx}, 1)
        x = parts{typeIdx}(partIdx,1);
        y = parts{typeIdx}(partIdx,2);
        w = parts{typeIdx}(partIdx,3) - x + 1;
        h = parts{typeIdx}(partIdx,4) - y + 1;
        x = x - CROP_ZONE(1) + 1;
        y = y - CROP_ZONE(3) + 1;
        rectangle('position', [x,y,w,h], 'EdgeColor', [1.0,1.0,1.0]);
    end
    hold off;
end



%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% 디버깅하면서 찍었던 코드. part combination 추출용
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
DrawDetections(cellListDetections{3},listCParts,image,0.5,5,500);


%()()
%('') HAANJU.YOO