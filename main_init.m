%==========================================
% PARAMETERS
%==========================================
ROOT_MAX_OVERLAP = 0.9;
HEAD_NMS_RATIO   = [0.1, 0.3, 0.5, 0.8];
PART_NMS_RATIO   = [0.3, 0.5, 0.8];
% HEAD_NMS_RATIO   = 0.3;
% PART_NMS_RATIO   = 0.8;
EVAL_MIN_OVERLAP = 0.5;
SOVLER_TIMELIMIT = 60;

%==========================================
% INPUT
%==========================================
DATASET_PATH = 'D:/Workspace/Dataset/PETS2009/S2/L2/Time_14-55';

% image
global START_FRAME_IDX END_FRAME_IDX
IMAGE_DIR       = fullfile(DATASET_PATH, 'View_001');
IMAGE_NAMEFORM  = 'frame_%04d';
IMAGE_FORMATE   = 'jpg';
START_FRAME_IDX = 424;
END_FRAME_IDX   = 424;

% part detection
global PARTCANDIDATE_DIR PARTCANDIDATE_FORM PARTCANDIDATE_SCALE
PARTCANDIDATE_DIR   = fullfile(IMAGE_DIR, 'partDetections');
PARTCANDIDATE_FORM  = [IMAGE_NAMEFORM '_part_candidates.mat'];
PARTCANDIDATE_SCALE = 2.0;

% ground truth
GROUNDTRUTH_DIR  = 'data/groundTruth';
GROUNDTRUTH_NAME = 'PETS2009-S2L2.mat';

%==========================================
% OUTPUT
%==========================================
RESULT_DIR      = 'D:/Workspace/ExperimentalResult/PAPD/PETS2009-S2L2';
RESULT_NAMEFORM = 'frame_%04d_result_%1.2f_%1.2f.mat';

%==========================================
% LIBRARIES
%==========================================
addpath library;
addpath c:/gurobi605/win64/matlab;  % Gurobi solver
load    model/INRIAPERSON_star.mat; % DPM model
CDC = CDistinguishableColors();     % distinguishable colors

%==========================================
% PRE-CALCULATIONS
%==========================================
numFrames = END_FRAME_IDX - START_FRAME_IDX + 1;
numHNR    = length(HEAD_NMS_RATIO);
numPNR    = length(PART_NMS_RATIO);


%()()
%('')HAANJU.YOO