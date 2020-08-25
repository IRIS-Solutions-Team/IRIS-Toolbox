function dateCode = ww(year, varargin)
% numeric.ww  IRIS date code for weekly dates
% 
% Backend IRIS function
% No help provided

% -IRIS Macroeconomic Modeling Toolbox
% -Copyright (c) 2007-2020 IRIS Solutions Team

%--------------------------------------------------------------------------

if nargin==3
    % * ww(year, month, day)
    x = datenum(year, varargin{:});
    dateCode = numeric.day2ww(x);
else
    % * ww(year, week)
    % * ww(year)
    dateCode = numeric.datecode(52, year, varargin{:});
end

end%

