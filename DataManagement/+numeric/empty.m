function x = empty(x, dim)
% empty  Empty numeric array in selected dimension
%
% Backend IRIS function
% No help provided.

% -Copyright (c) 2007-2020 IRIS Solutions Team
% -IRIS Macroeconomic Modeling Toolbox

%--------------------------------------------------------------------------

ref = cell(1, ndims(x));
ref(:) = {':'};
ref{dim} = [ ];
y = x(ref{:});

end
