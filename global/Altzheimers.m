% restoredefaultpath

startup
addpath([home '/ls_brain/classes/common'])
addpath([home '/ls_brain/global'])
addpath([home '/ls_brain/classes'])
addpath([home '/ls_brain/methods/Alzheimers'])
p=[home '/ls_brain/methods/Epilepsy/DiscreteTFDs-v1.0'];
path(path,p);
DTFDPath(p);
clear p

% addpath([home '/Documents/ls_brain/methods/Anaisthisia/switch/'])
addpath([home '/ls_brain/methods/Misc/KMBOX-0.9/'])
addpath([home '/ls_brain/methods/Misc/libsvm-3.20/matlab/'])
addpath(genpath([home '/Documents/ls_brain/methods/Misc/drtoolbox/']))
addpath([home '/ls_brain/methods/Misc/tensor_toolbox'])
addpath([home '/ls_brain/methods/Misc/tensor_toolbox/met'])
addpath([home '/ls_brain/methods/Misc/TENSORBOX'])
addpath([home '/ls_brain/methods/Epilepsy'])
addpath([home '/ls_brain/methods/Misc/nway330/'])
addpath([home '/ls_brain/methods/Misc/srv1_9'])
addpath([home '/ls_brain/methods/Misc/'])
addpath([home '/ls_brain/methods/Misc/code'])
addpath([home '/ls_brain/methods/Misc/matlab-bgl-master'])
addpath([home '/ls_brain/methods/Misc/2016_01_16_BCT'])
addpath([home '/fieldtrip-master'])
addpath([home '/ls_brain/methods/Misc/bb'])
run([home '/ls_brain/methods/Misc/bb/set_path.m'])
%a=which('trace');
%rmpath(a(1:end-7));
cd([home '/ls_brain/methods/Alzheimers'])
