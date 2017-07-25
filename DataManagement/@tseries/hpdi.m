function This = hpdi(This,Prob,Dim)
% hpdi  Highest probability density interval.
%
% Syntax
% =======
%
%     int = hpdi(x,prob)
%
% Input arguments
% ================
%
% * `x` [ tseries ] - Input data with random draws in each period.
%
% * `prob` [ numeric ] - Percent coverage of the computed interval, between
% 0 and 100.
%
% Output arguments
% =================
%
% * `int` [ tseries ] - Output tseries object with two columns, i.e. lower
% bounds and upper bounds for each period.
%
% Description
% ============
%
% Example
% ========
%

% -IRIS Macroeconomic Modeling Toolbox.
% -Copyright (c) 2007-2017 IRIS Solutions Team.

try
    Dim; %#ok<VUNUS>
catch
    Dim = 1;
end

if Dim > 2
    Dim = 2;
end

%--------------------------------------------------------------------------

[low,high] = tseries.myhpdi(This.data(:,:),Prob,Dim);

if Dim == 1
    This = [low;high];
else
    This.data = [low,high];
    This.Comment = {'HPDI low','HPDI high'};
    This = trim(This);
end

end