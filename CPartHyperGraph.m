classdef CPartHyperGraph
    
    properties
        HyperEdges
        LinkEdges        
    end
    
    methods
        % constructor
        function CPHG = CPartHyperGraph(listPartInfos, cellIndexAmongType)            
            
            numHyperEdges = 0;
            numLinkEdges = 0;
            
            [numPartTypes, numComponents] = size(cellIndexAmongType);
            
            %==========================================
            % ENUMERATE HYPER EDGES
            %==========================================
            
            % head 반드시 포함되게 할 것, root는 고려하지 않을 것
            
            % generate configurations
            configurations = zeros(2^(numPartTypes-2), numPartTypes);
            combinations = [];
            for cIdx = 1:size(configurations, 1)
                flags = ['01', dec2bin(cIdx-1, numPartTypes-2)];                 
                for typeIdx = 1:numPartTypes
                    configurations(cIdx,typeIdx) = str2double(flags(typeIdx));
                    if 0 == configurations(cIdx,typeIdx), continue; end
                    
                    newCombinations = [];
                    for partIdx = cellIndexAmongType{typeIdx}
                        for combIdx = 1:size(combinations, 1)
                            curNewCombination = combinations(combIdx);
                            curNewCombination(typeIdx) = partIdx;
                            newCombinations = [newCombinations; curNewCombination];
                        end
                    end
                    
                    combinations = newCombinations;
                end
            end
            
%             % generate part associations
%             combinations = [];
%             for cIdx = 1:size(configurations, 1)
%                 
%             end
%             
%             % by hard coding
%             numParts = 18;
%             partTypes = [listPartInfos(:).type];
%             partFlips = [listPartInfos(:).flip];
%             CellParts = cell(numParts);
%             CellParts{1} = listPartInfos('root' == partTypes & false == partFlips);
%             CellParts{2} = listPartInfos('head' == partTypes & false == partFlips);
%             CellParts{3} = listPartInfos('shoulder1' == partTypes & false == partFlips);
%             CellParts{4} = listPartInfos('shoulder2' == partTypes & false == partFlips);
%             CellParts{5} = listPartInfos('arm1' == partTypes & false == partFlips);
%             CellParts{6} = listPartInfos('arm2' == partTypes & false == partFlips);
%             CellParts{7} = listPartInfos('foot1' == partTypes & false == partFlips);
%             CellParts{8} = listPartInfos('foot2' == partTypes & false == partFlips);
%             CellParts{9} = listPartInfos('groin' == partTypes & false == partFlips);
%             
%             CellParts{10} = listPartInfos('root' == partTypes & true == partFlips);
%             CellParts{11} = listPartInfos('head' == partTypes & true == partFlips);
%             CellParts{12} = listPartInfos('shoulder1' == partTypes & true == partFlips);
%             CellParts{13} = listPartInfos('shoulder2' == partTypes & true == partFlips);
%             CellParts{14} = listPartInfos('arm1' == partTypes & true == partFlips);
%             CellParts{15} = listPartInfos('arm2' == partTypes & true == partFlips);
%             CellParts{16} = listPartInfos('foot1' == partTypes & true == partFlips);
%             CellParts{17} = listPartInfos('foot2' == partTypes & true == partFlips);
%             CellParts{18} = listPartInfos('groin' == partTypes & true == partFlips);
%             
%             % generate pairwise associations
%             stAssociationPair = struct('front', 0, 'back', 0);
%             numAssociationPairs = 0;
%             for partTypeIdx1 = 1 : numParts-1
%                 compPart1 = CellParts{partTypeIdx1};
%                 for partType2 = pIdx1+1 : numParts
%                     compPart2 = CellParts{partTypeIdx2};                    
%                     for partIdx1 = 1:length(compPart1)
%                         for partIdx2 = 1:length(compPart2)
%                         end
%                     end
%                 end
%             end
            
        end
    end
end