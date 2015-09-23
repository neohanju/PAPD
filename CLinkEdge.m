classdef CLinkEdge
    
    properties
        from = uint8(0)
        to = uint8(0)
        weight = double(0.0)
    end
    
    methods
        function CLE = CLinkEdge(from, to, weight)
            CLE.from = from;
            CLE.to = to;
            CLE.weight = weight;
        end
    end
end