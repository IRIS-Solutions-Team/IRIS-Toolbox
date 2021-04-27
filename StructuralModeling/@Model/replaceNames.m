% Type `web Model/replaceNames.md` for help on this function
%
% -[IrisToolbox] for Macroeconomic Modeling
% -Copyright (c) 2007-2021 [IrisToolbox] Solutions Team

function this = replaceNames(this, varargin)
this.Quantity = replaceNames(this.Quantity, varargin{:});
end%

