function this = ifelse(this, test, ifTrue, varargin)
% ifelse  Replace time series values based on a test condition
%
% __Syntax__
%
% Input arguments marked with a `~` sign may be omitted.
%
%     X = ifelse(X, Test, IfTrue, ~IfFalse)
%
%
% __Input Arguments__
%
% * `X` [ TimeSubscriptable ] - Input time series.
%
% * `Test` [ function_handle ] - Test function that returns `true` or
% `false` for each observation.
%
% * `IfTrue` [ any | empty ] - Value assigned to observations for which the
% `Test` function returns `true`; if isempty, these observations will
% remain unchanged.
%
% * `IfFalse` [ any | empty ] - Value assigned to observations for which
% the `Test` function returns `false`; if isempty or omitted, these
% observations will remain unchanged.
%
% 
% __Output Arguments__
%
% `X` [ TimeSubscriptable ] - Output time series.
%
%
% __Description__
%
%
% __Example__
%

% -IRIS Macroeconomic Modeling Toolbox.
% -Copyright (c) 2007-2020 IRIS Solutions Team.

persistent inputParser
if isempty(inputParser)
    inputParser = extend.InputParser('TimeSubscriptable.ifelse');
    inputParser.addRequired('TimeSeries', @(x) isa(x, 'TimeSubscriptable'));
    inputParser.addRequired('Test', @(x) isa(x, 'function_handle'));
    inputParser.addRequired('IfTrue');
    inputParser.addOptional('IfFalse', [ ]);
end
inputParser.parse(this, test, ifTrue, varargin{:});
ifFalse = inputParser.Results.IfFalse;

%--------------------------------------------------------------------------

data = this.Data;
indexTrue = test(data);

if ~islogical(indexTrue) || ~isequal(size(data), size(indexTrue))
    throw( ...
        exception.Base('TimeSubscriptable:IfElseTest', 'error') ...
    );
end

if isempty(ifTrue) && isempty(ifFalse)
    return
end

if ~isempty(ifTrue)
    if isequal(ifTrue, @missing) || isequal(ifTrue, @MissingValue)
        ifTrue = this.MissingValue;
    end
    data(indexTrue) = ifTrue;
end

if ~isempty(ifFalse)
    if isequal(ifFalse, @missing) || isequal(ifFalse, @MissingValue)
        ifFalse = this.MissingValue;
    end
    data(~indexTrue) = ifFalse;
end

this.Data = data;
this = trim(this);

end
