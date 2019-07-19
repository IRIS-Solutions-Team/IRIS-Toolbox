classdef ExcelSheet < handle
    properties
        Buffer (:, :) cell = cell.empty(0)
        FileName (1, 1) string = ""
        SheetNumber (1, 1) double = 1
        Orientation (1, 1) string {validateOrientation} = "Row"
        DataRange = double.empty(1, 0)
        DataStart (1, 1) double = NaN
        DataEnd (1, 1) double = NaN
        DataSkip (1, 1) double {mustBePositive, mustBeFinite, mustBeInteger} = 1
        Description = NaN
        Dates (1, :) DateWrapper = DateWrapper.NaD
        DateFormat (1, 1) string = "YYYYFP"
    end


    methods
        function this = ExcelSheet(fileName, sheetNumber)
            if nargin==0
                return
            end
            if nargin>=1
                this.FileName = fileName;
            end
            if nargin>=2
                this.SheetNumber = sheetNumber;
            end
        end%


        function read(this)
            this.Buffer = readcell(this.FileName, 'Sheet', this.SheetNumber);
        end%


        function dates = retrieveDates(this, locationRef, varargin)
            dataRange = getDataRange(this);
            if isempty(dataRange)
                THIS_ERROR = { 'ExcelSheet:CannotSetDates'
                               'Set DataRange or (DataStart and DataEnd) first before setting or retrieving Dates' };
                throw( exception.Base(THIS_ERROR, 'error') );
            end

            persistent parser
            if isempty(parser)
                parser = extend.InputParser('ExcelSheet.retrieveSeries');
                addRequired(parser, 'ExcelSheet', @(x) isa(x, 'ExcelSheet'));
                addRequired(parser, 'LocationRef', @(x) ~isempty(x));
                addOptional(parser, 'DateFormat', @auto, @(x) isequal(x, @auto) || Valid.string(x));
            end
            parse(parser, this, locationRef, varargin{:});
            dateFormat = parser.Results.DateFormat;
            if isequal(dateFormat, @auto)
                dateFormat = this.DateFormat;
            end

            if ~iscell(locationRef)
                locationRef = { locationRef };
            end
            location = cell(size(locationRef));
            if strcmpi(this.Orientation, "Row")
                [location{:}] = ExcelReference.parseRow(locationRef{:});
                datesCutout = this.Buffer([location{:}], dataRange);
                datesCutout = transpose(datesCutout);
            else
                [location{:}] = ExcelReference.parseColumn(locationRef{:});
                datesCutout = this.Buffer(dataRange, [location{:}]);
            end
            this.Dates = numeric.str2dat(datesCutout, 'DateFormat=', dateFormat);
            if nargout>=1
                dates = this.Dates;
            end
        end%

            
        function x = retrieveSeries(this, locationRef, varargin)
            dataRange = getDataRange(this);
            if isempty(dataRange)
                THIS_ERROR = { 'ExcelSheet:CannotSetDates'
                               'Set DataRange or (DataStart and DataEnd) first before setting or retrieving time series' };
                throw( exception.Base(THIS_ERROR, 'error') );
            end

            persistent parser
            if isempty(parser)
                parser = extend.InputParser('ExcelSheet.retrieveSeries');
                parser.addRequired('ExcelSheet', @(x) isa(x, 'ExcelSheet'));
                parser.addRequired('LocationRef', @(x) ~isempty(x));
                parser.addParameter('Aggregator', [ ], @(x) isempty(x) || isa(x, 'function_handle'));
                parser.addParameter('Comment', '', @(x) Valid.string(x) || Valid.list(x));
            end
            parse(parser, this, locationRef, varargin{:});
            opt = parser.Options;

            if ~iscell(locationRef)
                locationRef = { locationRef };
            end
            location = cell(size(locationRef));
            if strcmpi(this.Orientation, "Row")
                [location{:}] = ExcelReference.parseRow(locationRef{:});
                dataCutout = this.Buffer([location{:}], dataRange);
                dataCutout = transpose(dataCutout);
            else
                [location{:}] = ExcelReference.parseColumn(locationRef{:});
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
            x = Series(this.Dates, data, comment);
        end%




        function description = retrieveDescription(this, locationRef, varargin)
            persistent parser
            if isempty(parser)
                parser = extend.InputParser('ExcelSheet.retrieveSeries');
                parser.addRequired('ExcelSheet', @(x) isa(x, 'ExcelSheet'));
                parser.addRequired('LocationRef', @(x) ~isempty(x));
                parser.addParameter('Aggregator', [ ], @(x) isempty(x) || isa(x, 'function_handle'));
            end
            parse(parser, this, locationRef, varargin{:});
            opt = parser.Options;

            if ~iscell(locationRef)
                locationRef = { locationRef };
            end
            location = cell(size(locationRef));
            if strcmpi(this.Orientation, "Row")
                [location{:}] = ExcelReference.parseRow(locationRef{:});
                description = cell.empty(0);
                if ~isnan(this.Description)
                    description = this.Buffer([location{:}], this.Description);
                    description = transpose(description);
                end
            else
                [location{:}] = ExcelReference.parseColumn(locationRef{:});
                description = cell.empty(0);
                if ~isnan(this.Description)
                    description = this.Buffer(this.Description, [location{:}]);
                end
            end
            if isa(opt.Aggregator, 'function_handle')
                description = sprintf('%s & ', description{:});
                description = description(1:end-3);
            end
        end%




        function inx = testColumns(this, row, testFunc)
            row = ExcelReference.parseRow(row);
            inx = cellfun(testFunc, this.Buffer(row, :));
        end%
    end


    

    properties (Dependent)
        NumOfData
    end




    methods % Getters and Setters
        function value = get.DataEnd(this)
            if isequal(this.DataEnd, Inf)
                value = size(this.Buffer, 2);
            else
                value = this.DataEnd;
            end
        end%


        function value = getDataRange(this)
            if ~isempty(this.DataRange)
                value = this.DataRange;
                return
            end
            if isequal(this.DataEnd, Inf)
                dataEnd = size(this.Buffer, 2);
            else
                dataEnd = this.DataEnd;
            end
            try
                value = this.DataStart : this.DataSkip : dataEnd;
            catch
                value = double.empty(1, 0);
            end
        end%


        function value = get.NumOfData(this)
            dataRange = getDataRange(this);
            if islogical(dataRange)
                value = nnz(dataRange);
            else
                value = numel(dataRange);
            end
        end%


        function this = set.DataStart(this, value)
            this.DataStart = setAnchor(this, value);
            if isequaln(this.DataEnd, NaN)
                this.DataEnd = Inf;
            end
        end%


        function this = set.DataEnd(this, value)
            if isequal(value, Inf)
                this.DataEnd = Inf;
            else
                this.DataEnd = setAnchor(this, value);
            end
        end%


        function this = set.Description(this, value)
            this.Description = setAnchor(this, value);
        end%


        function anchor = setAnchor(this, value)
            if strcmpi(this.Orientation, "Row")
                anchor = ExcelReference.parseColumn(value);
            else
                anchor = ExcelReference.parseRow(value);
            end
        end%


        function this = set.Dates(this, value)
            dataRange = getDataRange(this);
            if isempty(dataRange)
                THIS_ERROR = { 'ExcelSheet:CannotSetDates'
                               'Set DataRange or (DataStart and DataEnd) first before setting or retrieving Dates' };
                throw( exception.Base(THIS_ERROR, 'error') );
            end
            numOfDates = numel(value);
            if numOfDates==1 || numOfDates==this.NumOfData;
                this.Dates = value;
                return
            end
            THIS_ERROR = { 'ExcelSheet:DatesNotMatchData'
                           'Number of Dates does not match size of DataRange' };
            throw( exception.Base(THIS_ERROR, 'error') );
        end%
    end
end


%
% Local Functions
%

function flag = validateOrientation(input)
    flag = strcmpi(input, "Row") || strcmpi(input, "Column");
    if flag
        return
    end
    THIS_ERROR = { 'ExcelReference:InvalidPropertyOrientation' 
                   'Property Orientation must be "Row" or "Column"' };
    throw( exception.Base(THIS_ERROR, 'error') );
end%

