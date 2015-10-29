function bConnected = CheckConnectivity(startVertexIdx, vertexFlags, matAdjacency, exception)
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

% input
if nargin < 4, exception = []; end
sizeGraph = length(vertexFlags);
vertices = find(0 < vertexFlags);

% flags fot uncovered vertecies
uncoveredFlags = ones(sizeGraph, 1); 
for v = exception, uncoveredFlags(v) = 0; end

% dynamic programming for path finding
currVertices = startVertexIdx;
nextVertices = zeros(1, sizeGraph);
while 0 < length(currVertices)
    numNextVertices = 0;
    for v = currVertices
        uncoveredFlags(v) = 0;
        for a = vertices
            % skip non-adjacent or already covered vertex
            if 0 == matAdjacency(v,a) || 0 == uncoveredFlags(a)
                continue; 
            end
            numNextVertices = numNextVertices + 1;
            nextVertices(numNextVertices) = a;
        end
    end
    currVertices = nextVertices(1:numNextVertices);
end

% result
bConnected = false;
if vertexFlags * uncoveredFlags == 0, bConnected = true; end

end

%()()
%('')HAANJU.YOO