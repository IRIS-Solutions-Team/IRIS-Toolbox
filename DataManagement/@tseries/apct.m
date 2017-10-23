function X = apct(X, varargin)
% apct  Annualised percent rate of change.
%
% __Syntax__
%
%     X = apct(X)
%
%
% __Input Arguments__
%
% * `X` [ tseries ] - Input tseries object.
%
%
% __Output Arguments__
%
% * `X` [ tseries ] - Annualised percentage rate of change in the input
% data.
%
%
% __Description__
%
%
% __Example__
%

% -IRIS Macroeconomic Modeling Toolbox.
% -Copyright (c) 2007-2017 IRIS Solutions Team.

persistent INPUT_PARSER
if isempty(INPUT_PARSER)
    INPUT_PARSER = extend.InputParser('tseries/apct');
    INPUT_PARSER.addRequired('TimeSeries', @(x) isa(x, 'tseries'));
    INPUT_PARSER.addOptional('Power', 1, @(x) isscalar(x) && isnumeric(x));
end
INPUT_PARSER.parse(X, varargin{:});
power = INPUT_PARSER.Results.Power;

%--------------------------------------------------------------------------

if isempty(X.data)
    return
end

X = unop(@tseries.implementPercentChange, X, 0, -1, Power);

end
