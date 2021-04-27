function x = mynansum(x,dim)
% mynansum  [Not a public function] Sum implemented for data with in-sample NaNs.
%
%
% Backend IRIS function.
% No help provided.

% -IRIS Macroeconomic Modeling Toolbox.
% -Copyright (c) 2007-2021 IRIS Solutions Team.

%**************************************************************************

if dim > ndims(x)
    return
end
index = ~isnan(x);
x(~index) = 0;
x = sum(x,dim);

end
