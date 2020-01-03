function [c, d] = fprintf(this, fileName, varargin)
% fprintf  Write VAR model as formatted model code to text file.
%
% Syntax
% =======
%
%     [c, d] = fprintf(v, fileName, ...)
%
%
% Input arguments
% ================
%
% * `v` [ VAR ] - VAR object that will be printed to a model file.
%
% * `fileName` [ char | cellstr ] - Filename, or filename format string, under
% which the model code will be saved.
%
% Output arguments
% =================
%
% * `c` [ cellstr ] - Text string with the model code for each
% parameterisation.
%
% * `d` [ cell ] - Parameter databases for each parameterisation; if
% `'HardParameters='` true, the database will be empty.
%
%
% Options
% ========
%
% See help on [`sprintf`](VAR/sprintf) for options available.
%
%
% Description
% ============
%
% For VAR objects with Na multiple alternative parameterisations, the
% filename `fileName` must be either a 1-by-Na cell array of string with a
% filename for each parameterisation, or a `sprintf` format string where a
% single occurence of `'%g'` will be replaced with the parameterisation
% number.
%
%
% Example
% ========
%

% -IRIS Macroeconomic Modeling Toolbox.
% -Copyright (c) 2007-2020 IRIS Solutions Team.

pp = inputParser( );
pp.addRequired('fileName', @(x) ischar(x) || (iscellstr(x) && length(this)==numel(x)));
pp.parse(fileName);

%--------------------------------------------------------------------------

[c, d] = sprintf(this, varargin{:});
for iAlt = 1 : length(c)
    if iscellstr(fileName)
        iFile = fileName{iAlt};
    else
        iFile = sprintf(fileName, iAlt);
    end
    char2file(c{iAlt}, iFile);
end

end
