% Type `+databank/+fromFred/data.md` for help on this function
%
% -[IrisToolbox] for Macroeconomic Modeling
% -Copyright (c) 2007-2022 [IrisToolbox] Solutions Team

function [outputDb, status, info] = data(seriesId, varargin)

[outputDb, status, info] = databank.fromFred.master("data", seriesId, varargin{:});

end%

