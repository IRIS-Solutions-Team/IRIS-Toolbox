function [Y, range, lsy] = getEstimationData(this, inp, range)
% getEstimationData  Input data and range including pre-sample for FAVAR estimation.
%
% Backend IRIS function.
% No help provided.

% -IRIS Macroeconomic Modeling Toolbox.
% -Copyright (c) 2007-2017 IRIS Solutions Team.

%--------------------------------------------------------------------------

lsy = this.NamesEndogenous;
usrRange = range;
[Y, ~, range] = db2array(inp, this.NamesEndogenous, range);
Y = permute(Y, [2, 1, 3]);

if isequal(usrRange, Inf) && nargout>1
    sample = ~any(any(isnan(Y), 3), 1);
    first = find(sample, 1);
    last = find(sample, 1, 'last');
    Y = Y(:, first:last, :);
    range = range(first:last);
end

end
