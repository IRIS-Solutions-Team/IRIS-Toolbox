function dates = readDates(this, locationRef, varargin)
% readDates  Read and store dates from excel sheet
%{
% ## Syntax ##
%
%     dates = readDates(excelSheet, locationRef, ...)
%
%
% ## Input Arguments ##
%
% __`excelSheet`__ [ ExcelSheet ] -
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
% -Copyright (c) 2007-2019 IRIS Solutions Team


dataRange = this.DataRange;
if isempty(dataRange)
    THIS_ERROR = { 'ExcelSheet:CannotSetDates'
                   'Set DataRange or (DataStart and DataEnd) first before setting or reading Dates' };
    throw( exception.Base(THIS_ERROR, 'error') );
end

persistent parser
if isempty(parser)
    parser = extend.InputParser('ExcelSheet.readDates');
    addRequired(parser, 'ExcelSheet', @(x) isa(x, 'ExcelSheet'));
    addRequired(parser, 'LocationRef', @(x) ~isempty(x));
    addDateOptions(parser);
end
parse(parser, this, locationRef, varargin{:});
opt = parser.Options;

%--------------------------------------------------------------------------

if ~iscell(locationRef)
    locationRef = { locationRef };
end
location = cell(size(locationRef));
if strcmpi(this.Orientation, "Row")
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
            THIS_ERROR = { 'ExcelSheet:MustEnforceFrequencyForDatetime'
                           'Option EnforceFrequency= must be used when DateFormat=@datetime' };
            throw( exception.Base(THIS_ERROR, 'error') );
        end
        inputDates = [ datesCutout{:} ];
        dates = DateWrapper.fromDatetimeAsNumeric(opt.EnforceFrequency, inputDates);
    end%
    

    function dates = hereFromString( )
        dates = numeric.str2dat(datesCutout, opt);
    end%
end%


