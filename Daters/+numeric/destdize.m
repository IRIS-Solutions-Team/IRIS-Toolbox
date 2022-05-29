function x = destdize(x, meanX, stdX)
% destdize  Destandardize numeric data
%
% Backend IRIS function
% No help provided

% -IRIS Macroeconomic Modeling Toolbox
% -Copyright (c) 2007-2022 IRIS Solutions Team

%--------------------------------------------------------------------------

% Add back std devs
x = bsxfun(@times, x, stdX);

% Add back mean
x = bsxfun(@plus, x, meanX);

end
