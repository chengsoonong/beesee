clc; close all; clear;
BEES_globals;
name = 'BEES';
% --------------------
% specify model parameters
% number of mixtures for 18 parts
% K  = [6 6 6 6 6 6 6 6 6 6 6 6 6];
% Tree structure for 18 parts: pa(i) is the parent of part i
% This structure is implicity assumed during data preparation
% (BUFFY_data.m) and evaluation (BUFFY_eval_pcp)
pa = [   0    1    2 ];
% %     head thrx abdm lant rant lwng rwng
% pa = [0 1 2 3 4 1 1 3 8 9 3 11 12];
% Spatial resolution of HOG cell, interms of pixel width and hieght
% The BUFFY dataset contains low-res people, so we use low-res parts
sbin = 3;
% --------------------
% Prepare training and testing images and part bounding boxes
% You will need to write custom *_data() functions for your own dataset
[pos neg] = BEES_train_data(name);
pos = point2box(pos,pa);
% --------------------
% training
model = trainmodel(name,pos,neg,K,pa,sbin);
save(modelpath,'model');