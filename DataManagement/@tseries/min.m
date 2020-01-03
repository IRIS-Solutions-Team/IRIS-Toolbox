function [Min,Inx] = min(This,Dim)
% min  Smallest elements in tseries object.
%
% Syntax
% =======
%
%     [M,Inx] = min(X)
%     [M,Inx] = min(X,Dim)
%
% Input arguments
% ================
%
% * `X` [ tseries ] - Tseries object whose data will be searched for
% minima.
%
% * `Dim` [ numeric ] - Dimension along which the smallest element will be
% searched for; if omitted, `Dim = 1` (i.e. along time dimension).
%
% Output arguments
% =================
%
% * `M` [ numeric ] - Largest elements found.
%
% * `Inx` [ numeric ] - Positions or dates of the smallest elements; see
% Description and Examples.
%
% Description
% ============
%
% The behavior of the function is identical to the standard Matlab `min`
% function except that `Inx` is%
%
% * a plain array of dates when `Dim = 1` (or `Dim` is omitted) indicating
% the dates at which the smallest values occur in each vector along
% specified dimension;
%
% * a tseries object with positions of occurrences of the smallest values
% in each vector along specified dimension.
%
% Example
% ========
%
% This is how the function works when applied to first dimension (time
% dimension):
%
%     >> x = tseries(qq(2010,1:4),[1;4;3;2]);
%     >> [m,inx] = min(x);
%     >> m
%     m =
%          4
%     >> inx
%     inx =
%        8.0410e+03
%     >> dat2char(inx)
%     ans =
%     2010Q2 
% 
% Example
% ========
%
% This is how the function works when applied to higher dimensions. Find
% the smallest value in each row (i.e. along 2nd dimension) and also the
% columns in which the smallest values occur.
%
%     >> x = tseries(qq(2010,1:4),rand(4,5))
%     x =
%         tseries object: 4-by-5
%         2010Q1:   0.71497     0.27981     0.54093     0.67733     0.96819
%         2010Q2:   0.97681    0.049111     0.20968     0.59677      0.9205
%         2010Q3:  0.091115     0.54422     0.29992     0.31507     0.35222
%         2010Q4:   0.82969      0.7949     0.59538     0.88024     0.12539
%         ''    ''    ''    ''    ''
%         user data: empty
%     >> [m,inx] = min(x,2);
%     >> m
%     m =
%         tseries object: 4-by-1
%         2010Q1:   0.27981
%         2010Q2:  0.049111
%         2010Q3:  0.091115
%         2010Q4:   0.12539
%         ''
%         user data: empty
%     >> inx
%     inx =
%         tseries object: 4-by-1
%         2010Q1:  2
%         2010Q2:  2
%         2010Q3:  1
%         2010Q4:  5
%         ''
%         user data: empty
%

% -IRIS Macroeconomic Modeling Toolbox.
% -Copyright (c) 2007-2020 IRIS Solutions Team.

try
    Dim; %#ok<VUNUS>
catch
    Dim = 1;
end

%--------------------------------------------------------------------------

[Min,Inx] = unopinx(@min,This,Dim,[ ],Dim);

end
