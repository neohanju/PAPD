classdef CPart
    properties
        component
        type
        % 1:root        2:head      3:foot1     4:shoulder1     5:groin
        % 6:shouler2    7:arm1      8:arm2      9:foot2
        coords = zeros(1,4) % [x1, y1, x2, y2]
        score
        pyramidLevel
        scale
        a2p % anchor scale to pixel scale
        rootID
    end
    methods
        function CP = CPart(component, type, coords, score, pyramidLevel, scale, a2p, rootID)
            CP.component = component;
            CP.type = type;
            CP.coords = coords;
            CP.score = score;
            CP.pyramidLevel = pyramidLevel;
            CP.scale = scale;
            CP.a2p = a2p;                       
            if nargin == 8
                CP.rootID = rootID;
            end
        end        
        function box = GetBox(CP)
            box = Coords2Rect(CP.coords);
        end
        function coords = EstimatePartCoords(basisPart, targetPartType, targetComponent, model)
            % find location of the target part
            anchorBasis = [0, 0];
            if 1 ~= basisPart.type
                anchorBasis = model.defs{basisPart.type-1+(basisPart.component-1)*8}.anchor;
            end
            anchorPart = model.defs{targetPartType-1+(targetComponent-1)*8}.anchor;
            vecAnchorDiff = anchorPart - anchorBasis;
            partLocation = basisPart.coords(1:2) + basisPart.a2p * vecAnchorDiff;
            
            % target part size in anchor domain (w=6/h=6)
            partSize = basisPart.a2p * 6;
            
            % estimated part position
            coords = [partLocation, partLocation + [partSize, partSize]];
        end
        function bAssociable = IsAssociable(CP1, CP2, model)
            bAssociable = false;
            if CP1.type == CP2.type || CP1.component ~= CP2.component, return; end
            
            % relative distance between two parts ('s anchors)
            anchor1 = model.defs{CP1.type-1+(CP1.component-1)*8}.anchor;
            anchor2 = model.defs{CP2.type-1+(CP2.component-1)*8}.anchor;
            vecAnchorDiff = anchor2 - anchor1;
            
            % relative center distance 
            center1 = 0.5*[(CP1.coords(1)+CP1.coords(3)), (CP1.coords(2)+CP1.coords(4))];
            center2 = 0.5*[(CP2.coords(1)+CP2.coords(3)), (CP2.coords(2)+CP2.coords(4))];            
            vecCenterDiff = 2 * CP1.scale * (center2 - center1) / model.sbin;
            
            % displacement between desired part center and real center
            displacement = abs(vecAnchorDiff - vecCenterDiff);
            
            % thresholds (to be designed)
            xThre = 9;
            yThre = 9;
            if displacement(1) > xThre || displacement(2) > yThre, return; end;
            
            bAssociable = true;
        end
%         function bNeighbor = IsNeighbor(CP1, CP2, model, overlapRatio)
%             bNeighbor = false;
%             rootSize = model.rootfilters{1}.size(end:-1:1) * 2; % {1} for component 1, and x2 to match the resolution with parts
%             root1Pos = [CP1.coords(1), CP1.coords(2)] - CP1.a2p * model.defs{CP1.type-1+(CP1.component-1)*8}.anchor;
%             root2Pos = [CP2.coords(1), CP2.coords(2)] - CP2.a2p * model.defs{CP2.type-1+(CP2.component-1)*8}.anchor;
%             root1Size = CP1.a2p * rootSize;
%             root2Size = CP2.a2p * rootSize;
%             root1Coords = [root1Pos, root1Pos + root1Size];
%             root2Coords = [root2Pos, root2Pos + root2Size];
%             
% %             figure(1); imshow(image, 'border', 'tight');
% %             headbox1 = GetBox(CP1) / 2;
% %             headbox2 = GetBox(CP2) / 2;
% %             rectangle('Position', headbox1, 'EdgeColor', [1, 0, 0]);
% %             rectangle('Position', headbox2, 'EdgeColor', [0, 1, 0]);
% %             rectangle('Position', [root1Rect(1),root1Rect(2),root1Size(1),root1Size(2)]/2, 'EdgeColor', [1, 0, 0]);
% %             rectangle('Position', [root2Rect(1),root2Rect(2),root2Size(1),root2Size(2)]/2, 'EdgeColor', [0, 1, 0]);
%             
%             if CheckOverlap(root1Coords, root2Coords, overlapRatio), bNeighbor = true; end
%         end
        function bCompatible = IsCompatible(CP1, CP2, partOverlapRatio)
            bCompatible = ~CheckOverlap(CP1.coords, CP2.coords, partOverlapRatio);
        end
    end
end