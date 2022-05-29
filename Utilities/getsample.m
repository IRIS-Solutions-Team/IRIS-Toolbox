function [sample,flag] = getsample(y)
% getsample  True for observations from first non-NaN to last non-NaN; flag checks for within-sample NaNs.
%
% Backend IRIS function.
% No help provided.

% -IRIS Macroeconomic Modeling Toolbox.
% -Copyright (c) 2007-2022 IRIS Solutions Team.

%**************************************************************************

transpose = ndims(y) == 2 && size(y,1) > 1 && size(y,2) == 1;
if transpose
   y = y.';
end

sample = all(all(~isnan(y),3),1);
first = find(sample,1);
last = find(sample,1,'last');
sample(1:first-1) = false;
sample(last+1:end) = false;
flag = all(sample(first:last));
sample(first:last) = true;

if transpose
   sample = sample.';
end

end
