classdef ExcelSheet < handle
    properties
        Buffer (:, :) cell = cell.empty(0)
        FileName (1, 1) string = ""
        SheetIdentification = 1
        SheetRange = ''
        Orientation (1, 1) string {validateOrientation} = "Row"
        DataRange = double.empty(1, 0)
        DataStart = NaN
        DataEnd = NaN
        DataSkip (1, 1) double {mustBePositive, mustBeFinite, mustBeInteger} = 1
        Description = NaN
        Dates (1, :) DateWrapper = DateWrapper.NaD
        InsertEmpty = [0, 0]
    end


    methods
        function this = ExcelSheet(fileName, varargin)
            if nargin==0
                return
            end

            persistent parser
            if isempty(parser)
                parser = extend.InputParser('ExcelSheet.ExcelSheet');
                addRequired(parser,  'fileName', @Valid.string);
                addParameter(parser, 'Sheet', 1, @(x) Valid.numericScalar(x) || Valid.string(x));
                addParameter(parser, 'Range', '', @Valid.string);
                addParameter(parser, 'InsertEmpty', [0, 0], @(x) isnumeric(x) && numel(x)==2 && all(x==round(x)) && all(x>=0));
            end
            parse(parser, fileName, varargin{:});
            opt = parser.Options;

            this.FileName = fileName;
            this.SheetIdentification = opt.Sheet;
            this.SheetRange = opt.Range;
            this.InsertEmpty = opt.InsertEmpty;
            read(this);
        end%


        function read(this)
            options = {'Sheet', this.SheetIdentification};
            if ~isempty(this.SheetRange)
                options = [ options, {'Range', this.SheetRange} ];
            end
            this.Buffer = readcell(this.FileName, options{:});
            insertRows = this.InsertEmpty(1);
            insertColumns = this.InsertEmpty(2);
            if insertRows>0
                this.Buffer = [ repmat({[]}, insertRows, this.NumOfColumns); this.Buffer ];
            end
            if insertColumns>0
                this.Buffer = [ repmat({[]}, this.NumOfRows, insertColumn), this.Buffer ];
            end
        end%


        function dates = readDates(this, locationRef, varargin)
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
                addDateOptions(parser);
            end
            parse(parser, this, locationRef, varargin{:});
            opt = parser.Options;

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
            this.Dates = numeric.str2dat(datesCutout, opt);
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
                parser.addRequired('excelSheet', @(x) isa(x, 'ExcelSheet'));
                parser.addRequired('locationRef', @(x) ~isempty(x));
                % Options
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
            if strcmpi(this.Orientation, 'Row')
                [location{:}] = ExcelReference.decodeRow(locationRef{:});
                description = cell.empty(0);
                if ~isnan(this.Description)
                    description = this.Buffer([location{:}], this.Description);
                    description = transpose(description);
                end
            else
                [location{:}] = ExcelReference.decodeColumn(locationRef{:});
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




        function pos = findRows(this, numToFind, varargin)
            persistent parser
            if isempty(parser)
                parser = extend.InputParser('ExcelSheet.findColumns');
                parser.KeepUnmatched = true;
                addRequired(parser, 'excelSheet', @(x) isa(x, 'ExcelSheet'));
                addRequired(parser, 'numToFound', @(x) isempty(x) || isnumeric(x));
            end
            parse(parser, this, numToFind);

            inx = true(this.NumOfRows, 1);
            for i = 1 : 2 : numel(varargin)
                column = ExcelReference.decodeColumn(varargin{i});
                testFunc = varargin{i+1};
                inx = inx & cellfun(testFunc, this.Buffer(:, column));
            end
            if isempty(numToFind) || any(nnz(inx)==numToFind)
                pos = find(inx);
                return
            end
            THIS_ERROR = { 'ExcelSheet:InvalidNumOfColumnsFound'
                           'Number of rows passing test fails to comply with user restriction' };
            throw( exception.Base(THIS_ERROR, 'error') );
        end%




        function pos = findColumns(this, numToFind, varargin)
            persistent parser
            if isempty(parser)
                parser = extend.InputParser('ExcelSheet.findColumns');
                parser.KeepUnmatched = true;
                addRequired(parser, 'excelSheet', @(x) isa(x, 'ExcelSheet'));
                addRequired(parser, 'numToFind', @(x) isempty(x) || isnumeric(x));
            end
            parse(parser, this, numToFind);

            inx = true(1, this.NumOfColumns);
            for i = 1 : 2 : numel(varargin)
                row = ExcelReference.decodeRow(varargin{i});
                testFunc = varargin{i+1};
                inx = inx & cellfun(testFunc, this.Buffer(row, :));
            end
            if isempty(numToFind) || any(nnz(inx)==numToFind)
                pos = find(inx);
                return
            end
            THIS_ERROR = { 'ExcelSheet:InvalidNumOfColumnsFound'
                           'Number of columns passing test fails to comply with user restriction' };
            throw( exception.Base(THIS_ERROR, 'error') );
        end%
    end


    

    properties (Dependent)
        NumOfData
        NumOfRows
        NumOfColumns
    end




    methods % Getters and Setters
        function value = get.NumOfRows(this)
            value = size(this.Buffer, 1);
        end%


        function value = get.NumOfColumns(this)
            value = size(this.Buffer, 2);
        end%


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
                anchor = ExcelReference.decodeColumn(value);
            else
                anchor = ExcelReference.decodeRow(value);
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
    flag = strcmpi(input, 'Row') || strcmpi(input, 'Column');
    if flag
        return
    end
    THIS_ERROR = { 'ExcelReference:InvalidPropertyOrientation' 
                   'Property Orientation must be "Row" or "Column"' };
    throw( exception.Base(THIS_ERROR, 'error') );
end%

