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
    end
    methods
        function CP = CPart(component, type, coords, score, pyramidLevel, scale)
            CP.component = component;
            CP.type = type;
            CP.coords = coords;
            CP.score = score;
            CP.pyramidLevel = pyramidLevel;
            CP.scale = scale;
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
            if CP1.type == CP2.type, return; end
            
            % relative distance between two parts ('s anchors)
            anchor1 = model.defs{CP1.type-1}.anchor;
            anchor2 = model.defs{CP2.type-1}.anchor;
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
    end
end