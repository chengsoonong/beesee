clc; close all; clear;
BEES_globals;
model = load(modelpath);

[predict] = BEES_predict_data(name);

load(modelpath);
suffix = num2str(K')';
model.thresh = min(model.thresh,-2);
boxes = testmodel(name,model,predict,suffix);
