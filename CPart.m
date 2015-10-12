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
    end
    methods
        function CP = CPart(component, type, coords, score, pyramidLevel, scale, a2p)
            CP.component = component;
            CP.type = type;
            CP.coords = coords;
            CP.score = score;
            CP.pyramidLevel = pyramidLevel;
            CP.scale = scale;
            CP.a2p = a2p;
        end
        function box = GetBox(CP)
            x = CP.coords(1);
            y = CP.coords(2);
            w = CP.coords(3) - CP.coords(1) + 1;
            h = CP.coords(4) - CP.coords(2) + 1;
            box = [x, y, w, h];
        end
        function resultFlag = IsAssociable(CP1, CP2, model)
            resultFlag = false;
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
            
            resultFlag = true;
        end
        function bNeighbor = IsNeighbor(CP1, CP2, model, overlapRatio, image)
            bNeighbor = false;
            rootSize = model.rootfilters{1}.size(end:-1:1) * 2; % {1} for component 1, and x2 to match the resolution with parts
            root1Pos = [CP1.coords(1), CP1.coords(2)] - CP1.a2p * model.defs{CP1.type-1+(CP1.component-1)*8}.anchor;
            root2Pos = [CP2.coords(1), CP2.coords(2)] - CP2.a2p * model.defs{CP2.type-1+(CP2.component-1)*8}.anchor;
            root1Size = CP1.a2p * rootSize;
            root2Size = CP2.a2p * rootSize;
            root1Coords = [root1Pos, root1Pos + root1Size];
            root2Coords = [root2Pos, root2Pos + root2Size];
            
%             figure(1); imshow(image, 'border', 'tight');
%             headbox1 = GetBox(CP1) / 2;
%             headbox2 = GetBox(CP2) / 2;
%             rectangle('Position', headbox1, 'EdgeColor', [1, 0, 0]);
%             rectangle('Position', headbox2, 'EdgeColor', [0, 1, 0]);
%             rectangle('Position', [root1Rect(1),root1Rect(2),root1Size(1),root1Size(2)]/2, 'EdgeColor', [1, 0, 0]);
%             rectangle('Position', [root2Rect(1),root2Rect(2),root2Size(1),root2Size(2)]/2, 'EdgeColor', [0, 1, 0]);
            
            if CheckOverlap(root1Coords, root2Coords, overlapRatio), bNeighbor = true; end
        end
    end
end