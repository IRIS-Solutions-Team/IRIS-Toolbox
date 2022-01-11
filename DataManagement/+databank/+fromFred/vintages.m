% Type `+databank/+fromFred/vintages.md` for help on this function
%
% -[IrisToolbox] for Macroeconomic Modeling
% -Copyright (c) 2007-2021 [IrisToolbox] Solutions Team

function [outputDb, status, info] = vintages(seriesId, varargin)

[outputDb, status, info] = databank.fromFred.master("vintages", seriesId, varargin{:});

end%

