classdef CHyperEdge
    
    properties
        configurations
        parts
        weight = double(0.0)
    end
    
    methods
        function CHE = CHyperEdge(partInfos)
            CHE.parts = partInfos;
            % TODO: calculate weight of hyper edge
            CHE.weight = 0;
        end
    end
end