
writerObj = VideoWriter('result_video.avi');
writerObj.FrameRate = 7;
open(writerObj);

close all;
main_init;

% stDetectionResult = curDetectionResult;

cellIdx = 0;
figFrameResult = figure;
for frameIdx = 0:435
    
    % proposed
    imagePath = fullfile(IMAGE_DIR, sprintf([IMAGE_NAMEFORM, '.', IMAGE_FORMATE], frameIdx));
    image = imread(imagePath);
    cellIdx = cellIdx + 1;
    curBBox = stDetectionResult(1).cellBBoxs{cellIdx};    
    
    imshow(image,'border','tight');
    hold on;
    for i = 1: size(curBBox, 1);
        x = curBBox(i,1) / 2.0;
        y = curBBox(i,2) / 2.0;
        w = curBBox(i,3) / 2.0;
        h = curBBox(i,4) / 2.0;
        rectangle('position', curBBox(i,1:4), 'EdgeColor', [0,1,0], 'LineWidth', 2.5);
    end

    
    
    % DPM
    
    partPath = fullfile(PARTCANDIDATE_DIR, sprintf(PARTCANDIDATE_FORM, frameIdx));
    load(partPath);
    dets = coords([1:4 end-1 end],:)';
    I = nms(dets, 0.5);
    for i = 1:length(I)
        x = coords(1,I(i)) / 2.0;
        y = coords(2,I(i)) / 2.0;
        w = coords(3,I(i)) / 2.0 - x + 1;
        h = coords(4,I(i)) / 2.0 - y + 1;
        rectangle('position', [x,y,w,h], 'EdgeColor', [1,0,0], 'LineWidth', 1.5);
    end


% GT

    
    curGTs = cellGroundTruths{frameIdx + 1};
    curGTs(:,1:2) = [curGTs(:,1) - curGTs(:,3)/2, curGTs(:,2) - curGTs(:,4)/2]; 
    for i = 1: size(curGTs, 1)
        x = curGTs(i,1);
        y = curGTs(i,2);
        w = curGTs(i,3);
        h = curGTs(i,4);
        rectangle('position', curGTs(i,:), 'EdgeColor', [0,0,0]);
    end
    
    % frame information
    text(10, 20, ...
        ['\fontsize{10}\color{white}' ...
        sprintf('frame: %03d', frameIdx)], ...
        'BackgroundColor', 'k');
    
    hold off;
    
    writeVideo(writerObj, im2frame(zbuffer_cdata(figFrameResult)));
%         pause;
end
close(writerObj);