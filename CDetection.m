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
        fullCombination
        score
    end
    methods
        function CD = CDetection(combination, fullCombination, score)
            CD.combination = combination;
            CD.fullCombination = fullCombination;
            CD.score = score;
        end
        function bCompatible = IsCompatible(CD1, CD2, listCPart, rootMaxOverlap, partMaxOverlap)            
            % inverse detection을 만든 다음, occlusion cover를 몇 개 하는지 확인            
            bCompatible = false;            
            CD1i = CD1; 
            CD1i.combination = CD1.fullCombination;
            CD1i.combination(0 < CD1.combination) = 0;
            CD1i.combination(1:2) = CD1.fullCombination(1:2);            
            numOcc = NumOccludedParts(CD1i, CD2, listCPart, 0, partMaxOverlap);
            if numOcc > 0, return; end;
                
            
            CD2i = CD2; 
            CD2i.combination = CD2.fullCombination;
            CD2i.combination(0 < CD2.combination) = 0;
            CD2i.combination(1:2) = CD2.fullCombination(1:2);
            numOcc = NumOccludedParts(CD1, CD2i, listCPart, 0, partMaxOverlap);
            if numOcc > 0, return; end;
            
            bCompatible = true;            
%             bCompatible = true;            
%             % check common part
%             commons = intersect(CD1.combination, CD2.combination);
%             if ~isempty(commons(0 < commons))
%                 bCompatible = false;
%                 return; 
%             end
% %             % check root overlap
% %             if ~IsCompatible(listCPart(CD1.combination(1)), listCPart(CD2.combination(1)), rootMaxOverlap)
% %                 bCompatible = false;
% %                 return;
% %             end
%             % check parts overlap (except root)
%             partsForCheck1 = CD1.combination(2:end);
%             partsForCheck2 = CD2.combination(2:end);
%             partsForCheck1 = partsForCheck1(0 < partsForCheck1);
%             partsForCheck2 = partsForCheck2(0 < partsForCheck2);
%             for p1 = partsForCheck1
%                 for p2 = partsForCheck2                 
%                     if ~IsCompatible(listCPart(p1), listCPart(p2), partMaxOverlap)
%                         bCompatible = false;
%                         return;
%                     end
%                 end
%             end
        end
        function numOccParts = NumOccludedParts(CD1, CD2, listCPart, model, partOccMinOverlap)
            % count occluded parts of CD1 by CD2
            % model은 0값이 들어올 수 있음
            numOccParts = 0;
            % roots are excepted
            occludedType1 = find(0 == CD1.combination); occludedType1(1 == occludedType1) = [];
            visibleType2 = find(0 ~= CD2.combination);  visibleType2(1 == visibleType2) = [];
            det1Component = listCPart(CD1.combination(2)).component;            
            det1HeadIdx = CD1.combination(2);            
            % find occluded parts of detection 1 by detection 2
            rescaleForSpeedup = 1.0;
            for occT1 = occludedType1
                if 0 ~= CD1.fullCombination(occT1)
                    estimatedCoords = listCPart(CD1.fullCombination(occT1)).coords;
                elseif 0 ~= model
                    estimatedCoords = EstimatePartCoords( ...
                        listCPart(det1HeadIdx), occT1, det1Component, model);
                end
                
                estimatedCoords = rescaleForSpeedup * estimatedCoords;
                c1x1 = round(estimatedCoords(1));
                c1y1 = round(estimatedCoords(2));
                c1x2 = round(estimatedCoords(3));
                c1y2 = round(estimatedCoords(4));
                w = c1x2 - c1x1 + 1;
                h = c1y2 - c1y1 + 1;
                occRegion = zeros(h, w);                
                bOccluded = false;
                for visT2 = visibleType2
                    if CheckOverlap(estimatedCoords, listCPart(CD2.combination(visT2)).coords, partOccMinOverlap)
                        bOccluded = true;
                        break;
                    end
                    curCoords = rescaleForSpeedup * listCPart(CD2.combination(visT2)).coords;
                    c2x1 = round(curCoords(1));
                    c2y1 = round(curCoords(2));
                    c2x2 = round(curCoords(3));
                    c2y2 = round(curCoords(4));                    
                    x1 = max(c1x1, c2x1);
                    y1 = max(c1y1, c2y1);
                    x2 = min(c1x2, c2x2);
                    y2 = min(c1y2, c2y2);
                    commonW = x2 - x1 + 1;
                    commonH = y2 - y1 + 1;
                    if commonW > 0 && commonH > 0
                        commnX = x1 - c1x1 + 1;
                        commnY = y1 - c1y1 + 1;
                        occRegion(commnY:commnY+commonH-1,commnX:commnX+commonW-1) = 1.0;
                    end
                end
                if bOccluded || sum(sum(occRegion)) >= w * h * partOccMinOverlap
                    numOccParts = numOccParts + 1;
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