classdef CPart
    
    properties
        component 
        type
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
    end
end