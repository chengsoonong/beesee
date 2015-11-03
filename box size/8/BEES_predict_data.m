function [predict] = BUFFY_data(name)
% this function is very dataset specific, you need to modify the code if
% you want to apply the pose algorithm on some other dataset

% it converts the various data format of different dataset into unique
% format for pose detection 
% the unique format for pose detection contains below data structure
%   pos:
%     pos(i).im: filename for the image containing i-th human 
%     pos(i).point: pose keypoints for the i-th human
%   neg:
%     neg(i).im: filename for the image contraining no human
%   test:
%     test(i).im: filename for i-th testing image
% This function also prepares flipped images and slightly rotated images for training.

BEES_globals;

cls = [name '_predict_data'];
try
	load([cachedir cls]);
catch
  
  predictsets  = [3 6]; % testing  sets

  % grab testing image information
  predict = [];
  numtest = 0;
  for e = predictsets
    load(sprintf(labelfile,e));
    for n = 1:setlengths(e)
      numtest = numtest + 1;
      predict(numtest).epi = e;
      predict(numtest).frame = n
      predict(numtest).im = sprintf(posims,e,n);
      predict(numtest).point = labels(:,:,n);
    end
  end

	save([cachedir cls],'predict');
end
