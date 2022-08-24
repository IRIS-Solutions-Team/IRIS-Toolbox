function outputSeries = retrieveSeries(this, locationRef, varargin)

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

if startsWith(this.Orientation, "row", "ignoreCase", true)
    location = ExcelReference.decodeRow(locationRef{:});
    dataCutout = this.Buffer(location, dataRange);
    dataCutout = transpose(dataCutout);
else
    location = ExcelReference.decodeColumn(locationRef{:});
    dataCutout = this.Buffer(dataRange, location);
end


for i = 1 : numel(dataCutout)
   if isstring(dataCutout{i}) || ischar(dataCutout{i})
       dataCutout{i} = double(string(dataCutout{i}));
   end
   if ~isnumeric(dataCutout{i})
       dataCutout{i} = NaN;
   end
end


data = nan(size(dataCutout));
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

