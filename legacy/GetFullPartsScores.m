function stDetectionResult = GetFullPartsScores(stDetectionResult)

main_init;

cellPBoxs = stDetectionResult.cellPBoxs;
cellBBoxs = stDetectionResult.cellBBoxs;
% find head coordinates in the part coordinates

% cell index와 frame index는 같다고 가정 (that is, full sequence)
cellIdx = 0;
for frameIdx = START_FRAME_IDX : END_FRAME_IDX  
    cellIdx = cellIdx + 1;
    partPath = fullfile(PARTCANDIDATE_DIR, sprintf(PARTCANDIDATE_FORM, frameIdx));
    load(partPath);
    
    curPBoxs = cellPBoxs{cellIdx};
    curBBoxs = cellBBoxs{cellIdx};
    
    for boxIdx = 1 : size(curPBoxs, 1)
        curPBox = curPBoxs(boxIdx, :, :);
        curPBox(:,:,curPBox(1,1,:) == 0) = []; % 1 x 5 x 9        
        curRootBox = curPBox(:,1:4,:) * 2;
        % RECT to COORDS
        curRootCoords = [curRootBox(1), curRootBox(2), ...
            curRootBox(1) + curRootBox(3) - 1, curRootBox(2) + curRootBox(4) - 1];
        
        rootCoords = round(coords(1:4,:)');
        ism = ismember(rootCoords, round(curRootCoords));
        ism = sum(ism, 2);
        targetIdx = find(ism == 4);
        assert(numel(targetIdx) > 0, 'something wrong!');
        targetScore = max(coords(end, targetIdx));
        
        curBBoxs(boxIdx, 7) = targetScore;
    end
    cellBBoxs{cellIdx} = curBBoxs;
end
stDetectionResult.cellBBoxs = cellBBoxs;