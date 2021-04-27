% Type `web Dater/mm.md` for help on this function
%
% -[IrisToolbox] Macroeconomic Modeling Toolbox
% -Copyright (c) 2007-2021 [IrisToolbox] Solutions Team

function outputDate = mm(varargin)

if nargin>=2 && validate.text(varargin{2})
    varargin{2} = dater.monthFromString(varargin{2});
end

outputDate = dater.datecode(Frequency.MONTHLY, varargin{:});

end%

