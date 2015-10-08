function hFig = DrawPart(image, listCParts, CDC, imageScale, figID)

% input check
if nargin < 5
    hFig = figure;
else
    hFig = figure(figID);
end
if nargin < 4, imageScale = 1.0; end
if nargin < 3, CDC = CDistinguishableColors(); end

% draw image
imshow(image, 'border', 'tight');
hold on;
for partIdx = 1:length(listCParts)
    curBox = GetBox(listCParts(partIdx)) / imageScale;
    rectangle('Position', curBox, 'EdgeColor', GetColor(CDC, listCParts(partIdx).type));
end
hold off;

end

%()()
%('')HAANJU.YOO