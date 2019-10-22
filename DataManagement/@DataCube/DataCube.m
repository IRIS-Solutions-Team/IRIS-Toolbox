classdef DataCube < matlab.mixin.Copyable
    properties
        FileName             = ''

        Names                = cell.empty(1, 0)
        Types                = int8.empty(1, 0)
        IndexOfTimeless      = logical.empty(1, 0)

        StartOfBaseRange     = DateWrapper.NaD( )
        EndOfBaseRange       = DateWrapper.NaD( )
        MinShift             = NaN
        MaxShift             = NaN

        NumOfRuns            = NaN

        DataType             = @double

        Allocated            = false
        InMemoryVariables    = double.empty(0)
        InMemoryTimeless     = double.empty(0)
        DeleteExistingFile     = true
    end


    properties (Dependent)
        BaseRange
        StartOfExtendedRange
        EndOfExtendedRange
        PosOfStartOfBaseRange
        InMemory
        NumOfNames
        NumOfBasePeriods
        NumOfExtendedPeriods
        FillValue
        NumOfVariables
        NumOfTimeless
        FirstBasePeriod
        LastBasePeriod
    end


    properties (Constant)
        VARIABLES_DATASET_NAME = '/Variables'
        TIMELESS_DATASET_NAME = '/Timeless'
    end


    methods
        function allocate(this)
            if this.InMemory
                this.InMemoryVariables = nan( sizeOfVariablesData(this), char(this.DataType) );
                this.InMemoryTimeless = nan( sizeOfTimelessData(this), char(this.DataType) );
            else
                createFile(this);
            end
            this.Allocated = true;
        end%


        function outputDatabank = reduce(this, func, varargin)
            persistent parser
            if isempty(parser)
                parser = extend.InputParser('DataCube.reduceToSeries');
                parser.addRequired('DataCube', @(x) isa(x, 'DataCube'));
                parser.addRequired('Function', @(x) isa(x, 'function_handle'));
                parser.addParameter('Select', @all, @(x) isequal(x, @all) || ischar(x) || iscellstr(x) || isa(x, 'string'));
            end
            parser.parse(this, func, varargin{:});
            selectedNames = parser.Results.Select;
            if isequal(selectedNames, @all)
                selectedNames = this.Names;
            else
                selectedNames = cellstr(selectedNames);
                selectedNames = intersect(selectedNames, this.Names, 'stable');
            end
            startDate = this.StartOfExtendedRange;
            template = Series( );
            for i = 1 : numel(selectedNames)
                name = selectedNames{i};
                [data, variablesNameRef] = readName(this, name);
                numOfRowsOriginal = size(data, 1);
                reducedData = func(data);
                if numOfRowsOriginal~=size(reducedData, 1)
                    throw( exception.Base('DataCube:ReducesToInvalidNumOfRows', 'error') );
                end
                if ~isempty(variablesNameRef)
                    outputDatabank.(name) = fill(template, reducedData, startDate);
                else
                    outputDatabank.(name) = reducedData;
                end
            end
        end%


        function varargout = sizeOfVariablesData(this, k)
            sizeOfThis = nan(1, 3);
            sizeOfThis(1) = this.NumOfExtendedPeriods;
            sizeOfThis(2) = this.NumOfVariables;
            sizeOfThis(3) = this.NumOfRuns;
            if nargin>1
                if k<=3
                    varargout{1} = sizeOfThis(k);
                else
                    varargout{1} = 1;
                end
                return
            end
            if nargout<=1
                varargout{1} = sizeOfThis;
            else
                if nargout>3
                    sizeOfThis(end+1:nargout) = 1;
                end
                varargout = num2cell(sizeOfThis);
            end
        end%


        function varargout = sizeOfTimelessData(this, k)
            sizeOfThis = nan(1, 3);
            sizeOfThis(1) = 1;
            sizeOfThis(2) = this.NumOfTimeless;
            sizeOfThis(3) = this.NumOfRuns;
            if nargin>1
                if k<=3
                    varargout{1} = sizeOfThis(k);
                else
                    varargout{1} = 1;
                end
                return
            end
            if nargout<=1
                varargout{1} = sizeOfThis;
            else
                if nargout>3
                    sizeOfThis(end+1:nargout) = 1;
                end
                varargout = num2cell(sizeOfThis);
            end
        end%


        function this = writeRun(this, data, run);
            persistent parser
            if isempty(parser)
                parser = extend.InputParser('DataCube.readName');
                parser.addRequired('DataCube', @(x) isa(x, 'DataCube'));
                parser.addRequired('Data', @(x) isnumeric(x) && ismatrix(x));
                parser.addOptional('Run', ':', @(x) isequal(x, ':') || (isnumeric(x) && all(x==round(x))));
            end
            parser.parse(this, data, run);

            data = permute(data, [2, 1, 3]);
            variablesData = data(:, ~this.IndexOfTimeless);
            timelessData = data(this.PosOfStartOfBaseRange, this.IndexOfTimeless);
            runRef = resolveRunReference(this, run);
            data = this.DataType(data);
            for i = runRef
                if this.InMemory
                    this.InMemoryVariables(:, :, i) = variablesData;
                    this.InMemoryTimeless(:, :, i) = timelessData;
                else
                    start = [1, 1, i];
                    count = [this.NumOfExtendedPeriods, this.NumOfVariables, 1];
                    h5write(this.FileName, this.VARIABLES_DATASET_NAME, variablesData, start, count);
                    count = [1, this.NumOfTimeless, 1];
                    h5write(this.FileName, this.TIMELESS_DATASET_NAME, timelessData, start, count);
                end
            end
        end%


        function runData = readRun(this, run)
            persistent parser
            if isempty(parser)
                parser = extend.InputParser('DataCube.readName');
                parser.addRequired('DataCube', @(x) isa(x, 'DataCube'));
                parser.addOptional('Run', @(x) isnumeric(x) && isscalar(x) && x==round(x));
            end
            parser.parse(this, run);

            if this.InMemory
                variablesData = this.InMemoryVariables(:, :, run);
                timelessData = this.InMemoryTimeless(1, :, run);
            else
                start = [1, 1, run];
                count = [this.NumOfExtendedPeriods, this.NumOfVariables, 1];
                variablesData = h5read(this.FileName, this.VARIABLES_DATASET_NAME, start, count);
                count = [1, this.NumOfTimeless, 1];
                timelessData = h5read(this.FileName, this.TIMELESS_DATASET_NAME, start, count);
            end
            timelessData = repmat(timelessData, [this.NumOfExtendedPeriods, 1, 1]);
            runData = zeros(this.NumOfExtendedPeriods, this.NumOfNames, 1, char(this.DataType));
            runData(:, ~this.IndexOfTimeless) = variablesData;
            runData(:, this.IndexOfTimeless) = timelessData;
            runData = permute(runData, [2, 1]);
        end%


        function [data, variablesNameRef, timelessNameRef] = readName(this, name, varargin)
            persistent parser
            if isempty(parser)
                parser = extend.InputParser('DataCube.readName');
                parser.addRequired('DataCube', @(x) isa(x, 'DataCube'));
                parser.addRequired('Name', @(x) ischar(x) || (isa(x, 'string') && isscalar(x)) || (isnumeric(x) && isscalar(x) && x>=1));
                parser.addOptional('Range', ':', @(x) isequal(x, ':') || isequal(x, 1) || DateWrapper.validateProperRangeInput(x));
                parser.addOptional('Run', ':', @(x) isequal(x, ':') || (isnumeric(x) && all(x==round(x))));
            end
            parser.parse(this, name, varargin{:});

            [variablesNameRef, timelessNameRef, rangeRef, runRef] = ...
                resolveReferencesInReadWriteName(this, name, parser.Results.Range, parser.Results.Run);
            if isempty(variablesNameRef) && isempty(timelessNameRef)
                throw( exception.Base('DataCube:NameNotFound', 'error'), ...
                       name );
            end
            if this.InMemory
                if ~isempty(variablesNameRef)
                    data = this.InMemoryVariables(rangeRef, variablesNameRef, runRef);
                else
                    data = this.InMemoryTimeless(1, timelessNameRef, runRef);
                end
            else
                if ~isempty(variablesNameRef)
                    start = [rangeRef(1), variablesNameRef, runRef(1)];
                    count = [rangeRef(end)-rangeRef(1)+1, 1, runRef(end)-runRef(1)+1];
                    data = h5read(this.FileName, this.VARIABLES_DATASET_NAME, start, count);
                else
                    start = [1, timelessNameRef, runRef(1)];
                    count = [1, 1, runRef(end)-runRef(1)+1];
                    data = h5read(this.FileName, this.TIMELESS_DATASET_NAME, start, count);
                end
            end
            data = permute(data, [1, 3, 2]);
        end%


        function outputSeries = readNameAsSeries(this, name)
            persistent parser
            if isempty(parser)
                parser = extend.InputParser('DataCube.readNameAsSeries');
                parser.addRequired('DataCube', @(x) isa(x, 'DataCube'));
                parser.addRequired('Name', @(x) ischar(x) || (isa(x, 'string') && isscalar(x)));
            end
            parser.parse(this, name);
            nameRef = resolveNameReference(this, name);
            [variablesNameRef, timelessNameRef] = splitNameRef(this, nameRef);
            if isempty(variablesNameRef)
                throw( exception.Base('DataCube:CannotReadTimelessAsSeries', 'error'), ...
                       name );
            end
            outputSeries = Series( );
            outputSeries.Start = this.StartOfExtendedRange;
            outputSeries.Data = readName(this, name);
        end%


        function this = writeName(this, data, name, varargin)
            persistent parser
            if isempty(parser)
                parser = extend.InputParser('DataCube.writeName');
                parser.addRequired('DataCube', @(x) isa(x, 'DataCube'));
                parser.addRequired('Data', @(x) isnumeric(x) && ismatrix(x));
                parser.addRequired('Name', @(x) ischar(x) || (isa(x, 'string') && isscalar(x)));
                parser.addOptional('Range', ':', @(x) isequal(x, ':') || DateWrapper.validateProperRangeInput(x));
                parser.addOptional('Run', ':', @(x) isequal(x, ':') || (isnumeric(x) && all(x==round(x))));
            end
            parser.parse(this, data, name, varargin{:});

            [variablesNameRef, timelessNameRef, rangeRef, runRef] = ...
                resolveReferencesInReadWriteName(this, name, parser.Results.Range, parser.Results.Run);
            if isempty(variablesNameRef) && isempty(timelessNameRef)
                throw( exception.Base('DataCube:NameNotFound', 'error'), ...
                       name );
            end
            data = permute(data, [1, 3, 2]);
            if this.InMemory
                if ~isempty(variablesNameRef)
                    this.InMemoryVariables(rangeRef, variablesNameRef, runRef) = data;
                else
                    this.InMemoryTimeless(1, timelessNameRef, runRef) = data;
                end
            else
                if ~isempty(variablesNameRef)
                    start = [rangeRef(1), variablesNameRef, runRef(1)];
                    count = [rangeRef(end)-rangeRef(1)+1, 1, runRef(end)-runRef(1)+1];
                    data = this.DataType(data);
                    if size(data, 1)==1 && count(1)>1
                        data = repmat(data, [count(1), 1, 1]);
                    end
                    if size(data, 3)==1 && count(3)>1
                        data = repmat(data, [1, 1, count(3)]);
                    end
                    h5write(this.FileName, this.VARIABLES_DATASET_NAME, data, start, count);
                else
                    start = [1, timelessNameRef, runRef(1)];
                    count = [1, 1, runRef(end)-runRef(1)+1];
                    data = this.DataType(data);
                    if size(data, 3)==1 && count(3)>1
                        data = repmat(data, [1, 1, count(3)]);
                    end
                    h5write(this.FileName, this.TIMELESS_DATASET_NAME, data, start, count);
                end
            end
        end%


        function value = get.StartOfExtendedRange(this)
            value = addTo(this.StartOfBaseRange, this.MinShift);
        end%


        function value = get.EndOfExtendedRange(this)
            value = addTo(this.EndOfBaseRange, this.MaxShift);
        end%


        function value = get.BaseRange(this)
            value = this.StartOfBaseRange : this.EndOfBaseRange;
        end%


        function value = get.PosOfStartOfBaseRange(this)
            value = round(-this.MinShift + 1);
        end%


        function value = get.NumOfNames(this)
            value = numel(this.Names);
        end%


        function value = get.NumOfBasePeriods(this)
            value = rnglen(this.StartOfBaseRange, this.EndOfBaseRange);
        end%


        function value = get.NumOfExtendedPeriods(this)
            value = rnglen(this.StartOfExtendedRange, this.EndOfExtendedRange);
        end%


        function value = get.InMemory(this)
            value = isempty(this.FileName);
        end%


        function value = get.FillValue(this)
            value = this.DataType(NaN);
        end%


        function value = get.NumOfVariables(this)
            value = this.NumOfNames - this.NumOfTimeless;
        end%


        function value = get.NumOfTimeless(this)
            value = nnz(this.IndexOfTimeless);
        end%


        function value = get.FirstBasePeriod(this)
            value = 1 - this.MinShift;
        end%


        function value = get.LastBasePeriod(this)
            value = this.NumOfBasePeriods - this.MinShift;
        end%


        function this = set.FileName(this, value)
            persistent parser
            if isempty(parser)
                parser = extend.InputParser('DataCube.FileName');
                parser.addRequired('FileName', @(x) isempty(x) || ischar(x) || (isa(x, 'string') && isscalar(x)));
            end
            parser.parse(value);

            values = char(value);
            value = strtrim(value);
            if isempty(value)
                this.FileName = '';
                return
            end
            [filePath, fileTitle, fileExt] = fileparts(value);
            if isempty(fileExt)
                value = [value, '.h5'];
            end
            this.FileName = value;
        end%


        function this = set.StartOfBaseRange(this, value)
            persistent parser
            if isempty(parser)
                parser = extend.InputParser('DataCube.StartOfBaseRange');
                parser.addRequired('BaseRange', @DateWrapper.validateDateInput);
            end
            parser.parse(value);
            this.StartOfBaseRange = value;
        end%


        function this = set.EndOfBaseRange(this, value)
            persistent parser
            if isempty(parser)
                parser = extend.InputParser('DataCube.EndOfBaseRange');
                parser.addRequired('BaseRange', @DateWrapper.validateDateInput);
            end
            parser.parse(value);
            this.EndOfBaseRange = value;
        end%


        function this = set.NumOfRuns(this, value)
            persistent parser
            if isempty(parser)
                parser = extend.InputParser('DataCube.NumOfRuns');
                parser.addRequired('NumOfRuns', @(x) isnumeric(x) && isscalar(x) && x==round(x) && x>=1);
            end
            parser.parse(value);
            this.NumOfRuns = value;
        end%


        function this = set.DataType(this, value)
            persistent parser
            if isempty(parser)
                parser = extend.InputParser('DataCube.DataType');
                parser.addRequired('DataType', @(x) isa(x, 'function_handle'));
            end
            parser.parse(value);
            this.DataType = value;
        end%


        function this = set.IndexOfTimeless(this, value)
            persistent parser
            if isempty(parser)
                parser = extend.InputParser('DataCube.IndexOfTimeless');
                parser.addRequired('IndexOfTimeless', @islogical);
            end
            parser.parse(value);
            this.IndexOfTimeless = value;
        end%


        function this = set.DeleteExistingFile(this, value)
            persistent parser
            if isempty(parser)
                parser = extend.InputParser('DataCube.DeleteExistingFile');
                parser.addRequired('DeleteExistingFile', @(x) isequal(x, true) || isequal(x, false));
            end
            parser.parse(value);
            this.DeleteExistingFile = value;
        end%


        function list = properties(this)
            list = this.Names;
        end%
    end


    methods (Access=protected)
        function createFile(this)
            if exist(this.FileName, 'file')==2
                if this.DeleteExistingFile
                    delete(this.FileName);
                else
                    throw( exception.Base('DataCube:FileExists', 'error'), ...
                           this.FileName );
                end
            end
            h5create( this.FileName, this.VARIABLES_DATASET_NAME, sizeOfVariablesData(this), ...
                      'FillValue', this.FillValue, ...
                      'DataType', char(this.DataType) );
            h5create( this.FileName, this.TIMELESS_DATASET_NAME, sizeOfTimelessData(this), ...
                      'FillValue', this.FillValue, ...
                      'DataType', char(this.DataType) );
        end%


        function [ variablesNameRef, ...
                   timelessNameRef, ...
                   rangeRef, ...
                   runRef ] = resolveReferencesInReadWriteName(this, name, varargin)
            nameRef = resolveNameReference(this, name);
            [variablesNameRef, timelessNameRef] = splitNameRef(this, nameRef);
            if isempty(varargin)
                if ~isempty(variablesNameRef)
                    rangeRef = 1 : this.NumOfExtendedPeriods;
                else
                    rangeRef = 1;
                end
            else
                if ~isempty(variablesNameRef)
                    rangeRef = resolveRangeReference(this, varargin{1});
                else
                    rangeRef = 1;
                end
                varargin(1) = [ ];
            end
            if isempty(varargin) 
                runRef = 1 : this.NumOfRuns;
            else
                runRef = resolveRunReference(this, varargin{1});
                varargin(1) = [ ];
            end
        end%


        function ref = resolveNameReference(this, name)
            if isnumeric(name) && isscalar(name)
                ref = name;
                if ref<1 || ref>this.NumOfNames
                    throw( exception.Base('DataCube:OutOfBoundsReference', 'error') );
                end
            elseif ischar(name) || isa(name, 'string')
                ref = find(strcmp(this.Names, name));
                if isempty(ref)
                    throw( exception.Base('DataCube:NameNotFound', 'error'), ...
                           name );
               end
            else
                throw( exception.Base('DataCube:InvalidReference', 'error') );
            end
        end%


        function ref = resolveRangeReference(this, range)
            if isequal(range, ':')
                ref = 1 : this.NumOfExtendedPeriods;
                return
            end
            startDate = getFirst(range);
            endDate = getLast(range);
            startRef = rnglen(this.StartOfExtendedRange, startDate);
            endRef = rnglen(this.StartOfExtendedRange, endDate);
            if startRef<1 || startRef>this.NumOfExtendedPeriods || endRef<1 || endRef>this.NumOfExtendedPeriods
                throw( exception.Base('DataCube:OutOfBoundsReference', 'error') );
            end
            ref = startRef : endRef;
        end%


        function ref = resolveRunReference(this, run)
            if isequal(run, ':')
                ref = 1 : this.NumOfRuns;
                return
            end
            ref = run;
            if any(ref<1 | ref>this.NumOfRuns)
                throw( exception.Base('DataCube:OutOfBoundsReference', 'error') );
            end
            if any(diff(ref)~=1)
                throw( exception.Base('DataCube:InvalidReference', 'error') );
            end
        end%


        function [variablesNameRef, timelessNameRef] = splitNameRef(this, nameRef)
            posOfVariables = find(~this.IndexOfTimeless);
            posOfTimelesss = find(this.IndexOfTimeless);
            variablesNameRef = find(posOfVariables==nameRef);
            timelessNameRef = find(posOfTimelesss==nameRef);
        end%
    end


    methods (Static)
        function this = forModel(varargin)
            this = DataCube( );

            if nargin==0
                return
            elseif nargin==1 && isa(varargin{1}, 'DataCube4Model')
                this = varargin{1};
                return
            end

            TYPE = @int8;
            persistent parser
            if isempty(parser)
                parser = extend.InputParser('DataCube.forModel');
                parser.addRequired('Model', @(x) isa(x, 'model'));
                parser.addRequired('StartDate', @DateWrapper.validateDateInput);
                parser.addRequired('EndDate', @DateWrapper.validateDateInput);
                parser.addRequired('NumOfRuns', @(x) isnumeric(x) && isscalar(x) && x==round(x) && x>=1);
                parser.addParameter('DataType', @double, @(x) isa(x, 'function_handle'));
                parser.addParameter('FileName', '', @(x) isempty(x) || ischar(x) || (isa(x, 'string') && isscalar(x)));
                parser.addParameter('DeleteExistingFile', false, @(x) isequal(x, true) || isequal(x, false));
            end
            parser.parse(varargin{:});

            quantity = getp(parser.Results.Model, 'Quantity');
            this.Names = quantity.Name;
            this.Types = quantity.Type;
            this.IndexOfTimeless = quantity.Type==TYPE(4);
            [this.MinShift, this.MaxShift] = getActualMinMaxShifts(parser.Results.Model);

            this.NumOfRuns = parser.Results.NumOfRuns;
            this.StartOfBaseRange = parser.Results.StartDate;
            this.EndOfBaseRange = parser.Results.EndDate;
            this.FileName = parser.Results.FileName;
            this.DataType = parser.Results.DataType;
            this.DeleteExistingFile = parser.Results.DeleteExistingFile;
            allocate(this);
        end%
    end
end
