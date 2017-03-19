function [cellListDetections] = ClassifyDetetions_SVM(...
    cellListDetections, cellSVMModels)

numClusters = length(cellListDetections);
numPartTypes = length(cellListDetections{1}(1).combination);

% classification
fprintf('Classify scores at each cluster...');
nchar = fprintf('0/%d',numClusters);
normScores = cell(numClusters, 1);
numDeletedDetections = 0;
for clusterIdx = 1:numClusters
    fprintf(repmat('\b', 1, nchar));
    nchar = fprintf('%d/%d', clusterIdx, numClusters);
    numCurDetections = length(cellListDetections{clusterIdx});
    deathNote = false(1, numCurDetections);
    for dIdx = 1:length(cellListDetections{clusterIdx})        
        scoreIdx = find(0 < cellListDetections{clusterIdx}(dIdx).combination); 
        if length(scoreIdx) == numPartTypes, continue; end % skip fullbody
        scoreIdx(1 == scoreIdx) = []; % except root        
        curFullScores = cellListDetections{clusterIdx}(dIdx).fullScores;
       
        % find configuration        
        curConfigurationString = repmat('0', 1, numPartTypes);
        curConfigurationString(scoreIdx) = '1';        
        configurationIdx = bin2dec(curConfigurationString(3:end))+1; % except head and root        

        % classification
        label = predict(cellSVMModels{configurationIdx}, curFullScores(scoreIdx));
        if cellSVMModels{configurationIdx}.ClassNames(end) ~= label
            % negative
            deathNote(dIdx) = true;
            numDeletedDetections = numDeletedDetections + 1;
            continue;
        end
    end
    cellListDetections{clusterIdx}(deathNote) = [];
    normScores{clusterIdx} = [cellListDetections{clusterIdx}.score];
end
fprintf(repmat('\b', 1, nchar));
fprintf('done!\n');
fprintf('the number of deleted detections: %d\n', numDeletedDetections);

end