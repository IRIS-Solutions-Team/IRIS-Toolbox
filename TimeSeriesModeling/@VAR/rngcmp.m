function flag = rngcmp(V1, V2)
% rngcmp  True if two VAR objects have been estimated using the same dates.
%
% __Syntax__
% -------
%
%     flag = rngcmp(V1, V2)
%
%
% __Input Arguments__
%
% * `V1`, `V2` [ VAR ] - Two estimated VAR objects.
%
%
% __Output Arguments__
% 
% * `flag` [ `true` | `false` ] - True if the two VAR objects, `V1` and
% `V2`, have been estimated using observations at the same dates.
%
%
% __Description__
%
%
% __Example__
%

% -IRIS Macroeconomic Modeling Toolbox.
% -Copyright (c) 2007-2022 IRIS Solutions Team.

pp = inputParser( );
pp.addRequired('V1', @(x) isa(x, 'VAR'));
pp.addRequired('V2', @(x) isa(x, 'VAR'));
pp.parse(V1, V2);

%--------------------------------------------------------------------------

nv1 = size(V1.A, 3);
nv2 = size(V2.A, 3);
nv = max(nv1, nv2);

flag = false(1, nv);
for v = 1 : nv
    fitted1 = V1.IxFitted(:, :, min(v, end));
    fitted2 = V2.IxFitted(:, :, min(v, end));
    datesFitted1 = V1.Range(fitted1);
    datesFitted2 = V2.Range(fitted2);
    flag(v) = numel(datesFitted1)==numel(datesFitted2) && all(dater.eq(datesFitted1, datesFitted2));
end

end%

