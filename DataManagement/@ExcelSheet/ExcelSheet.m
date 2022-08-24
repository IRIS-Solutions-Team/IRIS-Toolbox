classdef ExcelSheet ...
    < matlab.mixin.Copyable

    properties
        Buffer (:, :) cell = cell.empty(0)
        FileName (1, 1) string = ""
        SheetIdentification = 1
        SheetRange = ''
        Orientation (1, 1) string {locallyValidateOrientation} = "row"
        DataRange = double.empty(1, 0)
        DataStart = NaN
        DataEnd = NaN
        DataSkip (1, 1) double {mustBePositive, mustBeFinite, mustBeInteger} = 1
        Description = NaN
        NamesLocation = NaN
        CommentsLocation = NaN
        Dates (1, :) = Dater.empty(1, 0)
        InsertEmpty = [0, 0]
    end


    methods % Constructor
        function this = ExcelSheet(fileName, varargin)
            if nargin==0
                return
            end

            %(
            persistent pp
            if isempty(pp)
                pp = extend.InputParser('ExcelSheet/ExcelSheet');
                addRequired(pp,  'fileName', @validate.string);

                addParameter(pp, 'Sheet', 1, @(x) isempty(x) || validate.numericScalar(x) || validate.string(x));
                addParameter(pp, 'Range', '', @validate.string);
                addParameter(pp, 'InsertEmpty', [0, 0], @(x) isnumeric(x) && numel(x)==2 && all(x==round(x)) && all(x>=0));
                addParameter(pp, "ForceString", false, @validate.logicalScalar);
                addParameter(pp, 'readcellSettings', cell.empty(1, 0), @validate.nestedOptions);
            end
            %)
            opt = parse(pp, fileName, varargin{:});

            this.FileName = fileName;
            this.SheetIdentification = opt.Sheet;
            this.SheetRange = opt.Range;
            this.InsertEmpty = opt.InsertEmpty;
            read(this, opt.readcellSettings{:});
            if opt.ForceString
                this = forceString(this);
            end
        %)
        end%
    end




    methods % Public Interface
        %(
        varargout = readDates(varargin)
        varargout = retrieveSeries(varargin)
        varargout = retrieveDatabank(varargin)
        varargout = forceString(varargin)


        function output = retrieveCell(this, locationRef)
            persistent pp
            if isempty(pp)
                pp = extend.InputParser('ExcelSheet/retrieveCell');
                addRequired(pp, 'excelSheet', @(x) isa(x, 'ExcelSheet'));
                addRequired(pp, 'locationRef', @(x) ~isempty(x));
            end
            location = ExcelReference.decodeCell(locationRef);
            output = this.Buffer(location(1), location(2));
        end%


        function output = retrieveRange(this, locationRef)
            persistent pp
            if isempty(pp)
                pp = extend.InputParser('ExcelSheet/retrieveCell');
                addRequired(pp, 'excelSheet', @(x) isa(x, 'ExcelSheet'));
                addRequired(pp, 'locationRef', @(x) ~isempty(x));
            end
            [startLocation, endLocation] = ExcelReference.decodeRange(locationRef, size(this.Buffer));
            output = this.Buffer(startLocation(1):endLocation(1), startLocation(2):endLocation(2));
        end%


        function read(this, varargin)
            options = cell.empty(1, 0);
            if ~isempty(this.SheetIdentification)
                options = [options, {'Sheet', this.SheetIdentification}];
            end
            if ~isempty(this.SheetRange)
                options = [options, {'Range', this.SheetRange}];
            end
            this.Buffer = readcell(this.FileName, options{:}, varargin{:});
            insertRows = this.InsertEmpty(1);
            insertColumns = this.InsertEmpty(2);
            if insertRows>0
                this.Buffer = [ repmat({[]}, insertRows, this.NumColumns); this.Buffer ];
            end
            if insertColumns>0
                this.Buffer = [ repmat({[]}, this.NumRows, insertColumn), this.Buffer ];
            end
        end%




        function description = retrieveDescription(this, locationRef, varargin)
            persistent pp
            if isempty(pp)
                pp = extend.InputParser('ExcelSheet/retrieveSeries');
                addRequired(pp, 'ExcelSheet', @(x) isa(x, 'ExcelSheet'));
                addRequired(pp, 'LocationRef', @(x) ~isempty(x));
                addParameter(pp, 'Aggregator', [ ], @(x) isempty(x) || isa(x, 'function_handle'));
            end
            parse(pp, this, locationRef, varargin{:});
            opt = pp.Options;

            if ~iscell(locationRef)
                locationRef = { locationRef };
            end
            location = cell(size(locationRef));
            if startsWith(this.Orientation, "row", "ignoreCase", true)
                location = ExcelReference.decodeRow(locationRef{:});
                description = cell.empty(0);
                if ~isnan(this.Description)
                    description = this.Buffer(location, this.Description);
                    description = transpose(description);
                end
            else
                location = ExcelReference.decodeColumn(locationRef{:});
                description = cell.empty(0);
                if ~isnan(this.Description)
                    description = this.Buffer(this.Description, location);
                end
            end
            if isa(opt.Aggregator, 'function_handle')
                description = sprintf('%s & ', description{:});
                description = description(1:end-3);
            end
        end%




        function [pos, inx] = findRows(this, numToFind, varargin)
            %(
            persistent pp
            if isempty(pp)
                pp = extend.InputParser('@ExcelSheet/findRows');
                pp.KeepUnmatched = true;
                addRequired(pp, 'excelSheet', @(x) isa(x, 'ExcelSheet'));
                addRequired(pp, 'numToFound', @(x) isempty(x) || isnumeric(x));
            end
            parse(pp, this, numToFind);

            inx = true(this.NumRows, 1);
            for i = 1 : 2 : numel(varargin)
                column = ExcelReference.decodeColumn(varargin{i});
                testFunc = varargin{i+1};
                inx = inx & cellfun(testFunc, this.Buffer(:, column));
            end
            if isempty(numToFind) || any(nnz(inx)==numToFind)
                pos = find(inx);
                return
            end
            exception.error([
                "ExcelSheet:InvalidNumColumnsFound"
                "Number of rows passing test fails to comply with user restriction."
            ]);
            %)
        end%




        function [pos, inx] = findColumns(this, numToFind, varargin)
            %( Input parser
            persistent pp
            if isempty(pp)
                pp = extend.InputParser('@ExcelSheet/findColumns');
                pp.KeepUnmatched = true;
                addRequired(pp, 'excelSheet', @(x) isa(x, 'ExcelSheet'));
                addRequired(pp, 'numToFind', @(x) isempty(x) || isnumeric(x));
            end
            %)
            parse(pp, this, numToFind);

            inx = true(1, this.NumColumns);
            for i = 1 : 2 : numel(varargin)
                row = ExcelReference.decodeRow(varargin{i});
                testFunc = varargin{i+1};
                inx = inx & cellfun(testFunc, this.Buffer(row, :));
            end
            if isempty(numToFind) || any(nnz(inx)==numToFind)
                pos = find(inx);
                return
            end
            exception.error([
                "ExcelSheet:InvalidNumColumnsFound"
                "Number of columns passing test fails to comply with user restrictions."
            ]);
        end%
        %)
    end


    

    properties (Dependent)
        NumData
        NumRows
        NumColumns
    end




    methods % Getters and Setters
        function value = get.NumRows(this)
            value = size(this.Buffer, 1);
        end%


        function value = get.NumColumns(this)
            value = size(this.Buffer, 2);
        end%


        function value = get.DataEnd(this)
            if isequal(this.DataEnd, Inf)
                if startsWith(this.Orientation, "row", "ignoreCase", true)
                    value = this.NumColumns;
                else
                    value = this.NumRows;
                end
            else
                value = this.DataEnd;
            end
        end%


        function value = get.DataRange(this)
            if ~isempty(this.DataRange)
                value = this.DataRange;
                return
            end
            dataStart = this.DataStart;
            dataEnd = this.DataEnd;
            dataSkip = this.DataSkip;
            if isequaln(dataStart, NaN) || isequaln(dataEnd, NaN)
                value = double.empty(1, 0);
                return
            end
            try
                value = this.DataStart : this.DataSkip : dataEnd;
            catch
                value = double.empty(1, 0);
            end
        end%


        function value = get.NumData(this)
            dataRange = this.DataRange;
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


        function this = set.NamesLocation(this, value)
            this.NamesLocation = setAnchor(this, value);
        end%


        function this = set.CommentsLocation(this, value)
            this.CommentsLocation = setAnchor(this, value);
        end%


        function anchor = setAnchor(this, value)
            if startsWith(this.Orientation, "row", "ignoreCase", true)
                anchor = ExcelReference.decodeColumn(value);
            else
                anchor = ExcelReference.decodeRow(value);
            end
        end%
    end


    methods (Static) % Static constructors
        function this = fromFile(fileName, varargin)
            % Type `web ExcelSheet/fromFile.md` for help on this function
            %
            % -[IrisToolbox] for Macroeconomic Modeling
            % -Copyright (c) 2007-2022 [IrisToolbox] Solutions Team

            this = ExcelSheet(fileName, varargin{:});
        end%
    end
end

%
% Local validators
%

function flag = locallyValidateOrientation(input)
    %(
    if lower(string(input))==lower("row") || lower(string(input))==lower("column")
        return
    end
    error("Input value must be ""row"" or ""column"".");
    %)
end%

