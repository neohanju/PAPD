classdef CPartGraph
    
    properties
        Vertex
        Edge
    end
    
    methods
        % constructor
        function CPG = CPartGraph(listDetections, Q)            
            %==========================================
            % CANDIDATE DETECTIONS TO VERTICES
            %==========================================

            % combinations to vertices
            numDetections = size(listAssociations, 1);
            CPG.Vertex = CVertex.empty();
            for cIdx = 1:numDetections                
                CPG.Vertex(cIdx) = CVertex(cIdx, listDetections.combinations, listDetections.listPartInfo, listDetections.score);
            end
            
            %==========================================
            % ENUMERATE LINK EDGES
            %==========================================
            
            
        end
    end
end