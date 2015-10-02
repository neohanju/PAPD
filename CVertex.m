classdef CVertex
    properties
        id
        configuration
        partInfos
        weight
        adjacentVetices
        edges
    end
    methods
        function CV = CVertex(id, configuration, listPartInfo, weight)
            CV.id = id;
            CV.configuration = configuration;
            CV.partInfos = listPartInfo;
            CV.weight = weight;
            CV.adjacentVetices = [];
            CV.edges = [];
        end
        function CV = refresh(CV)
            CV.adjacentVetices = unique(CV.adjacentVetices);
            CV.adjacentVetices = sort(CV.adjacentVetices, 'ascend');
            CV.edges = unique(CV.edges);
            CV.edges = sort(CV.edges, 'ascend');
        end
    end
end