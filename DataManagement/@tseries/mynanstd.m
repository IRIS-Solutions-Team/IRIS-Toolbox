function X = mynanstd(X,Flag,Dim)
% mynanstd  Std deviation implemented for data with in-sample NaNs
%
% Backend IRIS function.
% No help provided.

% -IRIS Macroeconomic Modeling Toolbox.
% -Copyright (c) 2007-2022 IRIS Solutions Team.

%--------------------------------------------------------------------------

X = tseries.mynanvar(X,Flag,Dim);
X = sqrt(X);

end
