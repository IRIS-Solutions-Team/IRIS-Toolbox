function [this, meanX, stdX] = stdize(this, varargin)
% stdize  Standardize tseries data by subtracting mean and dividing by std deviation
%{
% ## Syntax ##
%
% Input arguments marked with a `~` sign may be omitted
%
%     [x, meanX, stdX] = stdize(x, ~normalize)
%
%
% ## Input Arguments ##
%
% __`x` [ NumericTimeSubscriptable ] -
% Input time series whose data will be normalized.
%
% __`~normalize` [ `0` | `1` ] -
% Setting `normalize=0` normalizes the std deviation by N-1, `normalize=1`
% normalizes by N, where N is the sample length.
%
%
% ## Output Arguments ##
%
% __`x` [ NumericTimeSubscriptable ] -
% Output time series with standardized data.
%
% __`meanX` [ numeric ] -
% Estimated mean subtracted from the input time series observations.
%
% __`stdX` [ numeric ] -
% Estimated std deviation by which the input time series observations have
% been divided.
%
%
% ## Description ##
%
%
% ## Example ##
%
%}

% -IRIS Macroeconomic Modeling Toolbox
% -Copyright (c) 2007-2022 IRIS Solutions Team

persistent parser
if isempty(parser)
    parser = extend.InputParser('NumericTimeSubscriptable.stdize');
    parser.addRequired('inputSeries', @(x) isa(x, 'NumericTimeSubscriptable'));
    parser.addOptional('normalize', 0, @(x) isequal(x, 0) || isequal(x, 1));
end
parser.parse(this, varargin{:});
normalize = parser.Results.normalize;

%--------------------------------------------------------------------------

[this.Data, meanX, stdX] = numeric.stdize(this.Data, normalize);

end%

