function data = pct(data, varargin)
% pct  Percent rate of change
%
% Backend IRIS function
% No help provided

% -IRIS Macroeconomic Modeling Toolbox
% -Copyright (c) 2007-2019 IRIS Solutions Team

%--------------------------------------------------------------------------

data = numeric.roc(data, varargin{:});
data = 100*(data - 1);

end%

