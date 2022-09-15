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
% * `X` [ Series ] - Input time series.
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
% `X` [ Series ] - Output time series.
%
%
% __Description__
%
%
% __Example__
%

% -IRIS Macroeconomic Modeling Toolbox.
% -Copyright (c) 2007-2022 IRIS Solutions Team.

function this = ifelse(this, test, valueIfTrue, varargin)

persistent ip
if isempty(ip)
    ip = extend.InputParser();
    ip.addRequired('timeSeries', @(x) isa(x, 'Series'));
    ip.addRequired('test', @(x) isa(x, 'function_handle'));
    ip.addRequired('valueIfTrue');
    ip.addOptional('valueIfFalse', []);
end
ip.parse(this, test, valueIfTrue, varargin{:});
valueIfFalse = ip.Results.IfFalse;


    data = this.Data;
    indexTrue = test(data);

    if ~islogical(indexTrue) || ~isequal(size(data), size(indexTrue))
        throw( ...
            exception.Base('Series:IfElseTest', 'error') ...
        );
    end

    if isempty(valueIfTrue) && isempty(valueIfFalse)
        return
    end

    if ~isempty(valueIfTrue)
        if isequal(valueIfTrue, @missing) || isequal(valueIfTrue, @MissingValue)
            valueIfTrue = this.MissingValue;
        end
        data(indexTrue) = valueIfTrue;
    end

    if ~isempty(valueIfFalse)
        if isequal(valueIfFalse, @missing) || isequal(valueIfFalse, @MissingValue)
            valueIfFalse = this.MissingValue;
        end
        data(~indexTrue) = valueIfFalse;
    end

    this.Data = data;
    this = trim(this);

end%

