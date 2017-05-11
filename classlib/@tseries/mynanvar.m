function X = mynanvar(X,Flag,Dim)
% mynanvar  [Not a public function] Variance implemeted for data with in-sample NaNs.
%
% Backend IRIS function.
% No help provided.

% -IRIS Macroeconomic Modeling Toolbox.
% -Copyright (c) 2007-2017 IRIS Solutions Team.

%--------------------------------------------------------------------------

xNDims = ndims(X);
if Dim > xNDims
    X(:) = 0;
    return
end

% Detect and zero NaN observations.
nanInx = isnan(X);
n = sum(~nanInx,Dim);
X(nanInx) = 0;

% Subtract mean from the data along `Dim`.
xMean = sum(X,Dim) ./ n;
X = bsxfun(@minus,X,xMean);

% Zero NaN observations again since they have been subtracted mean in
% the previous step and are not zeros any longer.
X(nanInx) = 0;

% Compute the sum of squares along dim.
X = sum(X.^2,Dim);
if Flag == 0
    n = n - 1;
end

% Compute variance whenever the number of available data points is
% sufficient.
nInx = n ~= 0;
X(nInx) = X(nInx) ./ n(nInx);
X(~nInx) = 0;

end