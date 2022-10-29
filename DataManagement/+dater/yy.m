% Type `web Dater/yy.md` for help on this function
% 
% -[IrisToolbox] Macroeconomic Modeling Toolbox
% -Copyright (c) 2007-2022 [IrisToolbox] Solutions Team

function outputDate = yy(varargin)

    if nargin==1 && validate.text(varargin{1})
        outputDate = dater.fromIsoString(Frequency.YEARLY, string(varargin{1}));
        return
    end

    outputDate = dater.datecode(Frequency.YEARLY, varargin{:});

end%

