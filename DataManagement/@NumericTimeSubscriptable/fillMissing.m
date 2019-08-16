function this = fillMissing(this, range, varargin)
% fillMissing  Fill missing time series observations

% -IRIS Macroeconomic Modeling Toolbox
% -Copyright (c) 2007-2019 IRIS Solutions Team

if isempty(this.Data)
    return
end

persistent parser
if isempty(parser)
    parser = extend.InputParser('NumericTimeSubscriptable.fillMissing');
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

% Call built-in `fillmissing` and supply the locations of missing values
data = fillmissing(data, varargin{:}, 'MissingLocations', inxMissing);

this = fill(this, data, startDate);

end%

