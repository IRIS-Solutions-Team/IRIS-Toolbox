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

% -[IrisToolbox] for Macroeconomic Modeling
% -Copyright (c) 2007-2020 IRIS Solutions Team

%--------------------------------------------------------------------------

flag = isa(this, 'tseries') && isa(that, 'tseries') ...
    && isequaln(this.Comment, that.Comment) ...
    && isequaln(this.UserData, that.UserData) ...
    && isequaln(this.Caption, that.Caption) ...
    && isequaln(this.BaseYear, that.BaseYear) ...
    && isequaln(this.Start, that.Start) ...
    && isequaln(this.Data, that.Data);

end%

