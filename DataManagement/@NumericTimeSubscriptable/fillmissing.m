function this = fillmissing(this, range, varargin)
% fillmissing  Fill missing time series observations

% -IRIS Macroeconomic Modeling Toolbox
% -Copyright (c) 2007-2019 IRIS Solutions Team

persistent parser
if isempty(parser)
    parser = extend.InputParser('NumericTimeSubscriptable.fillmissing');
    addRequired(parser, 'InputSeries', @(x) isa(x, 'NumericTimeSubscriptable'));
    addRequired(parser, 'Range', @DateWrapper.validateRangeInput);
end
parse(parser, this, range);

%-------------------------------------------------------------------------- 

range = double(range);
startDate = range(1);
endDate = range(end);

[data, startDate] = getDataFromTo(this, startDate, endDate);

missingTest = this.MissingTest;
inxMissing = missingTest(data);

if ~any(inxMissing(:))
    return
end

data = fillmissing(data, varargin{:}, 'MissingLocations', inxMissing);
this = fill(this, data, startDate);

end%

