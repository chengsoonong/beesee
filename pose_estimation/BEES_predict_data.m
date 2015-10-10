function [predict] = BUFFY_data(name)

BEES_globals;

cls = [name '_predict_data'];
try
	load([cachedir cls]);
catch
  
  predictsets  = [2 3]; % testing  sets

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
