%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% Name : GET PART CANDIDATES
% Date : 2015.10.29
% Author : Sandoo.Yun
% Version : 0.9
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%                                               .-ccc-,
%                                               (       )
%                                             (         )
%                        -!x!-               (          )
%                      /c     c\           (           )
%                     !         !         (           )
%                     !         !        (           )
%                     !     __ _,       (cccc-(     )
%                    /\/\  (. ).)       `_'_', (   )
%                     C       __)       (.( .)-(  )
%                     !   /ccc  \      (_      ( )
%                     /   \ c===='    /_____/` D)ee
%                   /`-_   `---'         \     |ee
%              .__|c-/^\-c|_/_   |\/\/\/\||    |ee
%             __.         ||/.\  |       |OooooOee
%             \           ---. \ |       |      \
%            _-    ,`_'_'  .c\  \|__   __|-____  / )e
%            <     -(. ).)    \  ( .\ (. )     \(_/ )e
%            c-       _) \_- ooo @  (_)  @      \(_//.e
%           / /_C (-.____)  /((O)/       \     ._/\c_.e
%          /   |_\     /   / /\\\\`-----''    _|o<  |__
%          |     \ooooO   (  \ \\ \\___/     \ `_'_',  /
%           \     \__-|    \  `)\\-'\\ '--.  /_(.(.)- _\
%            \   \ )  |-`--.`--=\-\ /-//_  '  ( c     D\
%             \_\_)   |-___/   / \ V /.c \/\\\ (@)___/ c|
%            /        |       /   | |.  /`\\_/\/   /
%           /         |      (   C`-'` /  |  \/   (/  /
%          /_________-        \  `C__-c   |  /    (/ /
%               | | |          \__________|  \     (/
% 
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

%--------------------------------------------------------------------------
% Init & Set Paths
%--------------------------------------------------------------------------
DPM_path = 'D:\Dropbox\Research\[001] PAPD\DPM_release_4.01';
addpath(genpath(DPM_path));
% init
cd '..';
main_init;
% Load DPM model
load('model\INRIAPERSON_star.mat');
model_cascade = model;
load(fullfile(DPM_path, 'INRIA/inriaperson_final.mat'));

% parameters
DPM_OVERLAP = 0.5;

START_FRAME_IDX = 0;
END_FRAME_IDX   = 239;
IMAGE_DIR       = 'D:\work\PETS2009\S2L3\View_001';
PARTCANDIDATE_DIR = 'D:\Dropbox\Research\[001] PAPD\DETECTIONS';
%--------------------------------------------------------------------------
% Get part candidates (root + 8 parts)
%--------------------------------------------------------------------------
fprintf('======================================================\n');
fprintf(' Get Part Candidates \n');
fprintf(' DIR: %s \n', DATASET_PATH);
fprintf('======================================================\n');
t_all = tic;
for frameIdx = START_FRAME_IDX : END_FRAME_IDX
    t_frame = tic;
    fprintf('FrameIdx (%d/%d) ...', frameIdx, END_FRAME_IDX);    
    % Read image
    imagePath = fullfile(IMAGE_DIR, sprintf('frame_%04d.jpg', frameIdx));
    image = imread(imagePath);
    im = imresize(image, 2);
    
    % Get feature pyramid
    pyra = featpyramid(double(im), model);
    
% %     % Get part candidates (root + 8 parts): this contains part locations and scores
%     [dets, boxes, info] = imgdetect(im, model, -1);
% %     top = nms(dets, 0.5);
%     boxes = reduceboxes(model, boxes(:,:));
% 
%     figure(1); clf;
%     I = nms(boxes, 0.5);
%     imshow(im, 'border', 'tight');
%     showboxes(im, boxes(I,1:4));    
    
    [coords, partscores] = cascade_part_candidates(pyra, model_cascade, model_cascade.thresh);
    [sortO, sortI] = sort(model_cascade.cascade.order{1}(1:9));
    partscores = partscores([sortI 10],:);
    
    % Save part candidates
    partPath = fullfile(PARTCANDIDATE_DIR, sprintf('frame_%04d_part_candidates.mat', frameIdx));
    save(partPath, 'coords', 'partscores');
    toc_frame = toc(t_frame);
    fprintf('Done! %f seconds\n', toc_frame);   
    
    % Save figure
    figure(2);
    dets = coords([1:4 end-1 end],:)';
    I = nms(dets, 0.5);
    imshow(im, 'border', 'tight');
    showboxes(im, coords(1:4,I)');    
    saveas(gcf, fullfile(PARTCANDIDATE_DIR, sprintf('frame_%04d_dpm_nms_0.5.jpg', frameIdx)),'jpg');

%     pause;
end
toc_all = toc(t_all);
fprintf('======================================================\n');
fprintf(' It took %f seconds\n', toc_all);
fprintf('======================================================\n');












%     %===========================
%     % Show detection results
%     %===========================
%     % draw head
%     dets = coords([1:4 end-1 end],:)';
%     over_head = 1;
%     over_full = 0.5;
%     I = nms2(dets, over_head);
%     figure(1);
%     imshow(im, 'border', 'tight');
%     showboxes(im, coords(5:8,I)');
%     title(sprintf('head, nms=%f',over_head));
%     saveas(gcf, fullfile('data', sprintf('%s_DPM_head.jpg',imageName))); 
%     
%     % draw full body
%     figure(2);
%     I = nms2(dets, over_full);
%     imshow(im, 'border', 'tight');
%     % showboxes(im, dets(I,:));
%     showboxes(im, coords(1:4,I)');
%     title(sprintf('full, nms=%f',over_full));
%     saveas(gcf, fullfile('data', sprintf('%s_DPM_full_nms.jpg',imageName))); 