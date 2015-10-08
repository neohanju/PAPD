classdef CVertex
    properties
        id
        combination
        partInfos
        weight
        adjacentVetices
        edges
    end
    methods
        function CV = CVertex(id, combination, listPartInfo, weight)
            CV.id = id;
            CV.combination = combination;
            CV.partInfos = listPartInfo;
            CV.weight = weight;
            CV.adjacentVetices = [];
            CV.edges = [];
        end
        function CV = update(CV)
            CV.adjacentVetices = unique(CV.adjacentVetices);
            CV.adjacentVetices = sort(CV.adjacentVetices, 'ascend');
            CV.edges = unique(CV.edges);
            CV.edges = sort(CV.edges, 'ascend');
        end
    end
end