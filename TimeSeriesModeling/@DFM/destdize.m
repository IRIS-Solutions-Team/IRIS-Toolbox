function [y, Py] = destdize(y, meanY, stdY, Py)
% destdize  Destandardize output data
%
% Backend IRIS function
% No help provided

% -IRIS Macroeconomic Modeling Toolbox.
% -Copyright (c) 2007-2022 IRIS Solutions Team.

%--------------------------------------------------------------------------

y = bsxfun(@times, y, stdY);
y = bsxfun(@plus, y, meanY);

if nargin>3 && nargout>1 && ~isempty(Py)
    ny = size(Py, 1);
    numPeriods = size(y, 2);
    stdY = stdY(:, ones(1, ny));
    for t = 1 : numPeriods
       Py(:, :, t) = stdY .* Py(:, :, t);
       Py(:, :, t) = Py(:, :, t) .* stdY';
    end
else
    Py = double.empty(0);
end

end
