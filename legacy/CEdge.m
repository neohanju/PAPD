classdef CEdge
    properties
        id
        vertices
        weight
    end
    methods
        function CE = CEdge(id, CV1, CV2, weight)
            CE.id = id;
            CE.vertices = [CV1.id, CV2.id];
            CE.weight = weight;
            
            CV1.edges = [CV1.edges, CE.id];
            CV2.edges = [CV2.edges, CE.id];
            CV1.adjacentVetices = [CV1.adjacentVetices, CV2.id];
            CV2.adjacentVetices = [CV2.adjacentVetices, CV1.id];
        end
    end
end