function [this, datesMissing] = fillMissing(this, range, varargin)
% fillMissing  Fill missing time series observations
%{
% ## Syntax ##
%
%     [x, datesMissing] = fillMissing(x, range, method)
%}

% -IRIS Macroeconomic Modeling Toolbox
% -Copyright (c) 2007-2020 IRIS Solutions Team

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

[data, startDate, endDate] = getDataFromTo(this, startDate, endDate);

missingTest = this.MissingTest;
inxMissing = missingTest(data);
if nargout>=2
    if any(inxMissing)
        datesMissing = (round(100*startDate) + round(100*(find(inxMissing)-1)))/100;
        datesMissing = DateWrapper(datesMissing);
    else
        datesMissing = DateWrapper.empty(0, 1);
    end
end

if ~any(inxMissing(:))
    return
end

conversionFunction = [ ];
if islogical(data)
    data = double(data);
    conversionFunction = @logical;
end

try
    % Call built-in `fillmissing` and supply the locations of missing values
    data = fillmissing(data, varargin{:}, 'MissingLocations', inxMissing);
catch
    % Older Matlab releases do not have the MissingLocation option
    data = fillmissing(data, varargin{:});
end

if ~isempty(conversionFunction)
    inxNaN = isnan(data);
    data(inxNaN) = this.MissingValue;
    data = conversionFunction(data);
end

%this = fill(this, data, startDate);
this = setData(this, startDate:endDate, data);

end%

