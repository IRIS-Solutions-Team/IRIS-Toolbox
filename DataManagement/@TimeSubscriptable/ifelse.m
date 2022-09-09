function this = ifelse(this, test, ifTrue, varargin)

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
