% Type `web Dater/qq.md` for help on this function
%
% -[IrisToolbox] Macroeconomic Modeling Toolbox
% -Copyright (c) 2007-2022 [IrisToolbox] Solutions Team

function outputDate = qq(varargin)

outputDate = dater.datecode(Frequency.QUARTERLY, varargin{:});

end%

