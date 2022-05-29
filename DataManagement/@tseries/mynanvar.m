function x = mynanvar(x, flag, dim)
% mynanvar  Variance implemeted for data with in-sample NaNs
%
% Backend IRIS function
% No help provided

% -IRIS Macroeconomic Modeling Toolbox
% -Copyright (c) 2007-2022 IRIS Solutions Team

%--------------------------------------------------------------------------

ndimsX = ndims(x);
if dim>ndimsX
    x(:) = 0;
    return
end

% Detect and zero NaN observations
indexNaN = isnan(x);
n = sum(~indexNaN, dim);
x(indexNaN) = 0;

% Subtract mean from the data along `dim`.
meanX = sum(x, dim) ./ n;
x = bsxfun(@minus, x, meanX);

% Zero NaN observations again since they have been subtracted mean in
% the previous step and are not zeros any longer
x(indexNaN) = 0;

% Compute the sum of squares along dim
x = sum(x.^2, dim);
if flag==0
    n = n - 1;
end

% Compute variance whenever the number of available data points is
% sufficient
index = n~=0;
x(index) = x(index) ./ n(index);
x(~index) = 0;

end
