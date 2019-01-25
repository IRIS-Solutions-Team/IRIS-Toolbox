% dot  Gross rate of growth pseudofunction.
%
% Syntax
% =======
%
%     dot(Expr)
%     dot(Expr,K)
%
% Description
% ============
%
% If the input argument `k` is not specified, this pseudofunction expands
% to
%
%     ((Expr)/(Expr{-1}))
%
% If the input argument `k` is specified, it expands to
%
%     ((Expr)/(Expr{k}))
%
% The two derived expressions, `Expr{-1}` and `Expr{k}`, are based on
% `Expr`, and have all its time subscripts shifted by --1 or by `k`
% periods, respectively.
%
% Example
% ========
%
% The following two lines
%
%     dot(Z)
%     dot(X+Y,-2)
%
% will expand to
%
%     ((Z)/(Z{-1}))
%     ((X+Y)/(X{-2}+Y{-2}))
%

% -IRIS Macroeconomic Modeling Toolbox.
% -Copyright (c) 2007-2019 IRIS Solutions Team.
