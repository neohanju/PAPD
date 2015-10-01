classdef CPartHyperGraph
    
    properties
        HyperEdges
        LinkEdges        
    end
    
    methods
        % constructor
        function CPHG = CPartHyperGraph(listPartInfos, cellIndexAmongType)            
            
            [numPartTypes, numComponents] = size(cellIndexAmongType);
            numHyperEdges = 0;
            numLinkEdges = 0;            
            
            %==========================================
            % ENUMERATE HYPER EDGES
            %==========================================
                       
            % generate configurations
            % (head 반드시 포함되게 할 것, root는 고려하지 않을 것)
            configurations = zeros(numComponents*2^(numPartTypes-2), numPartTypes);
            for cIdx = 1:size(configurations, 1)
                flags = ['01', dec2bin(cIdx-1, numPartTypes-2)];                    
                for typeIdx = 1:numPartTypes
                    configurations(cIdx,typeIdx) = str2double(flags(typeIdx));                        
                end                    
            end
            
            % generate combinations 
            % (apart from configuration generation for the combinience of the code readability)
            combinations = [];
            for componentIdx = 1:numComponents
                fprintf('Component: %d/%d\n', componentIdx, numComponents);
                for cIdx = 1:size(configurations, 1)
                    fprintf('Configuration: %d/%d:...', cIdx, size(configurations, 1));
                    combinationsInCurConfiguration = zeros(1, numPartTypes);
                    for typeIdx = 1:numPartTypes
                        % bit check                        
                        if 0 == configurations(cIdx,typeIdx), continue; end

                        % generate new combinations with boxes of the current part type
                        numNewCombinations = size(combinationsInCurConfiguration, 1)...
                            *length(cellIndexAmongType{typeIdx,componentIdx});
                        newCombinations = zeros(numNewCombinations, numPartTypes);
                        newCombinationIdx = 0;                        
                        for combIdx = 1:size(combinationsInCurConfiguration, 1)
                            curCombination = combinationsInCurConfiguration(combIdx,:);
                            for partIdx = cellIndexAmongType{typeIdx,componentIdx}   
                                % check compatibility between parts
                                bIsCompatible = true;
                                for preInsertedPartIdx = curCombination                                    
                                    if 0 == preInsertedPartIdx, continue; end
                                    bIsCompatible = CheckCompatibility(...
                                        listPartInfos(preInsertedPartIdx), listPartInfos(partIdx));
                                    if ~bIsCompatible, break; end
                                end                                
                                if ~bIsCompatible, continue; end
                                
                                % save combination
                                newCombinationIdx = newCombinationIdx + 1;
                                newCombinations(newCombinationIdx,:) = curCombination;
                                newCombinations(newCombinationIdx,typeIdx) = partIdx;
                            end
                        end                    
                        combinationsInCurConfiguration = newCombinations;
                    end
                    fprintf('%d sets are made\n', size(combinationsInCurConfiguration, 1));
                    combinations = [combinations; combinationsInCurConfiguration];
                end
            end
            
            %==========================================
            % ENUMERATE LINK EDGES
            %==========================================
            
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