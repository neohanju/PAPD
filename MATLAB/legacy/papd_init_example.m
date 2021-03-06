%===============================================================================
% Name : PAPD_INIT                                                         
% Date : 2015.10.23
% Author : HaanJu.Yoo
% Version : 0.9
%===============================================================================
%                       _    _  __  _  _ _____  ___ ___
%                       | /\ | |__| |\ |   |   |___ |  \
%                       |/  \| |  | | \|   |   |___ |__/
% 
%          F O R   C R I M E S   A G A I N S T   T H E   E M P I R E
% 
%  ________________________  _________________________  _______________________
% |        .......       LS||      .x%%%%%%x.         ||  ,.------;:~~:-.      |
% |      ::::::;;::.       ||     ,%%%%%%%%%%%        || /:.\`;;|||;:/;;:\     |
% |    .::;::::;::::.      ||    ,%%%'  )'  \%        ||:')\`:\||::/.-_':/)    |
% |   .::::::::::::::      ||   ,%x%) __   _ Y        ||`:`\\\ ;'||'.''/,.:\   |
% |   ::`_```_```;:::.     ||   :%%% ~=-. <=~|        ||==`;.:`|;::/'/./';;=   |
% |   ::=-) :=-`  ::::     ||   :%%::. .:,\  |        ||:-/-%%% | |%%%;;_- _:  |
% | `::|  / :     `:::     ||   `;%:`\. `-' .'        ||=// %wm)..(mw%`_ :`:\  |
% |   '|  `~'     ;:::     ||    ``x`. -===-;         ||;;--', /88\ -,- :-~~|  |
% |    :-:==-.   / :'      ||     / `:`.__.;          ||-;~~::'`~^~:`::`/`-=:) |
% |    `. _    .'.d8:      ||  .d8b.  :: ..`.         ||(;':)%%%' `%%%.`:``:)\ |
% | _.  |88bood88888._     || d88888b.  '  /8         ||(\ %%%/dV##Vb`%%%%:`-. |
% |~  `-+8888888888P  `-. _||d888888888b. ( 8b       /|| |);/( ;~~~~ :)\`;;.``\|
% |-'     ~~^^^^~~  `./8 ~ ||~   ~`888888b  `8b     /:|| //\'/,/|;;|:(: |.|\;|\|
% |8b /  /  |   \  \  `8   ||  ' ' `888888   `8. _ /:/||/) |(/ | / \|\\`( )- ` |
% |P        `          8   ||'      )88888b   8b |):X ||;):):)/.):|/) (`:`\\`-`|
% |                    8b  ||   ~ - |888888   `8b/:/:\||;%/ //;/(\`.':| ::`\\;`|
% |                    `8  ||       |888888    88\/~~;||;/~( \|./;)|.|):;\. \\-|
% |                     8b ||       (888888b   88|  / ||/',:\//) ||`.|| (:\)):%|
% |         .           `8 ||\       \888888   8-:   /||,|/;/(%;.||| (|(\:- ; :|
% |________/_\___________8_||_\_______\88888_.'___\__/||_%__%:__;_:`_;_:_.\%_`_|
% 
% L u k e  S k y w a l k e r      H a n   S o l o          C h e w b a c c a
% 
% Self-Proclaimed Jedi Knight     Smuggler, Pirate         Smuggler, Pirate
%      500,000 credits            200,000 credits          100,000 credits
% 
%                The above are wanted for the following crimes:
% 
%     - Liberation of a known criminal, Princess Leia Organa of Alderaan -
%          - Direct involvement in armed revolt against the Empire -
%                               - High treason -
%                                - Espionage -
%                                - Conspiracy -
%                     - Destruction of Imperial Property -
% 
%            These individuals are considered extremely dangerous.
% 
%        E X P E R I E N C E D   B O U N T Y   H U N T E R S   O N L Y
% 
%   The Empire will not  be held  responsible  for any  injuries or property
%   loss arising from the  attempted apprehension of these  notorious crimi-
%   nals. Bounty is for live capture only! For more information contact your
%   local Imperial Intelligence Office.
%===============================================================================

% miscellaneous functions
addpath library;

% Gurobi solver
addpath c:/gurobi605/win64/matlab

BATCH_GUROBI = false;

% parameters
ROOT_MAX_OVERLAP = 0.9;
PART_MAX_OVERLAP = 0.8;
PART_OCC_OVERLAP = 0.8;
CLUSTER_OVERLAP  = 0.1;
SOVLER_TIMELIMIT = 100;

% load input frame
INPUT_FILE_NAME    = 'img5';

%()()
%('')HAANJU.YOO