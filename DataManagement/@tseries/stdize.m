function [this, meanX, stdX] = stdize(this, varargin)
% stdize  Standardize tseries data by subtracting mean and dividing by std deviation
%
% __Syntax__
%
% Input arguments marked with a `~` sign may be omitted.

%     [X, MeanX, StdX] = stdize(X, ~Normalize)
%
%
% __Input Arguments__
%
% * `X` [ tseries ] - Input tseries object whose data will be normalized.
%
% * `~Normalize` [ `0` | `1` ] - `Normalize==0` normalizes the std
% deviation by N-1, `Normalize==1` normalizes by N, where N is the sample
% length.
%
%
% __Output Arguments__
%
% * `X` [ tseries ] - Output tseries object with standardized data.
%
% * `MeanX` [ numeric ] - Estimated mean subtracted from the input tseries
% observations.
%
% * `StdX` [ numeric ] - Estimated std deviation by which the input tseries
% observations have been divided.
%
%
% __Description__
%
%
% __Example__
%

% -IRIS Macroeconomic Modeling Toolbox.
% -Copyright (c) 2007-2019 IRIS Solutions Team.

persistent INPUT_PARSER
if isempty(INPUT_PARSER)
    INPUT_PARSER = extend.InputParser('tseries.stdize');
    INPUT_PARSER.addRequired('TimeSeries', @(x) isa(x, 'tseries'));
    INPUT_PARSER.addOptional('Normalize', 0, @(x) isequal(x, 0) || isequal(x, 1));
end
INPUT_PARSER.parse(this, varargin{:});
normalize = INPUT_PARSER.Results.Normalize;

%--------------------------------------------------------------------------

[this.Data, meanX, stdX] = numeric.stdize(this.Data, normalize);

end
