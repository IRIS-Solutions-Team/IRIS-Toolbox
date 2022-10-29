% Type `web Dater/hh.md` for help on this function
%
% -[IrisToolbox] Macroeconomic Modeling Toolbox
% -Copyright (c) 2007-2022 [IrisToolbox] Solutions Team

function outputDate = hh(varargin)

    if nargin==1 && validate.text(varargin{1})
        outputDate = dater.fromIsoString(Frequency.HALFYEARLY, string(varargin{1}));
        return
    end

    outputDate = dater.datecode(Frequency.HALFYEARLY, varargin{:});

end%

