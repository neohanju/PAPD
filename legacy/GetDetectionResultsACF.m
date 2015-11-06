addpath(genpath('.'));
main_init;

% evaluate channel filter
DETECTOR_NAME = 'ACF_INRIA';
load(fullfile('D:\work\piotr_toolbox\detector\models','AcfInriaDetector.mat')); % Load Detector
cellBBoxsACF = cell(END_FRAME_IDX - START_FRAME_IDX + 1, 1);
cellIdx = 0;
for frameIdx = START_FRAME_IDX:END_FRAME_IDX
    cellIdx = cellIdx + 1;
    tic;
    fprintf(' FRAME: %04d ......', frameIdx);
    imagePath = fullfile(IMAGE_DIR, sprintf([IMAGE_NAMEFORM, '.', IMAGE_FORMATE], frameIdx));
    image = imread(imagePath);
    image = imresize(image, 2.0);
%     detector.opts.pNms.type = 'none';
    bbs = acfDetect( image, detector, [] ); % [x y w h]
%     figure(1); clf;
%     imshow(image); hold on;
%     for bId = 1 : size(bbs, 1)
%         rectangle('Position', bbs(bId,1:4));
%     end
    cellBBoxsACF{cellIdx} = bbs;
    fprintf('DONE! (%f seconds) \n', toc);
end

save(fullfile(RESULT_DIR, sprintf('result_%s_%s.mat', DATASET_NAME, ...
    DETECTOR_NAME)), 'cellBBoxsACF');

