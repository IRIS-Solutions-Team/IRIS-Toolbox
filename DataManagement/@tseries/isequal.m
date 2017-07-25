function flag = isequal(this, that)
% isequal  Compare two tseries objects.
%
% Syntax
% =======
%
%     Flag = isequal(X1, X2)
%
%
% Input arguments
% ================
%
% * `X1`, `X2` [ tseries ] - Two tseries objects that will be compared.
%
%
% Output arguments
% =================
%
% * `Flag` [ `true` | `false` ] - True if the two input tseries objects
% have identical contents: start date, data, comments, userdata, and
% captions.
%
%
% Description
% ============
%
% The function `isequaln` is used to compare the tseries data, i.e. `NaN`s
% are correctly matched.
%
%
% Example
% ========
%

% -IRIS Macroeconomic Modeling Toolbox.
% -Copyright (c) 2007-2017 IRIS Solutions Team.

%--------------------------------------------------------------------------

flag = isa(this, 'tseries') && isa(that, 'tseries') ...
    && isequal@shared.UserDataContainer(this, that) ...
    && isequaln(this.start, that.start) ...
    && isequaln(this.data, that.data);

end
