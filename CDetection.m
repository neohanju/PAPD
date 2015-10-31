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
        fullScores
        score
        normalizedScore
    end
    methods
        function CD = CDetection(combination, fullCombination, fullScores, score)
            CD.combination = combination;
            CD.fullCombination = fullCombination;
            CD.fullScores = fullScores;
            CD.score = score;
            CD.normalizedScore = 0;
        end
        function bCompatible = IsCompatible(CD1, CD2, listCPart, rootMaxOverlap, partMaxOverlap)                
            bCompatible = false;            
            
            % check common part
            commons = intersect(CD1.combination, CD2.combination);
            if ~isempty(commons(0 < commons)), return; end
            
            % check root overlap
            if CheckOverlap(...
                    listCPart(CD1.combination(1)).coords, ...
                    listCPart(CD2.combination(1)).coords, rootMaxOverlap)
                return;
            end
            
            % check parts overlap (except root)
            partsForCheck1 = CD1.combination(2:end);
            partsForCheck2 = CD2.combination(2:end);
            partsForCheck1 = partsForCheck1(0 < partsForCheck1);
            partsForCheck2 = partsForCheck2(0 < partsForCheck2);
            for p1 = partsForCheck1
                for p2 = partsForCheck2                 
                    if CheckOverlap(listCPart(p1).coords, listCPart(p2).coords, partMaxOverlap)                        
                        return;
                    end
                end
            end
            
            % inverse detection을 만든 다음, occlusion cover를 몇 개 하는지 확인           
            CD1i = CD1; 
            CD1i.combination = CD1.fullCombination;
            CD1i.combination(0 < CD1.combination) = 0;
            numOcc = NumOccludedParts(CD1i, CD2, listCPart, partMaxOverlap);
            if numOcc > 0, return; end;
                
            
            CD2i = CD2; 
            CD2i.combination = CD2.fullCombination;
            CD2i.combination(0 < CD2.combination) = 0;
            numOcc = NumOccludedParts(CD1, CD2i, listCPart, partMaxOverlap);
            if numOcc > 0, return; end;
            
            bCompatible = true;
        end
        function numOccParts = NumOccludedParts(CD1, CD2, listCPart, partOccMinOverlap)                                    
            % part coords gathering
            numPartTypes  = numel(CD1.fullCombination)-1; % roots are excepted
            CD1PartCoords = zeros(4, numPartTypes);
            CD2PartCoords = zeros(4, numPartTypes);
            for pIdx = 2:numPartTypes+1
                if 0 == CD1.combination(pIdx)
                    CD1PartCoords(:,pIdx-1) = listCPart(CD1.fullCombination(pIdx)).coords';
                end
                if 0 < CD2.combination(pIdx)
                    CD2PartCoords(:,pIdx-1) = listCPart(CD2.fullCombination(pIdx)).coords';
                end
            end            
            % call C-mex fucntion
            numOccParts = NumOccludedParts_mex(...
                CD1PartCoords, ...
                CD2PartCoords, ...
                partOccMinOverlap, 1.0);
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