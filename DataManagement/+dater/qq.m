% Type `web Dater/qq.md` for help on this function
%
% -IRIS Macroeconomic Modeling Toolbox
% -Copyright (c) 2007-2020 IRIS Solutions Team

function outputDate = qq(varargin)

outputDate = dater.datecode(Frequency.QUARTERLY, varargin{:});

end%

