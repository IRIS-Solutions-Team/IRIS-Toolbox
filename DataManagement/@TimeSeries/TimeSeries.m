classdef (InferiorClasses={?matlab.graphics.axis.Axes, ?Date}) ...
    TimeSeries < TimeSubscriptable & shared.UserDataWrapper

    properties
        Start = Date.NaD
        Data = double.empty(0)
        ColumnNames = string.empty(1, 0)
        MissingValue = NaN
    end


    properties (Dependent)
        End
        FrequencyDisplayName
        MissingTest
    end


    methods
        function this = TimeSeries(varargin)
            persistent INPUT_PARSER
            if isempty(INPUT_PARSER)
                INPUT_PARSER = extend.InputParser('TimeSeries/TimeSeries');
                INPUT_PARSER.addRequired('Dates', @(x) isa(x, 'Date') || isempty(x)); 
                INPUT_PARSER.addRequired('Data', @(x) isnumeric(x) || islogical(x) || iscell(x) || isa(x, 'string'));
                INPUT_PARSER.addOptional('ColumnNames', '', @(x) isa(x, 'string') || ischar(x) || iscellstr(x));
                INPUT_PARSER.addOptional('UserData', [ ], @(x) true);
            end

            if nargin==0
                return
            end

            if nargin==1
                assert( ...
                    isa(varargin{1}, 'TimeSeries'), ...
                    'TimeSeries:TimeSeries:InvalidInput', ...
                    'Invalid input argument(s).' ...
                );
                this = varargin{1};
                return
            end
            INPUT_PARSER.parse(varargin{:});

            dates = INPUT_PARSER.Results.Dates;
            data = INPUT_PARSER.Results.Data;
            numOfDates = numel(dates);
            assert( ...
                numOfDates==1 || size(data, 1)==1 || (size(data, 1)==numOfDates), ...
                'TimeSeries:TimeSeries:InvalidSizeInTimeDim', ...
                'Invalid size of input data in time dimension.' ...
            );
            if isempty(dates) 
                dates = Date.NaD;
            else
                dates = vec(dates);
            end
            this = initData(this, dates, data);

            this.ColumnNames = INPUT_PARSER.Results.ColumnNames;
            this.UserData = INPUT_PARSER.Results.UserData;
            this = trim(this);
        end


        function last = get.End(this)
            if isnad(this.Start)
                last = this.Start;
                return
            end
            last = addTo(this.Start, size(this.Data, 1)-1);
        end


        function frequency = getFrequency(this)
            frequency = getFrequency(this.Start);
        end


        function frequencyDisplayName = get.FrequencyDisplayName(this)
            frequencyDisplayName = getFrequencyDisplayName(this.Start);
        end


        function missingTest = get.MissingTest(this)
            missingValue = this.MissingValue;
            if iscell(this.Data)
                missingTest = @(data) cellfun(@(y) isequal({y}, missingValue), data);
            elseif islogical(this.Data)
                missingTest = @(data) data==missingValue;
            elseif isa(this.Data, 'string') || isa(this.Data, 'double') || isa(this.Data, 'single')
                missingTest = @ismissing;
            else
                if isnan(missingValue)
                    missingTest = @isnan;
                else
                    missingTest = @(data) data==missingValue;
                end
            end
        end


        function this = set.ColumnNames(this, value)
            sizeData = size(this.Data);
            expectedSizeOfColumnNames = [1, sizeData(2:end)];
            if isempty(value)
                columnNames = repmat("", expectedSizeOfColumnNames);
            elseif ischar(value)
                columnNames = repmat(string(value), expectedSizeOfColumnNames);
            elseif isa(value, 'string') && numel(value)==1
                columnNames = repmat(value, expectedSizeOfColumnNames);
            else
                columnNames = repmat("", expectedSizeOfColumnNames);
                columnNames(:) = value(1, :);
            end
            this.ColumnNames = columnNames;
        end
    end


    methods (Access=protected, Hidden)
        varargout = binary(varargin)
        varargout = getDataFromRange(varargin)
        varargout = initData(varargin)
        varargout = setData(varargin)
        varargout = trim(varargin)
        varargout = unaryDim(varargin)
        

        function startDate = startDateWhenEmpty(this)
            startDate = empty(this.Start.Frequency, 0, 0);
        end


        function this = resetColumnNames(this)
            % Call set.ColumnNames with empty value
            this.ColumnNames = "";
        end
    end


    methods %(Hidden)
        varargout = disp(varargin)
        varargout = getDataFromAll(varargin)
        varargout = subsasgn(varargin)
        varargout = subsref(varargin)


        function this = template(this)
            this = TimeSeries( );
        end


        function this = fill(this, newData, newStart, newColumnNames, newUserData)
            assert( ...
                isequal(class(this.Data), class(newData)), ...
                'TimeSeries:fill', ...
                'New data class must match existing data class.' ...
            );
            this.Data = newData;
            if nargin>2
                this.Start = newStart;
            end
            if nargin>3
                this.ColumnNames = newColumnNames;
            else
                this.ColumnNames = "";
            end
            if nargin>4
                this.UserData = newUserData;
            else
                this.UserData = [ ];
            end
            this = trim(this);
        end


        function n = numArgumentsFromSubscript(varargin)
            n = 1;
        end


        function n = end(this, k, varargin)
            if k==1
                if isnad(this.Start)
                    n = Date.NaD;
                else
                    n = addTo(this.Start, size(this.Data, 1)-1);
                end
            else
                n = size(this.Data, k);
            end
        end


        function this = reshape(this, varargin)
            if numel(varargin)==1
                newShape = varargin{1};
            else
                newShape = [varargin{:}];
            end
            this.Data = reshape(this.Data, [size(this.Data, 1), newShape(2:end)]);
            this.ColumnNames = reshape(this.ColumnNames, [1, newShape(2:end)]);
        end
    end




    methods
        varargout = aggregate(varargin)
        varargout = cat(varargin)
        varargout = detrend(varargin)
        varargout = diff(varargin)
        varargout = interpolate(varargin)
        varargout = horzcat(varargin)
        varargout = hpf(varargin)
        varargout = vertcat(varargin)
        varargout = pct(varargin)
        varargout = plot(varargin)
    end




    methods
        function this = elementwise(fun, this, varargin)
            if iscell(this.Data)
                this.Data = cellfun(@(x) feval(fun, x, varargin{:}), this.Data, 'UniformOutput', false);
            else
                this.Data = feval(fun, this.Data, varargin{:});
            end
        end


        function this = uplus(this, varargin)
            this = elementwise('uplus', this, varargin{:});
            this = trim(this);
        end


        function this = uminus(this, varargin)
            this = elementwise('uminus', this, varargin{:});
            this = trim(this);
        end


        function this = not(this, varargin)
            this = elementwise('not', this, varargin{:});
            this = trim(this);
        end


        function this = log(this, varargin)
            this = elementwise('log', this, varargin{:});
            this = trim(this);
        end


        function this = exp(this, varargin)
            this = elementwise('exp', this, varargin{:});
            this = trim(this);
        end


        function this = sin(this, varargin)
            this = elementwise('sin', this, varargin{:});
            this = trim(this);
        end


        function this = cos(this, varargin)
            this = elementwise('cos', this, varargin{:});
            this = trim(this);
        end


        function this = tan(this, varargin)
            this = elementwise('tan', this, varargin{:});
            this = trim(this);
        end


        function this = asin(this, varargin)
            this = elementwise('asin', this, varargin{:});
            this = trim(this);
        end


        function this = acos(this, varargin)
            this = elementwise('acos', this, varargin{:});
            this = trim(this);
        end


        function this = atan(this, varargin)
            this = elementwise('atan', this, varargin{:});
            this = trim(this);
        end


        function this = plus(a, b)
            this = binary('plus', a, b);
            this = trim(this);
        end


        function this = minus(a, b)
            this = binary('minus', a, b);
            this = trim(this);
        end


        function this = times(a, b)
            this = binary('times', a, b);
            this = trim(this);
        end


        function this = rdivide(a, b)
            this = binary('rdivide', a, b);
            this = trim(this);
        end


        function this = ldivide(a, b)
            this = binary('ldivide', a, b);
            this = trim(this);
        end


        function this = power(a, b)
            this = binary('power', a, b);
            this = trim(this);
        end


        function this = mtimes(a, b)
            this = binary('times', a, b);
            this = trim(this);
        end
        

        function this = mrdivide(a, b)
            this = binary('rdivide', a, b);
            this = trim(this);
        end
        

        function this = mldivide(a, b)
            this = binary('ldivide', a, b);
            this = trim(this);
        end
        

        function this = mpower(a, b)
            this = binary('power', a, b);
            this = trim(this);
        end
        

        function outp = mean(this, varargin)
            [outp, dim] = unaryDim('mean', 1, this, varargin{:});
            if dim>2
                outp = trim(outp);
            end
        end


        function outp = sum(this, varargin)
            [outp, dim] = unaryDim('sum', 1, this, varargin{:});
            if dim>2
                outp = trim(outp);
            end
        end


        function outp = cumsum(this, varargin)
            [outp, dim] = unaryDim('cumsum', 1, this, varargin{:});
            if dim>2
                outp = trim(outp);
            end
        end


        function outp = prod(this, varargin)
            [outp, dim] = unaryDim('prod', 1, this, varargin{:});
            if dim>2
                outp = trim(outp);
            end
        end


        function outp = cumprod(this, varargin)
            [outp, dim] = unaryDim('cumprod', 1, this, varargin{:});
            if dim>2
                outp = trim(outp);
            end
        end


        function outp = std(this, varargin)
            [outp, dim] = unaryDim('std', 2, this, varargin{:});
            if dim>2
                outp = trim(outp);
            end
        end


        function outp = prctile(this, varargin)
            [outp, dim] = unaryDim('prctile', 2, this, varargin{:});
            if dim>2
                outp = trim(outp);
            end
        end


    end


    methods
        function varargout = size(this)
            [varargout{1:nargout}] = size(this.Data);
        end


        function n = length(this)
            n = size(this.Data, 1);
        end


        function n = numel(this)
            n = numel(this.Data);
        end


        function flag = isempty(this)
            flag = isempty(this.Data);
        end


        function flag = isnad(this)
            flag = isnad(this.Start);
        end


        function flag = isnumeric(this)
            flag = isnumeric(this.Data);
        end
    end


    methods (Static)
        function miss = getDefaultMissingValue(data)
            if iscell(data)
                miss = { double.empty(0) };
            elseif islogical(data)
                miss = false;
            elseif isa(data, 'string')
                miss = string(missing);
            else
                miss = ones(1, 1, 'like', data)*NaN;
            end
        end


        varargout = fromFred(varargin)
        varargout = shiftedDataFun(varargin)
        varargout = shiftDataKeepRange(varargin)
    end


    methods
        function this = setDataColumn(this, i, x)
            this.Data(:, i) = x;
        end
    end
end

