classdef ( ...
    CaseInsensitiveProperties=true ...
    , InferiorClasses={?matlab.graphics.axis.Axes, ?DateWrapper, ?Dater} ...
) Series ...
    < iris.mixin.GetterSetter ...
    & iris.mixin.UserDataContainer

    properties
        % Start  Date of first observation in time series
        Start (1, 1) = NaN

        % Comment  User comments attached to individual columns of time series
        Comment string = ""

        % Data  Numeric or logical array of time series data
        Data = double.empty(0, 1)

        % MissingValue  Representation of missing value
        MissingValue = NaN

        % Headers  Short titles for individual columns
        Headers = []
    end


    properties (Dependent)
        Self

        % StartAsNumeric  Date of first observation in time series returned as numeric value (double)
        StartAsNumeric

        % StartAsDate  Date of first observation in time series returned as IrisT date
        StartAsDate
        StartAsDateWrapper

        % BalancedStart  First date at which all columns have a non-missing observation
        BalancedStart

        % End  Date of last observation in time series
        End

        % EndAsNumeric  Date of last observation in time series returned as numeric value (double)
        EndAsNumeric

        % EndAsDate  Date of last observation in time series returned as IrisT date
        EndAsDate
        EndAsDateWrapper

        % BalancedEnd  Last date at which all columns have a non-missing observation
        BalancedEnd

        % Frequency  Date frequency of time series
        Frequency

        % FrequencyAsNumeric  Date frequency of times series returned as numeric value (double)
        FrequencyAsNumeric

        % Range  Date range from first to last observation in time series
        Range

        % RangeAsNumeric  Date range from first to last observation in time series returned as numeric value
        RangeAsNumeric

        % RangeAsDate  Date range from first to last observation in time series returned as IrisT date
        RangeAsDate
        RangeAsDateWrapper

        % MissingTest  Test for missing values
        MissingTest
    end


    properties (Constant)
        StartDateWhenEmpty = NaN
    end


    methods
        varargout = arma(varargin)
        varargout = ascii(varargin)
        varargout = bpass(varargin)
        varargout = bsxfun(varargin)
        varargout = chainlink(varargin)
        varargout = chowlin(varargin)
        varargout = clip(varargin)
        varargout = comment(varargin)
        varargout = detrend(varargin)
        varargout = df(varargin)
        varargout = expsm(varargin)
        varargout = fft(varargin)
        varargout = find(varargin)
        varargout = flipud(varargin)
        varargout = get(varargin)
        varargout = getData(varargin)
        varargout = getDataFromMultiple(varargin)
        varargout = getDataFromTo(varargin)
        varargout = getDataNoFrills(varargin)
        varargout = hpdi(varargin)
        varargout = ifelse(varargin)
        varargout = infoset2line(varargin)
        varargout = init(varargin)
        varargout = interp(varargin)
        varargout = isempty(varargin)
        varargout = isscalar(varargin)
        varargout = length(varargin)
        varargout = max(varargin)
        varargout = maxabs(varargin)
        varargout = min(varargin)
        varargout = ndims(varargin)
        varargout = pctmean(varargin)
        varargout = permute(varargin)
        varargout = plotpred(varargin)
        varargout = redate(varargin)
        varargout = removeWeekends(varargin)
        varargout = repmat(varargin)
        varargout = resetComment(varargin)
        varargout = reshape(varargin)
        varargout = resolveRange(varargin)
        varargout = retrieveColumns(varargin)
        varargout = select(varargin)
        varargout = setData(varargin)
        varargout = shift(varargin)
        varargout = sort(varargin)
        varargout = spy(varargin)
        varargout = subsasgn(varargin)
        varargout = subsref(varargin)
        varargout = trend(varargin)
        varargout = windex(varargin)
        varargout = wmean(varargin)
        varargout = x12(varargin)


        function out = double(this)
            out = double(this.Data);
        end%


        function out = single(this)
            out = single(this.Data);
        end%


        function date = startdate(this)
            date = Dater(this.Start);
        end%


        function date = enddate(this)
            date = Dater(this.End);
        end%


        function varargout = x13(varargin)
            [varargout{1:nargout}] = x12(varargin{:});
        end%


        function varargout = expsmooth(varargin)
            [varargout{1:nargout}] = expsm(varargin{:});
        end%


        function value = get.Self(this)
            value = this;
        end%


        function value = getStartAsNumeric(this)
            value = double(this.Start);
        end%


        function value = getStart(this)
            value = Dater(this.Start);
        end%


        function value = get.StartAsDateWrapper(this)
            value = getStart(this);
        end%


        function value = get.StartAsNumeric(this)
            value = getStartAsNumeric(this);
        end%


        function value = get.StartAsDate(this)
            value = getStart(this);
        end%


        function x = getComments(this)
            x = textual.stringify(this.Comment);
        end%


        function value = getBalancedStartAsNumeric(this)
            if isnan(this.Start) || isempty(this.Data)
                value = Dater(NaN);
                return
            end
            start = double(this.Start);
            inxMissing = this.MissingTest(this.Data);
            inxMissing = inxMissing(:, :);
            first = find(all(~inxMissing, 2), 1);
            if ~isempty(first)
                value = dater.plus(start, first-1);
            else
                value = NaN;
            end
        end%


        function value = getBalancedStart(this)
            value = Dater(getBalancedStartAsNumeric(this));
        end%


        function value = get.BalancedStart(this)
            value = getBalancedStart(this);
        end%:w


        function value = getEnd(this)
            value = Dater(getEndAsNumeric(this));
        end%


        function value = getEndAsNumeric(this)
            value = double(this.Start);
            if isnan(this.Start)
                return
            end
            numRows = size(this.Data, 1);
            value = dater.plus(value, numRows-1);
        end%


        function value = get.End(this)
            value = getEnd(this);
        end%


        function value = get.EndAsNumeric(this)
            value = getEndAsNumeric(this);
        end%


        function value = get.EndAsDate(this)
            value = getEnd(this);
        end%


        function value = get.EndAsDateWrapper(this)
            value = getEnd(this);
        end%


        function value = getBalancedEndAsNumeric(this)
            if isnan(this.Start) || isempty(this.Data)
                value = Dater(NaN);
                return
            end
            start = double(this.Start);
            inxMissing = this.MissingTest(this.Data);
            inxMissing = inxMissing(:, :);
            last = find(all(~inxMissing, 2), 1, 'last');
            if ~isempty(last)
                value = dater.plus(start, last-1);
            else
                value = NaN;
            end
        end%


        function value = getBalancedEnd(this)
            value = Dater(getBalancedEndAsNumeric(this));
        end%


        function value = get.BalancedEnd(this)
            value = getBalancedEnd(this);
        end%


        function value = get.Frequency(this)
            value = Frequency.fromNumeric(this.FrequencyAsNumeric); %#ok<PROP>
        end%


        function value = get.FrequencyAsNumeric(this)
            value  = dater.getFrequency(this.Start);
        end%


        function value = getFrequency(this)
            value = getFrequencyAsNumeric(this);
            value = Frequency.fromNumeric(value); %#ok<PROP>
        end%


        function value = getFrequencyAsNumeric(this)
            value = dater.getFrequency(double(this.Start));
        end%


        function numericRange = getRangeAsNumeric(this)
            numPeriods = size(this.Data, 1);
            numericRange = dater.plus(double(this.Start), 0:numPeriods-1);
            numericRange = reshape(numericRange, 1, []);
        end%


        function value = getRange(this)
            value = Dater(getRangeAsNumeric(this));
        end%


        function value = get.Range(this)
            value = getRange(this);
        end%


        function value = get.RangeAsNumeric(this)
            value = getRangeAsNumeric(this);
        end%


        function value = get.RangeAsDate(this)
            value = getRange(this);
        end%


        function range = get.RangeAsDateWrapper(this)
            value = getRange(this);
        end%


        function this = setComment(this, newValue)
            thisValue = this.Comment;
            newValue = strrep(newValue, '"', '');
            if isa(newValue, 'string')
                if numel(newValue)==1
                    newValue = char(newValue);
                else
                    newValue = cellstr(newValue);
                end
            end
            if ischar(newValue)
                thisValue(:) = {newValue};
            else
                sizeData = size(this.Data);
                sizeNewComment = size(newValue);
                expectedSizeComment = [1, sizeData(2:end)];
                if isequal(sizeNewComment, expectedSizeComment)
                    thisValue = newValue;
                elseif isequal(sizeNewComment, [1, 1])
                    thisValue = repmat(newValue, expectedSizeComment);
                else
                    throw( exception.Base('Series:InvalidSizeColumnNames', 'error') );
                end
            end
            if ~iscellstr(thisValue)
                throw( exception.Base('Series:InvalidValueColumnNames', 'error') );
            end
            this.Comment = thisValue;
        end%
    end


    methods (Hidden)
        varargout = checkConsistency(varargin)
        varargout = trim(varargin)
        varargout = rearrangePred(varargin)
        varargout = implementConstructor(varargin)
        varargout = implementGet(varargin)

        function disp(varargin)
            implementDisp(varargin{:});
        end%

        function index = end(this, k, varargin)
            if k==1
                index = this.EndAsNumeric;
            else
                index = size(this.Data, k);
            end
        end%

        function n = numel(~, varargin)
            n = 1;
        end%
    end


    methods
        function missingTest = get.MissingTest(this)
            missingValue = this.MissingValue;
            if isequaln(missingValue, NaN)
                if isreal(this.Data)
                    missingTest = @isnan;
                else
                    missingTest = @(x) isnan(real(x)) & isnan(imag(x));
                end
            elseif iscell(missingValue)
                missingTest = @(array) arrayfun(@(element) isequal(element, missingValue), array);
            elseif isa(missingValue, 'missing')
                missingTest = @ismissing;
            else
                missingTest = @(x) x==missingValue;
            end
        end%


        varargout = checkFrequency(varargin)


        function this = emptyData(this)
            if isnan(this.Start) || size(this.Data, 1)==0
                return
            end
            sizeData = size(this.Data);
            newSizeData = [0, sizeData(2:end)];
            this.Start = Series.StartDateWhenEmpty;
            this.Data = repmat(this.MissingValue, newSizeData);
        end%


        function [output, dim] = applyFunctionAlongDim(this, func, varargin)
            [output, dim] = func(this.Data, varargin{:});
            if dim>1
                output = fill(this, output, this.Start, '', [ ]);
            end
        end%


        function flag = validateFrequency(this, dates)
            if isnan(this.Start)
                flag = true(size(dates));
                return
            end
            flag = dater.getFrequency(this.Start)==dater.getFrequency(dates) ...
                 | isnan(dates);
        end%


        function flag = validateFrequencyOrInf(this, dates)
            flag = isinf(dates) | validateFrequency(this, dates);
        end%


    end


    methods
        function this = Series(varargin)

            this = this@iris.mixin.GetterSetter( );
            this = this@iris.mixin.UserDataContainer( );

            % Cast struct as Series
            if nargin==1 && isstruct(varargin{1})
                this = struct2obj(this, varargin{1});
                if ~checkConsistency(this)
                    exception.error([
                        "Series:InvalidStructPassedToConstructor"
                        "The struct passed into the Series constructor "
                        "is invalid or its fields are not consistent. "
                    ]);
                end
                return
            end

            % Empty call
            if nargin==0
                return
            end

            % Series input
            if nargin==1 && isequal(string(class(varargin{1})), "Series")
                this = varargin{1};
                return
            end

            [dates, values] = varargin{1:2};
            varargin(1:2) = [ ];

            skipInputParser = cell.empty(1, 0);
            if nargin>=3 && (ischar(varargin{end}) || (isstring(varargin{end}) && isscalar(varargin{end}))) ...
                && startsWith(varargin{end}, "--skip", "ignoreCase", true)
                skipInputParser = varargin(end);
                varargin(end) = [ ];
            end
            if ~isempty(varargin)
                comment = varargin{1};
                varargin(1) = [ ];
            else
                comment = [ ];
            end
            if ~isempty(varargin)
                userData = varargin{1};
                varargin(1) = [ ];
            else
                userData = [ ];
            end

            this = implementConstructor(this, dates, values, comment, userData, skipInputParser);
        end%
    end


    methods (Static)
        varargout = createDateAxisData(varargin)
    end




    methods (Static, Access=protected)
        varargout = trimRows(varargin)
    end


    methods % Plotting
        varargout = chartyy(varargin)

        varargout = band(varargin)
        varargout = plot(varargin)


        function varargout = area(varargin)
            this = Series.lookupObject(varargin{:});
            [varargout{1:nargout}] = this.implementPlot(@area, varargin{:});
        end%

        function varargout = bands(varargin)
            [varargout{1:nargout}] = Series.implementPlot(@bands, varargin{:});
        end%

        function varargout = bar(varargin)
            this = Series.lookupObject(varargin{:});
            [varargout{1:nargout}] = this.implementPlot(@bar, varargin{:});
        end%

        function varargout = barcon(varargin)
            exception.warning([
                "Deprecated"
                "Function Series/barcon is deprecated, and will be remove in the near future"
                "Use the standard bar(___, ""stacked"") instead."
            ]);
            [varargout{1:nargout}] = Series.implementPlot(@series.barcon, varargin{:});
        end%

        function varargout = binscatter(varargin)
            this = Series.lookupObject(varargin{:});
            [varargout{1:nargout}] = this.implementPlot(@binscatter, varargin{:});
        end%

        function varargout = bubblechart(varargin)
            this = Series.lookupObject(varargin{:});
            [varargout{1:nargout}] = this.implementPlot(@bubblechart, varargin{:});
        end%

        function varargout = errorbar(varargin)
            [varargout{1:nargout}] = Series.implementPlot(@series.errorbar, varargin{:});
        end%

        function varargout = histogram(varargin)
            this = Series.lookupObject(varargin{:});
            [varargout{1:nargout}] = this.implementPlot(@histogram, varargin{:});
        end%

        function varargout = scatter(varargin)
            this = Series.lookupObject(varargin{:});
            [varargout{1:nargout}] = this.implementPlot(@scatter, varargin{:});
        end%

        function varargout = stairs(varargin)
            this = Series.lookupObject(varargin{:});
            [varargout{1:nargout}] = this.implementPlot(@stairs, varargin{:});
        end%

        function varargout = stem(varargin)
            this = Series.lookupObject(varargin{:});
            [varargout{1:nargout}] = this.implementPlot(@stem, varargin{:});
        end%
    end


    methods (Static)
        function this = lookupObject(varargin)
            for v = varargin
                if isa(v{:}, 'Series')
                    this = v{:};
                    return
                end
            end
        end%
    end



    methods
        varargout = acf(varargin)
        varargout = adiff(varargin)
        varargout = adifflog(varargin)
        varargout = apply(varargin)
        varargout = arf(varargin)
        varargout = apct(varargin)
        varargout = aroc(varargin)
        varargout = bwf(varargin)
        varargout = bwf2(varargin)
        varargout = cat(varargin)
        varargout = convert(varargin)
        varargout = cumsumk(varargin)

        varargout = destdize(varargin)
        function varargout = destdise(varargin)
            [varargout{1:nargout}] = destdize(varargin{:});
        end%

        varargout = diff(varargin)
        varargout = difflog(varargin)
        varargout = diffChart(varargin)
        varargout = ellone(varargin)

        function varargout = isfreq(this, freq)
            [varargout{1:nargout}] = this.Frequency==freq;
        end%

        varargout = horzcat(varargin)

        function this = isMissing(this)
            this.Data = this.MissingTest(this.Data);
            this = resetMissingValue(this, this.Data);
        end%

        varargout = llf(varargin)
        varargout = llf2(varargin)
        varargout = moving(varargin)
        varargout = normalize(varargin)
        varargout = hpf(varargin)
        varargout = hpf2(varargin)

        varargout = fill(varargin)
        function varargout = replace(varargin)
            [varargout{1:nargout}] = fill(varargin{:});
        end%

        varargout = fillMissing(varargin)
        function varargout = fillmissing(varargin)
            [varargout{1:nargout}] = fillMissing(varargin{:});
        end%

        varargout = filter(varargin)
        varargout = genip(varargin)
        varargout = grow(varargin)
        tabular(varargin)
        varargout = pct(varargin)
        varargout = project(varargin)
        varargout = rebase(varargin)
        varargout = recognizeShift(varargin)
        varargout = regress(varargin)
        varargout = replaceData(varargin)
        varargout = rmse(varargin)
        varargout = roc(varargin)

        function this = round(this, varargin)
            this.Data = round(this.Data, varargin{:});
        end%

        varargout = size(varargin)

        function s = sizeData(this)
            s = size(this.Data);
        end%

        varargout = stdize(varargin)
        function varargout = stdise(varargin)
            [varargout{1:nargout}] = stdize(varargin{:});
        end%

        varargout = table(varargin)
        varargout = vertcat(varargin)
        varargout = yearly(varargin)
    end



    methods (Access=protected, Hidden)
        varargout = binop(varargin)
        varargout = implementDisp(varargin)


        function data = createDataFromFunction(this, data, numDates)
            if isequal(data, @ltrend)
                data = transpose(1:numDates);
            else
                data = feval(data, [numDates, 1]);
            end
        end%


        function checkDataClass(this, data)
            if isnumeric(data) || islogical(data) || isstring(data) || iscell(data)
                return
            end
            thisError = [ "Series:InvalidClassOfData"
                          "Series can only be assigned "
                          "numeric or logical classes of data. "];
            throw(exception.Base(thisError, 'error'));
        end%


        varargout = implementFilter(varargin)
        varargout = unop(varargin)
        varargout = unopinx(varargin)


        function this = resetMissingValue(this, values)
            if isa(values, 'single')
                this.MissingValue = single(NaN);
            elseif islogical(values)
                this.MissingValue = false;
            elseif isinteger(values)
                this.MissingValue = zeros(1, 1, class(values));
            elseif isnumeric(values) && ~isreal(values)
                this.MissingValue = complex(NaN, NaN);
            elseif isstring(values)
                this.MissingValue = string(missing( ));
            elseif iscell(values)
                this.MissingValue = {[]};
            else
                this.MissingValue = NaN;
            end
        end%
    end




    methods (Static, Access=protected, Hidden)
        varargout = plotSwitchboard(varargin)
        varargout = preparePlot(varargin)
    end



    methods (Static) % Static constructors
        varargout = fromData(varargin)
        varargout = linearTrend(varargin)
        varargout = seasonDummy(varargin)
        varargout = randomlyGrowing(varargin)
        varargout = empty(varargin)
    end


    methods (Static)
        varargout = createTable(varargin)
        varargout = implementPlot(varargin)

        function this = template(varargin)
            persistent persistentSeries
            if ~isa(persistentSeries, 'Series')
                persistentSeries = Series();
            end
            this = persistentSeries;
        end%
    end




    methods
        function x = abs(x)
            x.Data = abs(x.Data);
        end%
        function x = acos(x)
            x.Data = acos(x.Data);
            x = trim(x);
        end%
        function x = and(x, y)
            x = binop(@and, x, y);
        end%
        function x = asin(x)
            x.Data = asin(x.Data);
            x = trim(x);
        end%
        function x = atan(x)
            x.Data = atan(x.Data);
            x = trim(x);
        end%
        function x = atan2(x)
            x.Data = atan2(x.Data);
            x = trim(x);
        end%
        function x = ceil(x)
            x.Data = ceil(x.Data);
        end%
        function x = complex(x)
            x.Data = complex(x.Data);
        end%
        function x = cos(x)
            x.Data = cos(x.Data);
            x = trim(x);
        end%
        function x = eq(a, b)
            x = binop(@eq, a, b);
        end%
        function x = exp(x)
            x.Data = exp(x.Data);
            x = trim(x);
        end%
        function x = fix(x)
            x.Data = fix(x.Data);
            x = trim(x);
        end%
        function x = floor(x)
            x.Data = floor(x.Data);
        end%
        function x = ge(a, b)
            x = binop(@ge, a, b);
        end%
        function x = gt(a, b)
            x = binop(@gt, a, b);
        end%
        function x = imag(x)
            x = unop(@imag, x, 0);
            x = trim(x);
        end%
        function x = isinf(x)
            x.Data = isinf(x.Data);
        end%
        function x = isnan(x)
            x.Data = isnan(x.Data);
        end%
        function flag = isreal(x)
            flag = isreal(x.Data);
        end%
        function x = ldivide(a, b)
            x = binop(@ldivide, a, b);
        end%
        function x = le(a, b)
            x = binop(@le, a, b);
        end%
        function x = log(x)
            x.Data = log(x.Data);
            x = trim(x);
        end%
        function x = log10(x)
            x.Data = log10(x.Data);
            x = trim(x);
        end%
        function x = lt(a, b)
            x = binop(@lt, a, b);
        end%
        function x = minus(a, b)
            x = binop(@minus, a, b);
        end%
        function x = mldivide(x, y)
            if (isa(x, 'Series') && isa(y, 'Series')) ...
                    || (isnumeric(y) && length(y)==1)
                x = binop(@ldivide, x, y);
            else
                x = binop(@mldivide, x, y);
            end
        end%
        function x = mpower(x, y)
            x = binop(@power, x, y);
        end%
        function x = mrdivide(x, y)
            if (isa(x, 'Series') && isa(y, 'Series')) ...
                    || (isnumeric(x) && length(x)==1)
                x = binop(@rdivide, x, y);
            else
                x = binop(@mrdivide, x, y);
            end
        end%
        function x = mtimes(x, y)
            if isa(x, 'Series') && isa(y, 'Series')
                x = binop(@times, x, y);
            else
                x = binop(@mtimes, x, y);
            end
        end%

        function this = nanmean(this, dim, varargin)
            if nargin<2
                dim = 1;
            end
            this = unop(@mean, this, dim, dim, 'OmitNaN', varargin{:});
        end%

        function this = nanstd(this, flag, dim, varargin)
            if nargin<2
                flag = 0;
            end
            if nargin<3
                dim = 1;
            end
            this = unop(@std, this, dim, dim, 'omitNaN', varargin{:});
        end%

        function this = nansum(this, dim, varargin)
            if nargin<2
                dim = 1;
            end
            this = unop(@sum, this, dim, dim, 'omitNaN', varargin{:});
        end%

        function this = nanvar(this, flag, dim, varargin)
            if nargin<2
                flag = 0;
            end
            if nargin<3
                dim = 1;
            end
            this = unop(@var, this, dim, dim, 'omitNaN', varargin{:});
        end%

        function this = ne(this, Y)
            this = binop(@ne, this, Y);
        end%
        function x = norm(x, varargin)
            x = norm(x.Data, varargin{:}) ;
        end%
        function x = not(x)
            x.Data = not(x.Data);
        end%
        function x = or(x, y)
            x = binop(@or, x, y);
        end%
        function x = plus(x, y)
            x = binop(@plus, x, y);
        end%
        function x = power(x, y)
            x = binop(@power, x, y);
        end%
        function x = prod(x, dim)
            if nargin<2
                dim = 1;
            end
            x = unop(@prod, x, dim, dim);
        end%
        function x = rdivide(x, y)
            x = binop(@rdivide, x, y);
        end%
        function x = real(x)
            x.Data = real(x.Data);
            x = trim(x);
        end%
        function x = sin(x)
            x.Data = sin(x.Data);
            x = trim(x);
        end%
        function x = sqrt(x)
            x.Data = sqrt(x.Data);
            x = trim(x);
        end%
        function x = tan(x)
            x.Data = tan(x.Data);
            x = trim(x);
        end%
        function x = times(x, y)
            x = binop(@times, x, y);
        end%
        function x = uminus(x)
            x.Data = -x.Data;
        end%
        function x = uplus(x)
        end%


        %
        % Distribution functions (Stats Toolbox)
        %
        function x = erf(x, varargin)
            x.Data = erf(x.Data, varargin{:});
            x = trim(x);
        end%
        function x = normcdf(x, varargin)
            x.Data = normcdf(x.Data, varargin{:});
            x = trim(x);
        end%
        function x = normpdf(x, varargin)
            x.Data = normpdf(x.Data, varargin{:});
            x = trim(x);
        end%
        function x = norminv(x, varargin)
            x.Data = norminv(x.Data, varargin{:});
            x = trim(x);
        end%
        function x = logncdf(x, varargin)
            x.Data = logncdf(x.Data, varargin{:});
            x = trim(x);
        end%
        function x = lognpdf(x, varargin)
            x.Data = lognpdf(x.Data, varargin{:});
            x = trim(x);
        end%
        function x = logninv(x, varargin)
            x.Data = logninv(x.Data, varargin{:});
            x = trim(x);
        end%
        function x = gevcdf(x, varargin)
            x.Data = gevcdf(x.Data, varargin{:});
            x = trim(x);
        end%
        function x = gevpdf(x, varargin)
            x.Data = gevpdf(x.Data, varargin{:});
            x = trim(x);
        end%
        function x = gevinv(x, varargin)
            x.Data = gevinv(x.Data, varargin{:});
            x = trim(x);
        end%



        %
        % Functions whose behavior differs in different dimensions
        %
        function x = any(x, dim)
            if nargin<2
                dim = 1;
            end
            x = unop(@any, x, dim, dim);
        end%

        function x = all(x, dim)
            if nargin<2
                dim = 1;
            end
            x = unop(@all, x, dim, dim);
        end%

        function x = cumprod(x, dim, varargin)
            if nargin<2
                dim = 1;
            end
            x = unop(@cumprod, x, 0, dim, varargin{:});
        end%

        function x = cumsum(x, dim, varargin)
            if nargin<2
                dim = 1;
            end
            x = unop(@cumsum, x, 0, dim, varargin{:});
        end%

        function a = geomean(x, dim, varargin)
            if nargin<2
                dim = 1;
            end
            a = unop(@geomean, x, dim, dim, varargin{:});
        end%

        function x = mean(x, dim, varargin)
            if nargin<2
                dim = 1;
            end
            x = unop(@mean, x, dim, dim, varargin{:});
        end%

        function x = median(x, dim, varargin)
            if nargin<2
                dim = 1;
            end
            x = unop(@median, x, dim, dim, varargin{:});
        end%

        function x = mode(x, dim, varargin)
            if nargin<2
                dim = 1;
            end
            x = unop(@mode, x, dim, dim, varargin{:});
        end%


        function x = prctile(x, p, dim)
            if nargin<3
                dim = 2;
            end
            x = unop(@series.prctile, x, dim, p, dim);
        end%


        function varargout = pctile(varargin)
            [varargout{1:nargout}] = prctile(varargin{:});
        end%


        function x = std(x, flag, dim, varargin)
            if nargin<2
                flag = 0;
            end
            if nargin<3
                dim = 1;
            end
            x = unop(@std, x, dim, flag, dim, varargin{:});
        end%


        function x = sum(x, dim, varargin)
            if nargin<2
                dim = 1;
            end
            x = unop(@sum, x, dim, dim, varargin{:});
        end%


        function x = var(x, flag, dim, varargin)
            if nargin<2
                flag = 0;
            end
            if nargin<3
                dim = 1;
            end
            x = unop(@var, x, dim, flag, dim, varargin{:});
        end%
    end

end
