%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% Name : PART ASSOCIATION
% Date : 2015.09.22
% Author : HaanJu.Yoo
% Version : 0.9
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%                                            ....
%                                           W$$$$$u
%                                           $$$$F**+           .oW$$$eu
%                                           ..ueeeWeeo..      e$$$$$$$$$
%                                       .eW$$$$$$$$$$$$$$$b- d$$$$$$$$$$W
%                           ,,,,,,,uee$$$$$$$$$$$$$$$$$$$$$ H$$$$$$$$$$$~
%                        :eoC$$$$$$$$$$$C""?$$$$$$$$$$$$$$$ T$$$$$$$$$$"
%                         $$$*$$$$$$$$$$$$$e "$$$$$$$$$$$$$$i$$$$$$$$F"
%                         ?f"!?$$$$$$$$$$$$$$ud$$$$$$$$$$$$$$$$$$$$*Co
%                         $   o$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$
%                 !!!!m.*eeeW$$$$$$$$$$$f?$$$$$$$$$$$$$$$$$$$$$$$$$$$$$U
%                 !!!!!! !$$$$$$$$$$$$$$  T$$$$$$$$$$$$$$$$$$$$$$$$$$$$$
%                  *!!*.o$$$$$$$$$$$$$$$e,d$$$$$$$$$$$$$$$$$$$$$$$$$$$$$:
%                 "eee$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$C
%                b ?$$$$$$$$$$$$$$**$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$!
%                Tb "$$$$$$$$$$$$$$*uL"$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$'
%                 $$o."?$$$$$$$$F" u$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$
%                  $$$$en ```    .e$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$'
%                   $$$B*  =*"?.e$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$F
%                    $$$W"$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$"
%                     "$$$o#$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$"
%                    R: ?$$$W$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$" :!i.
%                     !!n.?$???""``.......,``````"""""""""""``   ...+!!!
%                      !* ,+::!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!*`
%                      "!?!!!!!!!!!!!!!!!!!!~ !!!!!!!!!!!!!!!!!!!~`
%                      +!!!!!!!!!!!!!!!!!!!! !!!!!!!!!!!!!!!!!!?!`
%                    .!!!!!!!!!!!!!!!!!!!!!' !!!!!!!!!!!!!!!, !!!!
%                   :!!!!!!!!!!!!!!!!!!!!!!' !!!!!!!!!!!!!!!!! `!!:
%                .+!!!!!!!!!!!!!!!!!!!!!~~!! !!!!!!!!!!!!!!!!!! !!!.
%               :!!!!!!!!!!!!!!!!!!!!!!!!!.`:!!!!!!!!!!!!!!!!!:: `!!+
%               "~!!!!!!!!!!!!!!!!!!!!!!!!!!.~!!!!!!!!!!!!!!!!!!!!.`!!:
%                   ~~!!!!!!!!!!!!!!!!!!!!!!! ;!!!!~` ..eeeeeeo.`+!.!!!!.
%                 :..    `+~!!!!!!!!!!!!!!!!! :!;`.e$$$$$$$$$$$$$u .
%                 $$$$$$beeeu..  `````~+~~~~~" ` !$$$$$$$$$$$$$$$$ $b
%                 $$$$$$$$$$$$$$$$$$$$$UU$U$$$$$ ~$$$$$$$$$$$$$$$$ $$o
%                !$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$. $$$$$$$$$$$$$$$~ $$$u
%                !$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$! $$$$$$$$$$$$$$$ 8$$$$.
%                !$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$X $$$$$$$$$$$$$$`u$$$$$W
%                !$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$! $$$$$$$$$$$$$".$$$$$$$:
%                 $$$$$$$$$$$$$$$$$$$$$$$$$$$$$$  $$$$$$$$$$$$F.$$$$$$$$$
%                 ?$$$$$$$$$$$$$$$$$$$$$$$$$$$$f $$$$$$$$$$$$' $$$$$$$$$$.
%                  $$$$$$$$$$$$$$$$$$$$$$$$$$$$ $$$$$$$$$$$$$  $$$$$$$$$$!
%                  "$$$$$$$$$$$$$$$$$$$$$$$$$$$ ?$$$$$$$$$$$$  $$$$$$$$$$!
%                   "$$$$$$$$$$$$$$$$$$$$$$$$Fib ?$$$$$$$$$$$b ?$$$$$$$$$
%                     "$$$$$$$$$$$$$$$$$$$$"o$$$b."$$$$$$$$$$$  $$$$$$$$'
%                    e. ?$$$$$$$$$$$$$$$$$ d$$$$$$o."?$$$$$$$$H $$$$$$$'
%                   $$$W.`?$$$$$$$$$$$$$$$ $$$$$$$$$e. "??$$$f .$$$$$$'
%                  d$$$$$$o "?$$$$$$$$$$$$ $$$$$$$$$$$$$eeeeee$$$$$$$"
%                  $$$$$$$$$bu "?$$$$$$$$$ 3$$$$$$$$$$$$$$$$$$$$*$$"
%                 d$$$$$$$$$$$$$e. "?$$$$$:`$$$$$$$$$$$$$$$$$$$$8
%         e$$e.   $$$$$$$$$$$$$$$$$$+  "??f "$$$$$$$$$$$$$$$$$$$$c
%        $$$$$$$o $$$$$$$$$$$$$$$F"          `$$$$$$$$$$$$$$$$$$$$b.
%       M$$$$$$$$U$$$$$$$$$$$$$F"              ?$$$$$$$$$$$$$$$$$$$$$u
%       ?$$$$$$$$$$$$$$$$$$$$F                   "?$$$$$$$$$$$$$$$$$$$$u
%        "$$$$$$$$$$$$$$$$$$"                       ?$$$$$$$$$$$$$$$$$$$$o
%          "?$$$$$$$$$$$$$F                            "?$$$$$$$$$$$$$$$$$$
%             "??$$$$$$$F                                 ""?3$$$$$$$$$$$$F
%                                                       .e$$$$$$$$$$$$$$$$'
%                                                      u$$$$$$$$$$$$$$$$$
%                                                     `$$$$$$$$$$$$$$$$"
%                                                      "$$$$$$$$$$$$F"
%                                                        ""?????""
%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%


%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%% PARAMETER AND PRESET, INPUT
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

dbstop if error
addpath library;

image = imread('data/frame_0062.jpg');
[imgH, imgW, imgC] = size(image);
imageScale = 2.0;


%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%% PART RESPONSE AND PRE-PROCESSING
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
load data/part_candidates.mat;
load model/INRIAPERSON_star.mat; % Load DPM model
numComponent = length(unique(coords(end-1,:)));
[numPartTypes, numDetections] = size(partscores);
numPartTypes = numPartTypes - 1; % since the last row of partscores is "pyramidLevel"

%==========================================
% NON-MAXIMAL SUPPRESSION WITH EACH PART
%==========================================
numParts = 0;
listCParts = CPart.empty();
cellIndexAmongType = cell(numPartTypes, numComponent); % array positions of a specific part and component
partMap = zeros(imageScale * imgH, imageScale * imgW);
for componentIdx = 1:numComponent
    
    % get data of current component
    curComponentIdx = find(componentIdx == coords(end-1,:));
    curComponents = coords(:,curComponentIdx);
    curComponentScores = partscores(:,curComponentIdx);   
    
    typeOffset = 1;
    for typeIdx = 1:numPartTypes
        
        % non-maximal suppression
        curCoords = curComponents(typeOffset:typeOffset+3,:);
        curScores = curComponentScores(typeIdx,:);
        pickedIdx = nms2([curCoords; curScores]', 0.3);
        
        % save candidates part into 'CPart' class instances
        curArrayIndex = [];
        for candidateIdx = pickedIdx'
            curScore = curComponentScores(typeIdx,candidateIdx);
            curCoord = curCoords(:,candidateIdx)';
            curPyraLevel =  curComponentScores(end, candidateIdx);
            curScale = 2 / ( 2 ^ ( 1 / model.interval ) )^(curPyraLevel-1);            
            numParts = numParts + 1;
            listCParts(numParts) = CPart(componentIdx, typeIdx, curCoord, curScore, curPyraLevel, curScale);
            curArrayIndex = [curArrayIndex, numParts];
            
            imageRect = round(curCoord);
            partMap(imageRect(1):imageRect(3),imageRect(2):imageRect(4)) = 1.0;
        end
        
        % save specific part positions locations in the array of class
        cellIndexAmongType{typeIdx,componentIdx} = curArrayIndex;
        
        typeOffset = typeOffset + 4;
    end
end



%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%% ASSOCIATION
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

listDetections = GenerateDetections(listCParts, cellIndexAmongType, model, partMap);
save detections.mat listDetections;

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%% OPTIMIZATION
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% solve MWCP with the graph

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%% REFINEMENT
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%


%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%% VISUALIZATION
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
CDC = CDistinguishableColors();

roots = coords(1:4,:);
rootRects = roots' / imageScale;
rootRects(:,3) = rootRects(:,3) - rootRects(:,1) + 1;
rootRects(:,4) = rootRects(:,4) - rootRects(:,2) + 1;
figure; imshow(image, 'border', 'tight'); hold on;
for rectIdx = 1:size(rootRects, 1)
    rectangle('Position', rootRects(rectIdx,:), 'EdgeColor', GetColor(CDC, 2));
end
hold off;

% for typeIdx = 1:numPartTypes
%     curListCParts = CPart.empty();
%     for componentIdx = 1:numComponent
%         curListCParts = [curListCParts, listCParts(cellIndexAmongType{typeIdx,componentIdx})];
%     end
%     DrawPart(image, curListCParts, CDC, imageScale, typeIdx);
% end

% numPartsInCombination = zeros(size(combinations, 1), 1);
% for combIdx = 1:size(combinations,1)
%     curCombination = combinations(combIdx,:);
%     numPartsInCombination(combIdx) = numel(curCombination(curCombination ~= 0));
% end
% 
% fullPartCombination = combinations(8 == numPartsInCombination,:);
% % draw all parts of the combination results 
% figure(100);
% imshow(image, 'border', 'tight');
% hold on;
% BBs = [];
% for combIdx = 1:size(fullPartCombination,1)
%     curCombination = fullPartCombination(combIdx,:);
%     curPartBoxes = [];
%     for typeIdx = 2:9
%         curBox = GetBox(listCParts(curCombination(typeIdx))) / imageScale;
%         rectangle('Position', curBox, 'EdgeColor', GetColor(CDC, typeIdx));
%         curPartBoxes = [curPartBoxes; curBox];
%     end
%     % Save bounding boxes of full body
%     %   should be modified when consider partial body.
%     BB = []; % [x y w h]
%     BB(1) = min(curPartBoxes(:,1));
%     BB(2) = min(curPartBoxes(:,2));
%     BB(3) = max(curPartBoxes(:,1) + curPartBoxes(:,3)) - BB(1);
%     BB(4) = max(curPartBoxes(:,2) + curPartBoxes(:,4)) - BB(2);
%     BBs = [BBs; BB]; 
% end
% hold off;
% % draw bounding boxes of the combination results
% figure(101);
% imshow(image, 'border', 'tight');
% hold on;
% for combIdx = 1:size(fullPartCombination,1)
%     rectangle('Position', BBs(combIdx,:), 'EdgeColor', GetColor(CDC, 10));
% end
% hold off;

%()()
%('') HAANJU.YOO