classdef ExcelSheet < handle
    properties
        Buffer (:, :) cell = cell.empty(0)
        FileName (1, 1) string = ""
        SheetNumber (1, 1) double = 1
        Orientation (1, 1) string {validateOrientation} = "Row"
        DataStart = NaN
        DataEnd = NaN
        DataSkip (1, 1) double {mustBePositive, mustBeFinite, mustBeInteger} = 1
        Description = NaN
        Dates (1, :) DateWrapper = DateWrapper.NaD
        DateFormat (1, 1) string = "YYYFP"
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


        function x = retrieveDates(this, locationRef)
            if isnan(this.DataStart) || isnan(this.DataEnd)
                THIS_ERROR = { 'ExcelSheet:CannotSetDates'
                               'Set DataStart and DataEnd first before setting or retrieving Dates' };
                throw( exception.Base(THIS_ERROR, 'error') );
            end

            persistent parser
            if isempty(parser)
                parser = extend.InputParser('ExcelSheet.retrieveSeries');
                parser.addRequired('ExcelSheet', @(x) isa(x, 'ExcelSheet'));
                parser.addRequired('LocationRef', @(x) ~isempty(x));
            end
            parse(parser, this, locationRef);

            if ~iscell(locationRef)
                locationRef = { locationRef };
            end
            location = cell(size(locationRef));
            if strcmpi(this.Orientation, "Row")
                [location{:}] = ExcelReference.parseRow(locationRef{:});
                datesCutout = this.Buffer([location{:}], this.DataRange);
                datesCutout = transpose(datesCutout);
            else
                [location{:}] = ExcelReference.parseColumn(locationRef{:});
                datesCutout = this.Buffer(this.DataRange, [location{:}]);
            end
            this.Dates = numeric.str2dat(datesCutout, 'DateFormat=', this.DateFormat);
        end%

            
        function x = retrieveSeries(this, locationRef, varargin)
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
                dataCutout = this.Buffer([location{:}], this.DataRange);
                dataCutout = transpose(dataCutout);
            else
                [location{:}] = ExcelReference.parseColumn(locationRef{:});
                dataCutout = this.Buffer(this.DataRange, [location{:}]);
            end
            data = nan(size(dataCutout));
            for i = 1 : size(dataCutout, 2)
                data(:, i) = [dataCutout{:, i}];
            end
            comment = retrieveDescription(this, locationRef, varargin{:});
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
    end


    properties (Dependent)
        DataRange
    end


    methods % Getters and Setters
        function value = get.DataRange(this)
            value = this.DataStart : this.DataSkip : this.DataEnd;
        end%


        function this = set.DataStart(this, value)
            this.DataStart = setAnchor(this, value);
        end%


        function this = set.DataEnd(this, value)
            this.DataEnd = setAnchor(this, value);
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
            if isnan(this.DataStart) || isnan(this.DataEnd)
                THIS_ERROR = { 'ExcelSheet:CannotSetDates'
                               'Set DataStart and DataEnd first before setting or retrieving Dates' };
                throw( exception.Base(THIS_ERROR, 'error') );
            end
            numOfDates = numel(value);
            numOfData = numel(this.DataRange);
            if numOfDates==1 || numOfDates==numOfData
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

