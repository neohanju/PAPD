classdef CPart
    properties
        component 
        type
        % 1:root        2:head      3:foot1     4:shoulder1     5:groin
        % 6:shouler2    7:arm1      8:arm2      9:foot2
        coords = zeros(1,4) % [x1, y1, x2, y2]
        score
    end
    methods
        function CP = CPart(component, type, coords, score)
            CP.component = component;
            CP.type = type;
            CP.coords = coords;
            CP.score = score;
        end
        function box = GetBox(CP)
            x = CP.coords(1);
            y = CP.coords(2);
            w = CP.coords(3) - CP.coords(1) + 1;
            h = CP.coords(4) - CP.coords(2) + 1;
            box = [x, y, w, h];
        end
        function resultFlag = CheckCompatibility(CP1, CP2)
            maxDistance = 150;
            maxOverlap = 0.3;
            
            pos1 = [CP1.coords(1), CP1.coords(2)];
            pos2 = [CP2.coords(1), CP2.coords(2)];
            resultFlag = true;
            
            % distance
            if norm(pos1 - pos2, 2) > maxDistance, resultFlag = false; return; end
            
            % overlap
            area1 = (CP1.coords(3)-CP1.coords(1)+1) * (CP1.coords(4)-CP1.coords(2)+1);
            area2 = (CP2.coords(3)-CP2.coords(1)+1) * (CP2.coords(4)-CP2.coords(2)+1);
            w = min(CP1.coords(3), CP2.coords(3)) - max(CP1.coords(1), CP2.coords(1));
            h = min(CP1.coords(4), CP2.coords(4)) - max(CP1.coords(2), CP2.coords(2));
            overlap = (w * h) / min(area1, area2);
            if overlap > maxOverlap, resultFlag = false; return; end
            
            % relative position
            heightOrder = [1, 1, 5, 2, 4, 2, 3, 3, 5];
            if heightOrder(CP1.type) < heightOrder(CP2.type)
                if CP1.coords(2) < CP2.coords(2), resultFlag = false; return; end
            elseif heightOrder(CP1.type) > heightOrder(CP2.type)
                if CP1.coords(2) > CP2.coords(2), resultFlag = false; return; end
            end
        end
    end
end