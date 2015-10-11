function [pos neg] = BUFFY_train_data(name)
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

cls = [name '_train_data'];
try
	load([cachedir cls]);
catch
  trainsets = [1 2 4 5];   % training sets
  trainfrs_neg = 1:2345;  % training frames for negative

  % -------------------
  % grab positive annotation and image information
  pos = [];
  numpos = 0;
  for e = trainsets
    load(sprintf(labelfile,e));
    for n = 1:setlengths(e)
      numpos = numpos + 1;
      pos(numpos).im = sprintf(posims,e,n);
      pos(numpos).point = labels(:,:,n);
    end
  end

  % -------------------
  % flip positive training images
%   posims_flip = [cachedir 'imflip/BEES%.6d.jpg'];
%   for n = 1:length(pos)
%     im = imread(pos(n).im);
%     imwrite(im(:,end:-1:1,:),sprintf(posims_flip,n));
%   end

  % -------------------
  % flip labels for the flipped positive training images
  % mirror property for the keypoint, please check your annotation for your
  % own dataset
% 	mirror = [1 2 3 5 4 7 6]; % for flipping original data
%   for n = 1:length(pos)
%     im = imread(pos(n).im);
%     width = size(im,2);
%     numpos = numpos + 1;
%     pos(numpos).im = sprintf(posims_flip,n);
%     pos(numpos).point(mirror,1) = width - pos(n).point(:,1) + 1;
%     pos(numpos).point(mirror,2) = pos(n).point(:,2);
%   end
  
	% -------------------
  % create ground truth keypoints for model training
  % the model may use any set of keypoints not restricted to the keypoints
  % annotated in the dataset
  % for example, we do not use the original 10 keypoints for model training,
  % instead, we generate another 18 keypoints which cover more of space of
  % the human body
% 	I = [1    2    2    3    4    4    5    6    7    8    8    9    9   10   11   11   12   12   13];
% 	J = [1    1    2    2    2    3    3    4    5    2    6    2    6    6    2    7    2    7    7];
% 	A = [1  1/2  1/2    1  1/2  1/2    1    1    1  2/3  1/3  1/3  2/3    1  2/3  1/3  1/3  2/3    1];
% 	Trans = full(sparse(I,J,A,13,7));
  
% 	for n = 1:length(pos)
%     pos(n).point = Trans * pos(n).point; % linear combination
%   end

	% -------------------
	% grab neagtive image information
	negims = 'NOBEES/%d.jpg';
	neg = [];
	numneg = 0;
	for fr = trainfrs_neg
    numneg = numneg + 1;
    neg(numneg).im = sprintf(negims,fr);
	end

	save([cachedir cls],'pos','neg');
end
