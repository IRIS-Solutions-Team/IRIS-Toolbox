% hpdi  Highest probability density interval
%
% __Syntax__
%
% Input arguments marked with a `~` sign may be omitted.
%
%     Int = hpdi(X, Coverage, ~Dim)
%
%
% __Input Arguments__
%
% * `X` [ tseries ] - Input time series; HPDIs will be calculated
% separately for each set of data along dimension `Dim`.
%
% * `Coverage` [ numeric ] - Percent coverage of the calculated interval,
% between 0 and 100.
%
% * `~Dim=1` [ numeric ] - Dimension along which the percentiles will be
% calculated.
%
%
% __Output Arguments__
%
% * `Int` [ tseries ] - Output array (if `Dim==1`) or output time series
% (if `Dim>1`) with the lower and upper bounds of the HPDIs.
%
%
% __Description__
%
%
% __Example__
%

function int = hpdi(this, coverage, dim)

% >=R2019b
%(
arguments
    this Series
    coverage (1, 1) double {mustBePositive}
    dim (1, 1) double {mustBeInteger, mustBePositive} = 2
end
%)
% >=R2019b


% <=R2019a
%{
try, dim;
    catch, dim = 2;
end
%}
% <=R2019a


    int = unop(@series.hpdi, this, dim, coverage, dim);

end%

