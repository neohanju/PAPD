function [cellGTs] = GrountTruth_Xml2Mat(filePath)
% Make groundtruth cellGTs
xDoc   = xmlread(filePath);
xRoot  = xDoc.getDocumentElement;
xFrame = xRoot.getChildNodes;
numFrames = (xFrame.getLength-1)/2;
cellGTs = cell(numFrames, 1);
for fIdx = 1:numFrames
    i = 2*fIdx-1;
%     frameNumber = xFrame.item(i).getAttribute('number');
    xObject = xFrame.item(i).getChildNodes.item(1).getChildNodes;
    numObjects = (xObject.getLength-1)/2;

    gtResult = zeros(numObjects, 4);
    for objIdx = 1:numObjects
        n = 2*objIdx-1;
%         id = str2double(xObject.item(n).getAttribute('id'));
        h  = str2double(xObject.item(n).getChildNodes.item(1).getAttribute('h'));
        w  = str2double(xObject.item(n).getChildNodes.item(1).getAttribute('w'));
        xc = str2double(xObject.item(n).getChildNodes.item(1).getAttribute('xc'));
        yc = str2double(xObject.item(n).getChildNodes.item(1).getAttribute('yc'));
%         gtResult(objIdx,:) = [id xc yc w h];
        gtResult(objIdx,:) = [xc yc w h];
    end
    cellGTs{fIdx} = gtResult;
end

end