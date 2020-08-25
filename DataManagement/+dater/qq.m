function outputDate = qq(year, quarter)
% numeric.qq  IRIS date code for quarterly dates
% 
% Backend IRIS function
% No help provided

% -IRIS Macroeconomic Modeling Toolbox
% -Copyright (c) 2007-2020 IRIS Solutions Team

%--------------------------------------------------------------------------

if nargin<2
    quarter = 1;
end

outputDate = numeric.datecode(4, year, quarter);

end%
