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

% init
main_init;


%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%% FOR OVERALL
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
TARGET_FRAME = 80;
IMAGE_RESCALE = 1.5;
CROP_CETNER = [627, 300];
CROP_WIDTH = 130;
CROP_HEIGHT = 260;
CROP_ZONE = round([CROP_CETNER - [CROP_WIDTH/(2*IMAGE_RESCALE), CROP_HEIGHT/(2*IMAGE_RESCALE)], ...
    CROP_CETNER + [CROP_WIDTH/(2*IMAGE_RESCALE)-1, CROP_HEIGHT/(2*IMAGE_RESCALE)-1]]);

% load target frame
image = imread(fullfile(IMAGE_DIR, sprintf([IMAGE_NAMEFORM, '.', IMAGE_FORMATE], TARGET_FRAME)));
cropImage = image(CROP_ZONE(2):CROP_ZONE(4),CROP_ZONE(1):CROP_ZONE(3),:);
cropImage = imresize(cropImage, IMAGE_RESCALE);

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
        curCoord = coords(typeOffset:typeOffset+3,rootIdx)'/2.0;
        parts{typeIdx} = [parts{typeIdx}; curCoord];
        typeOffset = typeOffset + 4;               
    end
    
end

% draw parts
for typeIdx = 1:numPartTypes
    figCurrent = figure(typeIdx); imshow(cropImage, 'border', 'tight'); hold on;
    set(figCurrent, 'position', [typeIdx*(CROP_WIDTH+10)-CROP_WIDTH, 400, CROP_WIDTH, CROP_HEIGHT]);
    for partIdx = 1:size(parts{typeIdx}, 1)
        x = parts{typeIdx}(partIdx,1);
        y = parts{typeIdx}(partIdx,2);
        w = (parts{typeIdx}(partIdx,3) - x + 1) * IMAGE_RESCALE;
        h = (parts{typeIdx}(partIdx,4) - y + 1) * IMAGE_RESCALE;
        x = (x - CROP_ZONE(1) + 1) * IMAGE_RESCALE;
        y = (y - CROP_ZONE(3) + 1) * IMAGE_RESCALE;
        rectangle('position', [x,y,w,h], 'EdgeColor', [0.7,0.7,0.7]);
    end
    hold off;
end


% %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% % FOR RESULT
% %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% TARGET_FRAME = 80;
% 
% % load(fullfile(RESULT_DIR, 'result_hnr0.80_pnr0.50_SVM2GN.mat'));
% image = imread(fullfile(IMAGE_DIR, sprintf([IMAGE_NAMEFORM, '.', IMAGE_FORMATE], TARGET_FRAME)));
% 
% partBoxes = curDetectionResult(1).cellPBoxs{TARGET_FRAME+1};
% 
% 
% [numBoxes,~,numParts] = size(partBoxes);
% figure(10);
% imshow(image, 'border', 'tight'); hold on;
% 
% % frame information
% % text(10, 20, ...
% %     ['\fontsize{10}\color{white}' ...
% %         sprintf('frame: %03d / detected boxes: %03d', TARGET_FRAME, numBoxes)], ...
% %     'BackgroundColor', 'k');
% 
% % draw part boxes
% for bIdx = 1:numBoxes
%     curColor = GetColor(CDC, bIdx+7);
%     bRoot = true;
%     for pIdx = 1:numParts
%         curPart = partBoxes(bIdx,1:4,pIdx);
%         if 0 == curPart(3), continue; end
%         if bRoot
%             bRoot = false;
%             continue;
%         end
%         xs = [curPart(1), curPart(1)+curPart(3), curPart(1)+curPart(3), curPart(1)];
%         ys = [curPart(2), curPart(2), curPart(2)+curPart(4), curPart(2)+curPart(4)];
%         p  = patch(xs, ys, curColor);
%         set(p, 'FaceAlpha', 0.3);
%         rectangle('Position', curPart, 'EdgeColor', curColor);
%     end
% end
% hold off;
% drawnow;


% %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% %% RESULT VIDEO RECORDING
% %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% 
% 
% % load(fullfile(RESULT_DIR, 'result_hnr0.80_pnr0.50_SVM2GN.mat'));
% writerObj = VideoWriter('result_video_S2L3.avi');
% writerObj.FrameRate = 7;
% open(writerObj);
% 
% % stDetectionResult = curDetectionResult(1);
% stDetectionResult = interDetectionResult;
% 
% figFrameResult = figure;
% for frameIdx = 0:181
%     image = imread(fullfile('D:\Workspace\Dataset\PETS2009\S2\L3\Time_14-41\View_001'...
%         , sprintf([IMAGE_NAMEFORM, '.', IMAGE_FORMATE], frameIdx)));
% 
%     partBoxes = stDetectionResult.cellPBoxs{frameIdx+1};
% 
% 
%     [numBoxes,~,numParts] = size(partBoxes);
%     figure(figFrameResult);
%     imshow(image, 'border', 'tight'); hold on;
% 
%     % frame information
%     text(10, 20, ...
%         ['\fontsize{10}\color{white}' ...
%             sprintf('frame: %03d / detected boxes: %03d', frameIdx, numBoxes)], ...
%         'BackgroundColor', 'k');
% 
%     % draw part boxes
%     for bIdx = 1:numBoxes
%         curColor = GetColor(CDC, bIdx);
%         bRoot = true;
%         for pIdx = 1:numParts
%             curPart = partBoxes(bIdx,1:4,pIdx);
%             if 0 == curPart(3), continue; end
%             if bRoot
%                 bRoot = false;
%                 continue;
%             end
%             xs = [curPart(1), curPart(1)+curPart(3), curPart(1)+curPart(3), curPart(1)];
%             ys = [curPart(2), curPart(2), curPart(2)+curPart(4), curPart(2)+curPart(4)];
%             p  = patch(xs, ys, curColor);
%             set(p, 'FaceAlpha', 0.3);
%             rectangle('Position', curPart, 'EdgeColor', curColor);
%         end
%     end
%     hold off;
%     drawnow;
%     
%     writeVideo(writerObj, im2frame(zbuffer_cdata(figFrameResult)));
% end
% 
% close(writerObj);

%()()
%('') HAANJU.YOO