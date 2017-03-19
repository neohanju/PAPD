classdef CDistinguishableColors
    properties
        numColors = 400
        colors
    end
    methods
        function CDC = CDistinguishableColors(numColors)
            if 0 < nargin
                CDC.numColors = numColors;
            end
            CDC.colors = distinguishable_colors(CDC.numColors);
            endColor = CDC.colors(end, :); 
            CDC.colors(end, :) = CDC.colors(4, :); % switch black color with the one at the end
            CDC.colors(4, :) = endColor;
        end
        function color = GetColor(CDC, index)
            index = rem(index-1, CDC.numColors) + 1;
            color = CDC.colors(index, :);
        end
    end
end