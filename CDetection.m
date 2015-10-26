classdef CDetection
    % .__                           __.
    %   \ `\~~---..---~~~~~~--.---~~| /   
    %    `~-.   `                   .~         _____ 
    %        ~.                .--~~    .---~~~    /
    %         / .-.      .-.      |  <~~        __/
    %        |  |_|      |_|       \  \     .--'
    %       /-.      -       .-.    |  \_   \_
    %       \-'   -..-..-    `-'    |    \__  \_ 
    %        `.                     |     _/  _/
    %          ~-                .,-\   _/  _/
    %         /                 -~~~~\ /_  /_
    %        |               /   |    \  \_  \_ 
    %        |   /          /   /      | _/  _/
    %        |  |          |   /    .,-|/  _/ 
    %        )__/           \_/    -~~~| _/
    %          \                      /  \
    %           |           |        /_---` 
    %           \    .______|      ./
    %           (   /        \    /
    %           `--'          /__/
    properties
        combination
        score
    end
    methods
        function CD = CDetection(combination, score)
            CD.combination = combination;
            CD.score = score;
        end
        function bCompatible = IsCompatible(CD1, CD2, listCPart, rootMaxOverlap, partMaxOverlap)
            bCompatible = true;            
            % check common part
            commons = intersect(CD1.combination, CD2.combination);
            if ~isempty(commons(0 < commons))
                bCompatible = false;
                return; 
            end
            % check root overlap
            if ~IsCompatible(listCPart(CD1.combination(1)), listCPart(CD1.combination(2)), rootMaxOverlap)
                bCompatible = false;
                return;
            end
            % check parts overlap (except root)
            partsForCheck1 = CD1.combination(2:end);
            partsForCheck2 = CD2.combination(2:end);
            partsForCheck1 = partsForCheck1(0 < partsForCheck1);
            partsForCheck2 = partsForCheck2(0 < partsForCheck2);
            for p1 = partsForCheck1
                for p2 = partsForCheck2                 
                    if ~IsCompatible(listCPart(p1), listCPart(p2), partMaxOverlap)
                        bCompatible = false;
                        return;
                    end
                end
            end
        end
        function numOccParts = NumOccludedParts(CD1, CD2, listCPart, model, partOccMinOverlap)
            numOccParts = 0;
            % roots are excepted
            occludedType1 = find(0 == CD1.combination); occludedType1(1 == occludedType1) = [];
            occludedType2 = find(0 == CD2.combination); occludedType2(1 == occludedType2) = [];
            visibleType1 = find(0 ~= CD1.combination);  visibleType1(1 == visibleType1) = [];
            visibleType2 = find(0 ~= CD2.combination);  visibleType2(1 == visibleType2) = [];
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
                            estimatedCoords, partOccMinOverlap);
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
                            estimatedCoords, partOccMinOverlap);
                        numOccParts = numOccParts + 1;
                        break;
                    end
                end
            end
        end
        function ShowDetection(CD, listCPart, image, rescale)
            if 0 ~= image, imshow(image, 'border', 'tight'); end
            if nargin < 4, rescale = 1.0; end            
            for pIdx = CD.combination(0 < CD.combination)
                curColor = [1, 1, 1];
                if 2 == listCPart(pIdx).type, curColor = [1, 0, 0]; end
                rectangle('Position', rescale*Coords2Rect(listCPart(pIdx).coords), 'EdgeColor', curColor);
            end           
        end
    end
end