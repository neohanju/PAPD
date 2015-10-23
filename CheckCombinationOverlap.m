function bOverlap = CheckCombinationOverlap( ...
    combination1, combination2, listCParts, overlapRatio)

bOverlap = false;
numTypes = length(combination1);
for typeIdx1 = 2:numTypes
    for typeIdx2 = 2:numTypes
        if CheckOverlap(...
                listCParts(combination1(typeIdx1)).coords, ...
                listCParts(combination2(typeIdx2)).coords, ...
                overlapRatio);
            bOverlap = true;
            return;
        end        
    end            
end
end

%()()
%('')HAANJU.YOO