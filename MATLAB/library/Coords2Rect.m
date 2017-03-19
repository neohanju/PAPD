function rect = Coords2Rect(coords)
rect = [coords(1),coords(2),coords(3)-coords(1)+1,coords(4)-coords(2)+1];
end