function [Max, Inx] = max(This, Dim)
% max  Largest elements in tseries object.
%
% __Syntax__
%
%     [M, Inx] = max(X)
%     [M, Inx] = max(X, Dim)
%
%
% __Input Arguments__
%
% * `X` [ tseries ] - Tseries object whose data will be searched for
% maxima.
%
% * `Dim` [ numeric ] - Dimension along which the largest element will be
% searched for; if omitted, `Dim = 1` (i.e. along time dimension).
%
%
% __Output Arguments__
%
% * `M` [ numeric ] - Largest elements found.
%
% * `Inx` [ numeric ] - Positions or dates of the largest elements; see
% Description and Examples.
%
%
% __Description__
%
% The behavior of the function is identical to the standard Matlab `max`
% function except that `Inx` is%
%
% * a plain array of dates when `Dim = 1` (or `Dim` is omitted) indicating
% the dates at which the largest values occur in each vector along
% specified dimension;
%
% * a tseries object with positions of occurrences of the largest values in
% each vector along specified dimension.
%
%
% __Example__
%
% This is how the function works when applied to first dimension (time
% dimension):
%
%     >> x = tseries(qq(2010, 1:4), [1;4;3;2]);
%     >> [m, pos] = max(x);
%     >> m
%     m =
%          4
%     >> pos
%     pos =
%       1x1 Quarterly Date(s)
%         '2010Q2'
%
% 
% __Example__
%
% This is how the function works when applied to higher dimensions. Find
% the largest value in each row (i.e. along 2nd dimension) and also the
% columns in which the largest values occur.
%
%     >> x = tseries(qq(2010, 1:4), rand(4, 5))
%     x =
%         tseries object: 4-by-5
%         2010Q1:   0.71497     0.27981     0.54093     0.67733     0.96819
%         2010Q2:   0.97681    0.049111     0.20968     0.59677      0.9205
%         2010Q3:  0.091115     0.54422     0.29992     0.31507     0.35222
%         2010Q4:   0.82969      0.7949     0.59538     0.88024     0.12539
%         ''    ''    ''    ''    ''
%         user data: empty
%     >> [m, inx] = max(x, 2);
%     >> m
%     m =
%         tseries object: 4-by-1
%         2010Q1:  0.96819
%         2010Q2:  0.97681
%         2010Q3:  0.54422
%         2010Q4:  0.88024
%         ''
%         user data: empty
%     >> inx
%     inx =
%         tseries object: 4-by-1
%         2010Q1:  5
%         2010Q2:  1
%         2010Q3:  2
%         2010Q4:  4
%         ''
%         user data: empty
%

% -IRIS Macroeconomic Modeling Toolbox.
% -Copyright (c) 2007-2018 IRIS Solutions Team.

try
    Dim; %#ok<VUNUS>
catch
    Dim = 1;
end

%--------------------------------------------------------------------------

[Max, Inx] = unopinx(@max, This, Dim, [ ], Dim);

end
