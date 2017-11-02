function data = implementPercentChange(data, sh, power)
% implementPercentChange  Percent rate of change.
%
% Backend IRIS function.
% No help provided.

% -IRIS Macroeconomic Modeling Toolbox.
% -Copyright (c) 2007-2017 IRIS Solutions Team.

try
    sh; %#ok<VUNUS>
catch %#ok<CTCH>
    sh = -1;
end

try
    power; %#ok<VUNUS>
catch %#ok<CTCH>
    power = 1;
end

%--------------------------------------------------------------------------

sh = sh(:).';

pos = transpose(1:size(data, 2));
pos = pos(:, ones(1, length(sh)));
pos = transpose(pos(:));

data = data(:, pos) ./ tseries.myshift(data, sh);
if power~=1
    data = data .^ power;
end
data = 100*(data - 1);

end
