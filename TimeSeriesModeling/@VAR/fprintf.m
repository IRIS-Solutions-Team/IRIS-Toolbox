% fprintf  Write VAR model as formatted model code to text file
%
% Syntax
%--------------------------------------------------------------------------
%
%     [c, d] = fprintf(v, fileName, ...)
%
%
% Input Arguments
%--------------------------------------------------------------------------
%
% * `v` [ VAR ] - VAR object that will be printed to a model file.
%
%
% * `fileName` [ char | cellstr ] - Filename, or filename format string, under
% which the model code will be saved.
%
%
% Output Arguments
%--------------------------------------------------------------------------
%
% * `c` [ cellstr ] - Text string with the model code for each
% parameterisation.
%
%
% * `d` [ cell ] - Parameter databases for each parameterisation; if
% `'HardParameters='` true, the database will be empty.
%
%
% Options
%--------------------------------------------------------------------------
%
% See help on [`sprintf`](VAR/sprintf) for options available.
%
%
% Description
%--------------------------------------------------------------------------
%
% For VAR objects with Na multiple alternative parameterisations, the
% filename `fileName` must be either a 1-by-Na cell array of string with a
% filename for each parameterisation, or a `sprintf` format string where a
% single occurence of `'%g'` will be replaced with the parameterisation
% number.
%
%
% Example
%--------------------------------------------------------------------------
%

% -[IrisToolbox] for Macroeconomic Modeling
% -Copyright (c) 2007-2022 [IrisToolbox] Solutions Team

function [c, d] = fprintf(this, fileName, varargin)

%( Input parser
persistent pp
if isempty(pp)
    pp = extend.InputParser("@VAR/fprintf");
    addRequired(pp, 'fileName', @(x) isstring(x) || ischar(x) || iscellstr(x));
end
%)
parse(pp, fileName);

%--------------------------------------------------------------------------

fileName = string(fileName);

[c, d] = sprintf(this, varargin{:});
for v = 1 : countVariants(this)
    fileName__ = fileName(v);
    if contains(fileName__, "%g")
        fileName__ = sprintf(fileName__, v);
    end
    fid = fopen(fileName__, "w+t");
    fwrite(fid, c(v));
    fclose(fid);
end

end%

