classdef CDetection
    properties
        combination
        score
    end
    methods
        function CD = CDetection(combination, score)
            CD.combination = combination;
            CD.score = score;
        end
        function bCompatible = IsCompatible(CD1, CD2, listCPart, partOveralapRatio)
            bCompatible = true;            
            % check common part
            commons = intersect(CD1.combination, CD2.combination);
            if ~isempty(commons(0 < commons))
                bCompatible = false;
                return; 
            end
            % check parts overlap
            for p1 = CD1.combination(0 < CD1.combination)                
                for p2 = CD2.combination(0 < CD2.combination)                    
                    if ~IsCompatible(listCPart(p1), listCPart(p2), partOveralapRatio)
                        bCompatible = false;
                        return;
                    end
                end
            end
        end
        function numOccParts = NumOccludedParts(CD1, CD2, listCPart, model, partOverlapRatio) %, image)
            numOccParts = 0;
            occludedType1 = find(0 == CD1.combination); occludedType1(1) = []; % except root
            occludedType2 = find(0 == CD2.combination); occludedType2(1) = [];
            visibleType1 = find(0 ~= CD1.combination);
            visibleType2 = find(0 ~= CD2.combination);
            det1Component = listCPart(CD1.combination(2)).component;
            det2Component = listCPart(CD2.combination(2)).component;
            det1HeadIdx = CD1.combination(2);
            det2HeadIdx = CD2.combination(2);
            
            % find occluded parts of detection 1 by detection 2
            for occT1 = occludedType1
                estimatedCoords = EstimatePartCoords( ...
                    listCPart(det1HeadIdx), occT1, det1Component, model);
                for visT2 = visibleType2
                    if CheckOverlap(listCPart(CD2.combination(visT2)).coords, ...
                            estimatedCoords, partOverlapRatio);
                        
%                         % debug display
%                         figure(40); clf; imshow(image, 'border', 'tight');
%                         hold on;
%                         rectangle('Position', Coords2Rect(estimatedCoords)/2, 'EdgeColor', [1, 1, 1]);
%                         rectangle('Position', Coords2Rect(listCPart(CD2.combination(visT2)).coords)/2, ...
%                             'EdgeColor', [1, 0, 0]);
%                         hold off;
%                         pause;
%                         %%%
                        numOccParts = numOccParts + 1;
                        break;
                    end
                end
            end
            
            % find occluded parts of detection 2 by detection 1
            for occT2 = occludedType2
                estimatedCoords = EstimatePartCoords( ...
                    listCPart(det2HeadIdx), occT2, det2Component, model);
                for visT1 = visibleType1
                    if CheckOverlap(listCPart(CD1.combination(visT1)).coords, ...
                            estimatedCoords, partOverlapRatio);
                        numOccParts = numOccParts + 1;
                        break;
                    end
                end
            end
        end
        function ShowDetection(CD, listCPart, image, rescale, figID)
            if nargin < 5
                figure;
            else
                figure(figID);
            end
            if nargin < 4, rescale = 1.0; end
            imshow(image, 'border', 'tight');
            hold on;
            for pIdx = CD.combination(0 < CD.combination)
                curColor = [1, 1, 1];
                if 1 == listCPart(pIdx).type, curColor = [1, 0, 0]; end
                rectangle('Position', rescale*Coords2Rect(listCPart(pIdx).coords), 'EdgeColor', curColor);
            end
            hold off;
        end
    end
end