function X = mynanmean(X,Dim)
% mynansum  [Not a public function] Sum implemented for data with in-sample NaNs.
%
% Backend IRIS function.
% No help provided.

% -IRIS Macroeconomic Modeling Toolbox.
% -Copyright (c) 2007-2018 IRIS Solutions Team.

%--------------------------------------------------------------------------

if Dim > ndims(X)
    return
end

% Detect and zero NaN observations.
nanindex = isnan(X);
n = sum(~nanindex,Dim);
X(nanindex) = 0;

% Compute sum whenever there is at least one data point available.
nindex = n > 0;
X = sum(X,Dim);
X(nindex) = X(nindex) ./ n(nindex);
X(~nindex) = NaN;

end