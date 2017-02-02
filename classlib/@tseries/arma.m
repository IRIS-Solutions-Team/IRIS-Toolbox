function X = arma(varargin)
% arma  Apply ARMA model to input series.
%
%
% Syntax
% =======
%
%     Y = arma(X,E,Ar,Ma,Range)
%
%
% Input arguments
% ================
% 
% * `X` [ tseries ] - Input time series from which initial condition will
% be constructed.
%
% * `E` [ tseries ] - Input time series with innovations; `NaN` values in
% `E` on `Range` will be replaced with `0`.
%
% * `Ar` [ numeric | empty ] - Row vector of AR polynominal coefficients;
% if empty, `Ar = 1`; see Description.
%
% * `Ma` [ numeric | empty ] - Row vector of MA polynominal coefficients;
% if empty, `Ma = 1`; see Description.
%
% * `Range` [ numeric | char ] - Range on which the output series
% observations will be constructed.
%
%
% Output arguments
% =================
%
% * `X` [ tseries ] - Output time series constructed by running an ARMA
% model on the input series `X` and `E`; the output time series also
% includes p initial conditions where p is the order of the AR polynomial.
%
%
% Options
% ========
%
%
% Description
% ============
%
% The output series is constructed as follows:
%
% $$ A(L) X_t = M(L) E_t $$
%
% where $A(L) = A_0 + A_1 L + \cdots$ and $M(L)=M_0 + M_1 L + \cdots$ are
% polynomials in lag operator $L$ defined by the vectors `Ar` and `Ma`. In
% other words,
%
% $$ X_t = \frac{1}{A_1} \left( -A_2 X_{t-1} - A_3 X_{t-2} - \cdots
%            + M_0 E_t + M_1 E_{t-1} + \cdots \right) . $$
%
% Note that the coefficient $A_0$ is `Ar(1)`, $A_1$ is `Ar(2)`, and so on.
%
%
% Example
% ========
%
% Construct an AR(1) process with autoregression coefficient 0.8, built
% from normally distributed innovations:
%
%     X = Series(0:20,0);
%     E = Series(1:20,@randn);
%     X = arma(X,E,[1,-0.8],[ ],1:20);
%     plot(X);
%

% -IRIS Macroeconomic Modeling Toolbox.
% -Copyright (c) 2007-2017 IRIS Solutions Team.

[X,E,Ar,Ma,Range,varargin] = ...
    irisinp.parser.parse('tseries.arma',varargin{:}); %#ok<ASGLU>

Ar = Ar(:).';
if isempty(Ar)
    Ar = 1;
elseif Ar(1)~=1
    Ar = Ar / Ar(1);
end

Ma = Ma(:).';
if isempty(Ma)
    Ma = 1;
end

%--------------------------------------------------------------------------

pa = length(Ar) - 1;
pm = length(Ma) - 1;
p = max(pa,pm);

nPer = length(Range);
xRange = Range(1)-p : Range(end);
nXPer = length(xRange);

XData = rangedata(X,xRange);
EData = rangedata(E,xRange);
EData(isnan(EData)) = 0;
for t = p+1 : nXPer
    XData(t,:) = ...
        -Ar(2:end)*XData(t-1:-1:t-pa,:) ...
        + Ma*EData(t:-1:t-pm,:);
end

XData(1:end-nPer-pa,:) = [ ];
X = replace(X,XData,Range(1)-pa);

end
