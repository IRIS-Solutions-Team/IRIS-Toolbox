function int = hpdi(this, coverage, varargin)
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

% -IRIS Macroeconomic Modeling Toolbox.
% -Copyright (c) 2007-2019 IRIS Solutions Team.

persistent inputParser
if isempty(inputParser)
    inputParser = extend.InputParser('tseries.hpdi');
    inputParser.addRequired('InputSeries', @(x) isa(x, 'tseries'));
    inputParser.addRequired('Coverage', @(x) isnumeric(x) && isscalar(x) && x>=0 && x<=100);
    inputParser.addOptional('Dim', 2, @(x) isnumeric(x) && isscalar(x) && x==round(x) && x>=1);
end
inputParser.parse(this, coverage, varargin{:});
dim = inputParser.Results.Dim;

%--------------------------------------------------------------------------

int = unop(@numeric.hpdi, this, dim, coverage, dim);

end
