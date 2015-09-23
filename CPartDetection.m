classdef CPartDetection
    
    properties
        type @char
        box = [0.0, 0.0, 0.0, 0.0]
        patch = []
        score = 0.0
    end
    
    methods
        function CPD = CPartDetection(type, box, patch, score)
            CPD.type = type;
            CPD.box = box;
            CPD.patch = patch;
            CPD.score = score;
        end
    end
end