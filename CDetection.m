classdef CDetection
    properties
        combination
        partInfos
        score        
    end
    methods
        function CV = CDetection(combination, listPartInfo, score)
            CV.combination = combination;
            CV.partInfos = listPartInfo;
            CV.score = score;            
        end
    end
end