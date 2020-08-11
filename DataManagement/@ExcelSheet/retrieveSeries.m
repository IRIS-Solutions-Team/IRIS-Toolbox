function outputSeries = retrieveSeries(this, locationRef, varargin)
% retrieveSeries  Retrieve time series from ExcelSheet
%{
% ## Syntax ##
%
%     output = function(input, ...)
%
%
% ## Input Arguments ##
%
% __`input`__ [ | ] -
% Description
%
%
% ## Output Arguments ##
%
% __`output`__ [ | ] -
% Description
%
%
% ## Options ##
%
% __`OptionName=Default`__ [ | ] -
% Description
%
%
% ## Description ##
%
%
% ## Example ##
%
%}

% -[IrisToolbox] for Macroeconomic Modeling
% -Copyright (c) 2007-2020 [IrisToolbox] Solutions Team

dataRange = this.DataRange;
if isempty(dataRange)
    exception.error([
        "ExcelSheet:CannotSetDates"
        "DataRange or (DataStart and DataEnd) need to be set first before "
        "setting or retrieving time series."
    ]);
end

%( Input parser
persistent pp
if isempty(pp)
    pp = extend.InputParser('ExcelSheet.retrieveSeries');
    addRequired(pp, 'excelSheet', @(x) isa(x, 'ExcelSheet'));
    addRequired(pp, 'locationRef', @(x) ~isempty(x));

    addParameter(pp, 'Aggregator', [ ], @(x) isempty(x) || isa(x, 'function_handle'));
    addParameter(pp, 'Comment', '', @(x) validate.string(x) || validate.list(x));
end
%)
opt = parse(pp, this, locationRef, varargin{:});

if ~iscell(locationRef)
    locationRef = { locationRef };
end
location = cell(size(locationRef));
if strcmpi(this.Orientation, "Row")
    [location{:}] = ExcelReference.decodeRow(locationRef{:});
    dataCutout = this.Buffer([location{:}], dataRange);
    dataCutout = transpose(dataCutout);
else
    [location{:}] = ExcelReference.decodeColumn(locationRef{:});
    dataCutout = this.Buffer(dataRange, [location{:}]);
end
data = nan(size(dataCutout));
inxValid = cellfun(@isnumeric, dataCutout);
dataCutout(~inxValid) = { NaN };
for i = 1 : size(dataCutout, 2)
    data(:, i) = [dataCutout{:, i}];
end
if isempty(opt.Comment)
    comment = retrieveDescription(this, locationRef, varargin{:});
else
    comment = opt.Comment;
end
if isa(opt.Aggregator, 'function_handle')
    data = opt.Aggregator(data, 2);
end

outputSeries = Series(this.Dates, data, comment);

end%

