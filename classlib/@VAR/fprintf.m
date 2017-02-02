function [C,D] = fprintf(This,File,varargin)
% fprintf  Write VAR model as formatted model code to text file.
%
% Syntax
% =======
%
%     [C,D] = fprintf(V,File,...)
%
% Input arguments
% ================
%
% * `V` [ VAR ] - VAR object that will be printed to a model file.
%
% * `File` [ char | cellstr ] - Filename, or filename format string, under
% which the model code will be saved.
%
% - Output arguments
%
% * `C` [ cellstr ] - Text string with the model code for each
% parameterisation.
%
% * `D` [ cell ] - Parameter databases for each parameterisation; if
% `'hardParameters='` true, the database will be empty.
%
% Options
% ========
%
% See help on [`sprintf`](VAR/sprintf) for options available.
%
% Description
% ============
%
% For VAR objects with Na multiple alternative parameterisations, the
% filename `File` must be either a 1-by-Na cell array of string with a
% filename for each parameterisation, or a `sprintf` format string where a
% single occurence of `'%g'` will be replaced with the parameterisation
% number.
%
% Example
% ========
%

% -IRIS Macroeconomic Modeling Toolbox.
% -Copyright (c) 2007-2017 IRIS Solutions Team.

pp = inputParser( );
pp.addRequired('File',@(x) ischar(x) ...
    || (iscellstr(x) && length(This) ==  numel(x)));
pp.parse(File);

%--------------------------------------------------------------------------

[C,D] = sprintf(This,varargin{:});
for iAlt = 1 : length(C)
    if iscellstr(File)
        iFile = File{iAlt};
    else
        iFile = sprintf(File,iAlt);
    end
    char2file(C{iAlt},iFile);
end

end
