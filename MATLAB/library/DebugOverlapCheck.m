function DebugOverlapCheck(image, CD1, CD2, listCParts, imageResize, rescaleForSpeedup)

numParts = numel(CD1.combination)-1;
coords1 = zeros(numParts, 4);
coords2 = zeros(numParts, 4);
for p = 2:numParts+1
    if 0 < CD1.combination(p)
        coords1(p-1,:) = listCParts(CD1.combination(p)).coords;
    end
    if 0 < CD2.combination(p)
        coords2(p-1,:) = listCParts(CD2.combination(p)).coords;
    end
end

overlapImage = imresize(image, imageResize);
textInfo = zeros(numParts, 3);

for c1 = 1:numParts
    curCoords1 = rescaleForSpeedup * coords1(c1,:);
    c1x1 = round(curCoords1(1));
    c1x2 = round(curCoords1(3));
    if 0 == c1x1 && 0 == c1x2, continue; end
    c1y1 = round(curCoords1(2));    
    c1y2 = round(curCoords1(4));
    w = c1x2 - c1x1 + 1;
    h = c1y2 - c1y1 + 1;
    occRegion = zeros(h, w);
    
    for c2 = 1:numParts
        curCoords2 = rescaleForSpeedup * coords2(c2,:);
        c2x1 = round(curCoords2(1));
        c2x2 = round(curCoords2(3));        
        if 0 == c2x1 && 0 == c2x2, continue; end
        c2y1 = round(curCoords2(2));
        c2y2 = round(curCoords2(4));
        x1 = max(c1x1, c2x1);
        y1 = max(c1y1, c2y1);
        x2 = min(c1x2, c2x2);
        y2 = min(c1y2, c2y2);
        commonW = x2 - x1 + 1;
        commonH = y2 - y1 + 1;
        if commonW > 0 && commonH > 0
            commnX = x1 - c1x1 + 1;
            commnY = y1 - c1y1 + 1;
            occRegion(commnY:commnY+commonH-1,commnX:commnX+commonW-1) = 1.0;
        end
    end
    
    overlapImage(c1y1:c1y1+h-1,c1x1:c1x1+w-1,1) = overlapImage(c1y1:c1y1+h-1,c1x1:c1x1+w-1,1) + uint8(200 * occRegion);
    textInfo(c1,1) = (c1x1 + w/2)/imageResize;
    textInfo(c1,2) = (c1y1 + h/2)/imageResize;
    textInfo(c1,3) = sum(sum(occRegion)) / (w * h);
end

figure(987); clf; imshow(image, 'border', 'tight'); hold on; 
ShowDetection(CD1,listCParts,image,1/imageResize);  hold off;
figure(988); clf; imshow(image, 'border', 'tight'); hold on; 
ShowDetection(CD2,listCParts,image,1/imageResize);  hold off;

overlapImage = imresize(overlapImage, 1/imageResize);
figure(989); clf; imshow(overlapImage, 'border', 'tight'); hold on;
for p = 1:numParts
    x = coords2(p,1)/imageResize;
    y = coords2(p,2)/imageResize;
    w = coords2(p,3)/imageResize - x + 1;
    h = coords2(p,4)/imageResize - y + 1;
    rectangle('position', [x,y,w,h], 'EdgeColor', [1,1,1]);
end
for c1 = 1:numParts    
    text(textInfo(c1,1), textInfo(c1,2), ...
    ['\fontsize{10}\color{white}' sprintf('%1.2f', textInfo(c1,3))], ...
    'BackgroundColor', 'k');
end
hold off;

end