function x = diff(x, shifts)
% diff  Implement diff for numeric data
%
% Backend IRIS function
% No help provided

% -Copyright (c) 2007-2017 IRIS Solutions Team
% -IRIS Macroeconomic Modeling Toolbox

if nargin<2
    shifts = -1;
end

if isempty(shifts)
    ref = cell(1, ndims(x));
    ref(:) = {':'};
    ref{2} = [ ];
    x = x(ref{:});
    return
end

%--------------------------------------------------------------------------

numShifts = numel(shifts);
x = repmat(x, 1, numShifts) - apply.shift(x, shifts);

end
