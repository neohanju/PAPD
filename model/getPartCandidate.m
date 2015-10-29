%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% Name : GET PART CANDIDATES
% Date : 2015.09.24
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
% Set Paths
%--------------------------------------------------------------------------
DPM_path = 'D:\work\DPM\';
addpath(genpath(DPM_path));

%--------------------------------------------------------------------------
% Get part candidates (root + 8 parts)
%--------------------------------------------------------------------------
% Load test image
for imgIdx = 1 : 5
    imageName = sprintf('img%d',imgIdx);
    im = imread(fullfile('data', sprintf('%s.jpg', imageName)));
    im = imresize(im, 2);
    % Load DPM model
    load('model\INRIAPERSON_star.mat');
    
    % Get feature pyramid
    pyra = featpyramid(double(im), model);
    
    % Get part candidates (root + 8 parts)
    %       this contains part locations and scores
    [coords, partscores] = cascade_part_candidates(pyra, model, model.thresh);
    [sortO, sortI] = sort(model.cascade.order{1}(1:9));
    partscores = partscores([sortI 10],:);
    
    %===========================
    % Show detection results
    %===========================
    % draw head
    dets = coords([1:4 end-1 end],:)';
    over_head = 1;
    over_full = 0.5;
    I = nms2(dets, over_head);
    figure(1);
    imshow(im, 'border', 'tight');
    showboxes(im, coords(5:8,I)');
    title(sprintf('head, nms=%f',over_head));
    saveas(gcf, fullfile('data', sprintf('%s_DPM_head.jpg',imageName))); 
    
    % draw full body
    figure(2);
    I = nms2(dets, over_full);
    imshow(im, 'border', 'tight');
    % showboxes(im, dets(I,:));
    showboxes(im, coords(1:4,I)');
    title(sprintf('full, nms=%f',over_full));
    saveas(gcf, fullfile('data', sprintf('%s_DPM_full_nms.jpg',imageName))); 
    
%     pause;
    % Save part candidates
%     save(fullfile('data', sprintf('%s_part_candidates.mat',imageName)), 'coords', 'partscores');
    
end

