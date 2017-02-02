function x = mydestdize(x,xmean,xstd)
% MYDESTDIZE  [Not a public function] De-standardize data.
%
% Backend IRIS function.
% No help provided.

% -IRIS Macroeconomic Modeling Toolbox.
% -Copyright (c) 2007-2017 IRIS Solutions Team.

%**************************************************************************

% Add back std devs.
x = bsxfun(@times,x,xstd);

% Add back mean.
x = bsxfun(@plus,x,xmean);

end