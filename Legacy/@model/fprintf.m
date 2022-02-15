% Fprintf  Print model object back to model file
%
% -IRIS Macroeconomic Modeling Toolbox.
% -Copyright (c) 2007-2021 IRIS Solutions Team.

function C = fprintf(this, fileName, varargin)

C = sprintf(this, varargin{:});
textual.write(C, fileName);

end%

