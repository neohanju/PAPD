function  [cellListDetections] = GenerateDetections(...
    listCParts, cellCombinationCluster, minOccOverlapRatio)
%                                                                           ,aa,       ,aa
%                                                                            d"  "b    ,d",`b
%                                                                          ,dP a  "b,ad8' 8 8
%                                                                          d8' 8  ,88888a 8 8
%                                                                         d8baa8ba888888888a8
%                                                                      ,ad888888888YYYY888YYY,
%                                                                   ,a888888888888"   "8P"  "b
%                                                               ,aad8888tt,8888888b (0 `8, 0 8
%                           ____________________________,,aadd888ttt8888ttt"8"I  "Yb,   `Ya  8
%                     ,aad8888b888888aab8888888888b,     ,aatPt888ttt8888tt 8,`b,   "Ya,. `"aP
%                 ,ad88tttt8888888888888888888888888ttttt888ttd88888ttt8888tt,t "ba,.  `"`d888
%              ,d888tttttttttttttt888888888888888888888888ttt8888888888ttt888ttt,   "a,   `88'
%             a888tttttttttttttttttttttttttt8888888888888ttttt88888ttt888888888tt,    `""8"'
%            d8P"' ,tttttttttttttttttttttttttttttttttt88tttttt888tttttttt8a"8888ttt,   ,8'
%           d8tb  " ,tt"  ""tttttttttttttttttttttttttttttttttt88ttttttttttt, Y888tt"  ,8'
%           88tt)              "t" ttttt" """  """    "" tttttYttttttttttttt, " 8ttb,a8'
%           88tt                    `"b'                  ""t'ttttttttttt"t"t   t taP"
%           8tP                       `b                       ,tttttt' " " "tt, ,8"
%          (8tb  b,                    `b,                 a,  tttttt'        ""dP'
%          I88tb `8,                    `b                d'   tttttt        ,aP"
%          8888tb `8,                   ,P               d'    "tt "t'    ,a8P"
%         I888ttt, "b                  ,8'              ,8       "tt"  ,d"d"'
%        ,888tttt'  8b               ,dP""""""""""""""""Y8        tt ,d",d'
%      ,d888ttttP  d"8b            ,dP'                  "b,      "ttP' d'
%    ,d888ttttPY ,d' dPb,        ,dP'                      "b,     t8'  8
%   d888tttt8" ,d" ,d"  8      ,d"'                         `b     "P   8
%  d888tt88888d" ,d"  ,d"    ,d"                             8      I   8
% d888888888P' ,d"  ,d"    ,d"                               8      I   8
% 88888888P' ,d"   (P'    d"                                 8      8   8
% "8P"'"8   ,8'    Ib    d"                                  Y      8   8
%       8   d"     `8    8                                   `b     8   Y
%       8   8       8,   8,                                   8     Y   `b
%       8   Y,      `b   `b                                   Y     `b   `b
%       Y,   "ba,    `b   `b,                                 `b     8,   `"ba,
%        "b,   "8     `b    `""b                               `b     `Yaa,adP'
%          """""'      `baaaaaaP                                `YaaaadP"'

%==========================================
% CONFIGURATIONS
%==========================================
% (head 반드시 포함되게 할 것, head로부터 configuration 내 모든 part로 path 존재하게끔)
% part adjacency matrix
Ap = [0 0 0 0 0 0 0 0 0; %     2
      0 0 0 1 0 1 0 0 0; %  4     6
      0 0 0 0 1 0 0 1 1; %  7     8
      0 1 0 0 0 1 1 0 0; %     5
      0 0 1 0 0 0 1 1 1; %   9   3
      0 1 0 1 0 0 0 1 0; 
      0 0 0 1 1 0 0 0 1; 
      0 0 1 0 1 1 0 0 0;
      0 0 1 0 1 0 1 0 0];
numPartTypes = size(Ap, 1);
configurations = zeros(2^(numPartTypes-2), numPartTypes);
numConfigurations = 0;
for cIdx = 1:size(configurations, 1)
    curBinaryString = ['11', dec2bin(cIdx-1, numPartTypes-2)];
    curConfiguration = zeros(1, numPartTypes);
    for typeIdx = 1:numPartTypes
        curConfiguration(typeIdx) = str2double(curBinaryString(typeIdx));
    end
    % check connectivity (except root and head)
    if ~CheckConnectivity(2, curConfiguration, Ap, [1, 2]), continue; end
    numConfigurations = numConfigurations + 1;
    configurations(numConfigurations,:) = curConfiguration;
end
configurations = configurations(1:numConfigurations,:);

%==========================================
% COMBINATIONS
%==========================================
numCluster = length(cellCombinationCluster);
cellListDetections = cell(numCluster, 1);
for clusterIdx = 1:numCluster
    % get data for the current cluster
    curClusterCombinations = cellCombinationCluster{clusterIdx};
    numCurCombinations = size(curClusterCombinations, 1);
    curPartsIdxs = curClusterCombinations';
    curPartsIdxs = curPartsIdxs(:)';
    
    % enumerate combinations
    cellListDetections{clusterIdx} = CDetection.empty();
    numCurClusterDetections = 0;
    
    for cIdx = 1:numCurCombinations
        curCombination = curClusterCombinations(cIdx,:);
        
        % 다른 pedestrian에 의해 가려지지 않은 part의 경우, 꼭 추가로 고려하도록
        curPossibleConfigurations = configurations;
        otherPartsIdxs = curPartsIdxs;
        otherPartsIdxs((cIdx-1)*numPartTypes+1:cIdx*numPartTypes) = [];
        for tIdx = 1:numPartTypes
            p1 = curCombination(tIdx);
            bOccluded = false;
            for p2 = otherPartsIdxs
                if p1 == p2, continue; end
                if CheckOverlap(listCParts(p1).coords, listCParts(p2).coords, minOccOverlapRatio)
                    bOccluded = true;
                    break;
                end
            end
            if bOccluded, continue; end            
            curPossibleConfigurations(:,tIdx) = 1.0;
        end
        curPossibleConfigurations = unique(curPossibleConfigurations, 'rows');
        curNumConfiguration = size(curPossibleConfigurations, 1);
        
        % element-wise multiplication 
        repmatCurCombination = repmat(curCombination, curNumConfiguration, 1); % dim: 128x9
        generatedCombinations = curPossibleConfigurations .* repmatCurCombination;
        
        % make CDetection instance
        for dIdx = 1:curNumConfiguration
            curGeneratedCombination = generatedCombinations(dIdx,:);
            curListCParts = ...
                listCParts(curGeneratedCombination(0 ~= curGeneratedCombination));
            curScore = sum([curListCParts.score]);
            if length(curListCParts) < length(curCombination)
                curScore = curScore - listCParts(curGeneratedCombination(1)).score; 
            end
            numCurClusterDetections = numCurClusterDetections + 1;
            cellListDetections{clusterIdx}(numCurClusterDetections) = ...
                CDetection(curGeneratedCombination, curCombination, curScore);
        end
    end
end
end

%()()
%('')HAANJU.YOO