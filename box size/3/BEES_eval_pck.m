clc; close all; clear;
BEES_globals;
model = load(modelpath);

[test] = BEES_predict_data(name);

suffix = num2str(K')';
load([cachedir name '_boxes_' suffix]);

model.thresh = min(model.thresh,-2);
boxes_gtbox = testmodel_gtbox(name,model,test,suffix);

for n = 1:length(test)
  ca(n).point = [];
  if isempty(boxes_gtbox{n})
    continue;
  end
  box = boxes_gtbox{n};
	b = box(1:floor(size(box, 2)/4)*4);
  b = reshape(b,4,size(b,2)/4);
  bx = .5*b(1,:) + .5*b(3,:);
  by = .5*b(2,:) + .5*b(4,:);
  ca(n).point = [bx' by'];
end

% -------------------
% generate ground truth keypoint locations
for n = 1:length(test)
  gt(n).point = test(n).point;
  gt(n).scale = norm(gt(n).point(1,:)-gt(n).point(2,:)); 
%   use head to abdomen as the scale
end

pck = eval_pck(ca,gt);
% % average left with right and neck with top head
% pck = (pck + pck([2 1 5 6 8 10 3 4 7 9]))/2;
% % change the order to: Head & Shoulder & Elbow & Wrist & Hip & Knee & Ankle
% pck = pck([1 3 4 5 7 9]);
meanpck = mean(pck);
fprintf('mean PCK = %.1f\n',meanpck*100); 
fprintf('Keypoints & Head & Thorax & Abdomen\n');
fprintf('PCK       '); fprintf('& %.1f ',pck*100); fprintf('\n');
