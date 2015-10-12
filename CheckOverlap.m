function bOverlap = CheckOverlap(coords1, coords2, overlapRatio)
bOverlap = false;

Area1 = (coords1(3)-coords1(1)+1)*(coords1(4)-coords1(2)+1);
Area2 = (coords2(3)-coords2(1)+1)*(coords2(4)-coords2(2)+1);

x1 = max(coords1(1), coords2(1));
y1 = max(coords1(2), coords2(2));
x2 = min(coords1(3), coords2(3));
y2 = min(coords1(4), coords2(4));
commonW = x2 - x1 + 1;
commonH = y2 - y1 + 1;

if commonW > 0 && commonH > 0
    % compute overlap
    overlap = commonW * commonH * 1/ min(Area1, Area2);
    if overlap > overlapRatio, bOverlap = true; end
end

end

%()()
%('')HAANJU.YOO