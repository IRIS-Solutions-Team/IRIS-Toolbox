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

% -IRIS Macroeconomic Modeling Toolbox
% -Copyright (c) 2007-2020 IRIS Solutions Team


dataRange = this.DataRange;
if isempty(dataRange)
    THIS_ERROR = { 'ExcelSheet:CannotSetDates'
                   'Set DataRange or (DataStart and DataEnd) first before setting or retrieving time series' };
    throw( exception.Base(THIS_ERROR, 'error') );
end

persistent parser
if isempty(parser)
    parser = extend.InputParser('ExcelSheet.retrieveSeries');
    parser.addRequired('excelSheet', @(x) isa(x, 'ExcelSheet'));
    parser.addRequired('locationRef', @(x) ~isempty(x));
    % Options
    parser.addParameter('Aggregator', [ ], @(x) isempty(x) || isa(x, 'function_handle'));
    parser.addParameter('Comment', '', @(x) validate.string(x) || validate.list(x));
end
parse(parser, this, locationRef, varargin{:});
opt = parser.Options;

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





