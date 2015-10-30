function ShowFrameResult(image, frameIdx, partBoxes, figHandle, CDC)

[numBoxes,~,numParts] = size(partBoxes);
figure(figHandle);
imshow(image, 'border', 'tight'); hold on;

% frame information
text(10, 20, ...
    ['\fontsize{10}\color{white}' ...
        sprintf('frame: %03d / detected boxes: %03d', frameIdx, numBoxes)], ...
    'BackgroundColor', 'k');

% draw part boxes
for bIdx = 1:numBoxes
    curColor = GetColor(CDC, bIdx);
    for pIdx = 1:numParts
        curPart = partBoxes(bIdx,:,pIdx);
        if 0 == curPart(3), continue; end
        rectangle('Position', curPart, 'EdgeColor', curColor);
    end
end
hold off;
drawnow;
end