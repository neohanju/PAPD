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
%% OVERLAP CHECK
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%




% %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% %% TEASURE: PART COMBINATIONS
% %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% TARGET_FRAME = 80;
% IMAGE_RESIZE = 2.0;
% CROP_CENTER = [627, 310] * IMAGE_RESIZE;
% CROP_ZONE = round([CROP_CENTER(1)-75, CROP_CENTER(1)+75-1, CROP_CENTER(2)-130, CROP_CENTER(2)+130-1]);
% CROP_WIDTH = CROP_ZONE(2) - CROP_ZONE(1) + 1;
% CROP_HEIGHT = CROP_ZONE(4) - CROP_ZONE(3) + 1;
% 
% % load target frame
% image = imread(fullfile(IMAGE_DIR, sprintf([IMAGE_NAMEFORM, '.', IMAGE_FORMATE], TARGET_FRAME)));
% cropImage = imresize(image, IMAGE_RESIZE);
% cropImage = cropImage(CROP_ZONE(3):CROP_ZONE(4),CROP_ZONE(1):CROP_ZONE(2),:);
% [imgH,imgW,~] = size(cropImage);
% 
% % load detections
% load('ForFigure.mat'); detections = cellListDetections{6};
% 
% numDetections = length(detections);
% if 0 == numDetections, return, end;
% numParts = length(detections(1).combination);
% partColors = colormap(parula(numParts));
% 
% %=======================================
% % DRAW COMBINATIONS
% %=======================================
% for dIdx = 1:numDetections    
%     fCombination = figure(100+dIdx);    
%     set(fCombination, 'position', [20*dIdx, 400, imgW,imgH], 'units', 'normalized');
%     imshow(cropImage, 'border', 'tight');
%     hold on;
%     for typeIdx = 2:numParts
%         if 0 == detections(dIdx).combination(typeIdx), continue; end
%         curBox = GetBox(listCParts(detections(dIdx).combination(typeIdx)))/2.0*IMAGE_RESIZE;
%         curBox(1) = curBox(1) - CROP_ZONE(1) + 1;
%         curBox(2) = curBox(2) - CROP_ZONE(3) + 1;
%         rectangle('position', curBox, 'EdgeColor', partColors(typeIdx,:), 'LineWidth', 2.0);
%     end
%     hold off;
%     drawnow;
%     resultImage = frame2im(getframe(gcf));    
%     imwrite(resultImage, ...
%         fullfile('D:\Workspace\SNU_PIL\UnderConstruction\150919_[LATEX]_CVPR_PAPD\figures', ...
%         sprintf('part_combination_%03d.png', dIdx)));
%     pause(0.5);
% end


% %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% %% TEASURE: PART RESPONSES
% %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% TARGET_FRAME = 80;
% IMAGE_RESIZE = 2.0;
% CROP_CENTER = [627, 310] * IMAGE_RESIZE;
% CROP_ZONE = round([CROP_CENTER(1)-75, CROP_CENTER(1)+75-1, CROP_CENTER(2)-130, CROP_CENTER(2)+130-1]);
% CROP_WIDTH = CROP_ZONE(2) - CROP_ZONE(1) + 1;
% CROP_HEIGHT = CROP_ZONE(4) - CROP_ZONE(3) + 1;
% 
% % load target frame
% image = imread(fullfile(IMAGE_DIR, sprintf([IMAGE_NAMEFORM, '.', IMAGE_FORMATE], TARGET_FRAME)));
% [imgH,imgW,~] = size(image);
% cropImage = imresize(image, IMAGE_RESIZE);
% cropImage = cropImage(CROP_ZONE(3):CROP_ZONE(4),CROP_ZONE(1):CROP_ZONE(2),:);
% 
% % load parts
% partPath = fullfile(PARTCANDIDATE_DIR, sprintf(PARTCANDIDATE_FORM, TARGET_FRAME));
% load(partPath);
% partDetections.partscores = partscores;
% partDetections.coords     = coords;
% partDetections.scale      = PARTCANDIDATE_SCALE;
% 
% [numPartTypes, numRoots] = size(partscores);
% numPartTypes = numPartTypes - 1; % exclude "pyramidLevel"
% parts        = cell(numPartTypes, 1);
% partColors   = colormap(parula(9));
% 
% for rootIdx = 1:numRoots
%     typeOffset = 1;    
%     for typeIdx = 1:numPartTypes
%         curCoord = coords(typeOffset:typeOffset+3,rootIdx)'/2.0;
%         parts{typeIdx} = [parts{typeIdx}; curCoord];
%         typeOffset = typeOffset + 4;
%     end
% end
% 
% % draw parts
% figCurrent = figure(1); clf; imshow(image, 'border', 'tight'); hold on;
% set(figCurrent, 'position', [20, 400, imgW,imgH], 'units', 'normalized');
% for typeIdx = 2:numPartTypes
%     for partIdx = 1:size(parts{typeIdx}, 1)
%         x = max(1, parts{typeIdx}(partIdx,1));
%         y = max(1, parts{typeIdx}(partIdx,2));
%         w = min(parts{typeIdx}(partIdx,3) - x + 1, imgW - x);
%         h = min(parts{typeIdx}(partIdx,4) - y + 1, imgH - y);
%         rectangle('position', [x,y,w,h], 'EdgeColor', partColors(typeIdx,:));
%     end    
% end
% hold off;
% 
% 
% % draw parts
% figCrop = figure(2); clf; imshow(cropImage, 'border', 'tight'); hold on;
% set(figCrop, 'position', [imgW + 30, 400, CROP_WIDTH, CROP_HEIGHT], 'units', 'normalized');
% for typeIdx = 1:numPartTypes        
%     for partIdx = 2:size(parts{typeIdx}, 1)
%         x = parts{typeIdx}(partIdx,1)*IMAGE_RESIZE; 
%         y = parts{typeIdx}(partIdx,2)*IMAGE_RESIZE; 
%         w = parts{typeIdx}(partIdx,3)*IMAGE_RESIZE - x + 1;
%         h = parts{typeIdx}(partIdx,4)*IMAGE_RESIZE - y + 1;
%         x = x - CROP_ZONE(1) + 1; if x < 0, continue; end
%         y = y - CROP_ZONE(3) + 1; if y < 0, continue; end
%         rectangle('position', [x,y,w,h], 'EdgeColor', partColors(typeIdx,:));
%     end
% end
% hold off;

% %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% %% FOR OVERALL
% %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% TARGET_FRAME = 80;
% IMAGE_RESIZE = 2.0;
% CROP_CENTER = [627, 300] * IMAGE_RESIZE;
% CROP_ZONE = round([CROP_CENTER(1)-75, CROP_CENTER(1)+75-1, CROP_CENTER(2)-130, CROP_CENTER(2)+130-1]);
% CROP_WIDTH = CROP_ZONE(2) - CROP_ZONE(1) + 1;
% CROP_HEIGHT = CROP_ZONE(4) - CROP_ZONE(3) + 1;
% 
% % load target frame
% image = imread(fullfile(IMAGE_DIR, sprintf([IMAGE_NAMEFORM, '.', IMAGE_FORMATE], TARGET_FRAME)));
% cropImage = imresize(image, IMAGE_RESIZE);
% cropImage = cropImage(CROP_ZONE(3):CROP_ZONE(4),CROP_ZONE(1):CROP_ZONE(2),:);
% 
% % load parts
% partPath = fullfile(PARTCANDIDATE_DIR, sprintf(PARTCANDIDATE_FORM, TARGET_FRAME));
% load(partPath);
% partDetections.partscores = partscores;
% partDetections.coords     = coords;
% partDetections.scale      = PARTCANDIDATE_SCALE;
% 
% [numPartTypes, numRoots] = size(partscores);
% numPartTypes = numPartTypes - 1; % exclude "pyramidLevel"
% parts        = cell(numPartTypes, 1);
% for rootIdx = 1:numRoots
%     typeOffset = 1;    
%     for typeIdx = 1:numPartTypes
%         curCoord = coords(typeOffset:typeOffset+3,rootIdx)'/2.0 * IMAGE_RESIZE;
%         parts{typeIdx} = [parts{typeIdx}; curCoord];
%         typeOffset = typeOffset + 4;               
%     end
%     
% end
% 
% % draw parts
% for typeIdx = 1:numPartTypes
%     figCurrent = figure(typeIdx); imshow(cropImage, 'border', 'tight'); hold on;
%     set(figCurrent, 'position', [typeIdx*(CROP_WIDTH+4)-CROP_WIDTH, 400, CROP_WIDTH, CROP_HEIGHT]);
%     for partIdx = 1:size(parts{typeIdx}, 1)
%         x = parts{typeIdx}(partIdx,1);
%         y = parts{typeIdx}(partIdx,2);
%         w = parts{typeIdx}(partIdx,3) - x + 1;
%         h = parts{typeIdx}(partIdx,4) - y + 1;
%         x = x - CROP_ZONE(1) + 1;
%         y = y - CROP_ZONE(3) + 1;
%         rectangle('position', [x,y,w,h], 'EdgeColor', [1.0,1.0,1.0]);
%     end
%     hold off;
% end



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