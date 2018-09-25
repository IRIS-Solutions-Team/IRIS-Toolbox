function outputDate = hh(year, halfyear)
% numeric.hh  IRIS date code for half-yearly dates
% 
% Backend IRIS function
% No help provided

% -IRIS Macroeconomic Modeling Toolbox
% -Copyright (c) 2007-2018 IRIS Solutions Team

%--------------------------------------------------------------------------

if nargin<2
    halfyear = 1;
end

outputDate = numeric.datecode(2, year, halfyear);

end%

