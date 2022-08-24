function dates = readDates(this, locationRef, varargin)

dataRange = this.DataRange;
if isempty(dataRange)
    thisError = [ 
        "ExcelSheet:CannotSetDates"
        "Set DataRange or (DataStart and DataEnd) first before setting or reading Dates" 
    ];
    throw( exception.Base(thisError, 'error') );
end

persistent pp
if isempty(pp)
    pp = extend.InputParser('ExcelSheet.readDates');
    addRequired(pp, 'ExcelSheet', @(x) isa(x, 'ExcelSheet'));
    addRequired(pp, 'LocationRef', @(x) ~isempty(x));
    addDateOptions(pp);
end
parse(pp, this, locationRef, varargin{:});
opt = pp.Options;

%--------------------------------------------------------------------------

if ~iscell(locationRef)
    locationRef = { locationRef };
end
location = cell(size(locationRef));
if startsWith(this.Orientation, "row", "ignoreCase", true)
    [location{:}] = ExcelReference.decodeRow(locationRef{:});
    datesCutout = this.Buffer([location{:}], dataRange);
    datesCutout = transpose(datesCutout);
else
    [location{:}] = ExcelReference.decodeColumn(locationRef{:});
    datesCutout = this.Buffer(dataRange, [location{:}]);
end
if isequal(opt.DateFormat, @datetime)
    dates = hereFromDatetime( );
else
    dates = hereFromString( );
end
this.Dates = dates;

return

    function dates = hereFromDatetime( )
        if isequal(opt.EnforceFrequency, false)
            thisError = { 'ExcelSheet:MustEnforceFrequencyForDatetime'
                           'Option EnforceFrequency= must be used when DateFormat=@datetime' };
            throw( exception.Base(thisError, 'error') );
        end
        inputDates = [ datesCutout{:} ];
        dates = dater.fromMatlab(opt.EnforceFrequency, inputDates);
    end%
    

    function dates = hereFromString( )
        dates = numeric.str2dat(datesCutout, opt);
    end%
end%


