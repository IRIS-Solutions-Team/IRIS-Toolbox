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

missingValue = this.MissingValue;

data = numeric.fillMissing(data, missingValue, varargin{:});

this = setData(this, startDate:endDate, data);

end%

