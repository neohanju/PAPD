classdef CDetection
    properties
        combination        
        score        
    end
    methods
        function CV = CDetection(combination, score)
            CV.combination = combination;            
            CV.score = score;
        end
    end
end