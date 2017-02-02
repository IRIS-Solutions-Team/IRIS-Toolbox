function [flag, lsMissing] = chkmissing(this, d, start, varargin)
% chkmissing  Check for missing initial values in simulation database.
%
% Syntax
% =======
%
%     [Ok, Miss] = chkmissing(M, D, Start)
%
%
% Input arguments
% ================
%
% * `M` [ model ] - Model object.
%
% * `D` [ struct ] - Input database for the simulation.
%
% * `Start` [ numeric ] - Start date for the simulation.
%
%
% Output arguments
% =================
%
% * `Ok` [ `true` | `false` ] - True if the input database `D` contains
% all required initial values for simulating model `M` from date `Start`.
%
% * `Miss` [ cellstr ] - List of missing initial values.
%
%
% Options
% ========
%
% * `'error='` [ *`true`* | `false` ] - Throw an error if one or more
% initial values are missing.
%
%
% Description
% ============
%
% This function does not perform any simulation; it only checks for missing
% initial values in an input database.
%
%
% Example
% ========
%

% -IRIS Macroeconomic Modeling Toolbox.
% -Copyright (c) 2007-2017 IRIS Solutions Team.

opt = passvalopt('model.chkmissing',varargin{:});

%--------------------------------------------------------------------------

lsMissing = cell(1, 0);

nAlt = length(this.Variant);
[~, ~, nb, nf] = sizeOfSolution(this.Vector);
vecXb = this.Vector.Solution{2}(nf+1:end);

ixInit = model.Variant.get(this.Variant, 'IxInit', ':');

ixAvailable = true(1, nb);
for j = 1 : nb
    pos = real( vecXb(j) );
    sh = imag( vecXb(j) );
    name = this.Quantity.Name{pos};
    lag = sh - 1;
    try
        value = rangedata(d.(name), start+lag);
        value = value(:, :);
        if numel(value)==1 && nAlt>1
            value = repmat(value, 1, nAlt);
        end
        ix = permute(ixInit(1, j, :), [1, 3, 2]);
        ixAvailable(j) = all(~isnan(value) | ~ix);
    catch
        ixAvailable(j) = false;
    end
end

flag = all(ixAvailable);
if ~flag
    lsMissing = printSolutionVector(this, vecXb(~ixAvailable));
    if opt.error
        throw( ...
            exception.Base('Model:MissingInitCond', 'error'), ...
            lsMissing{:} ...
            );
    end
end

end
