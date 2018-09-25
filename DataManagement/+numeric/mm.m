function outputDate = mm(year, month)
% numeric.mm  IRIS date code for monthly dates
%
% Backend IRIS function
% No help provided

% -IRIS Macroeconomic Modeling Toolbox
% -Copyright (c) 2007-2018 IRIS Solutions Team

%--------------------------------------------------------------------------

if nargin<2
    month = 1;
end

outputDate = numeric.datecode(12, year, month);

end%

