% Time Series (tseries Objects)
%
% This section describes the `tseries` class of objects.
%
%
% Description
% ------------
%
% Time series (tseries) are numeric arrays with their first dimension
% (rows) dated using the DateWrapper class. The DateWrapper class
% implements dates of fixed calendar frequency: early, half-yearly,
% quarterly, monthly, weekly, and daily, plus an undated integer frequency.
% The size of time series date in 2nd and higher dimensions (columns,
% pages, etc.) is unrestricted. Time series can be manipulating using most
% of the common math and statistics operators and functions.
%
%
% tseries methods:
%
%
% Categorical List 
% -----------------
%
% __Constructors__
%
%   tseries - Create new time series (tseries) object
%
% The following are static constructors and need to be called with
% `tseries.` preceding their names.
%
%   linearTrend - Create time series with linear trend
%   empty - Create empty time series or empty an existing time series
%
%
% __Properties Directly Accessible__
%
%   Data - Numeric array of time series data
%   Start - Date of first observation available 
%   End - 
%   Range - 
%   Frequency - 
%   MissingValue - Representation of missing value
%   MissingTest - Test for missing values
%
%
% __Getting Information about Time Series__
%
%   get - Query tseries object property
%   isequal - Compare two tseries objects
%   length - Length of time series data in time dimension
%   ndims - Number of dimensions in tseries object data
%   size - Size of tseries object data
%   specrange - Time series specific range
%   yearly - Display tseries object one calendar year per row
%
%
% __Referencing Time Series__
%
%   subsasgn - Subscripted assignment for tseries objects
%   subsref - Subscripted reference function for tseries objects
%
%
% __Filters__
%
%   arf - Run autoregressive function on time series
%   arma - Apply ARMA model to input series
%   bpass - Band-pass filter
%   detrend - Remove linear time trend from time series data
%   expsm - Exponential smoothing
%   hpf - Hodrick-Prescott filter with tunes (aka LRX filter)
%   hpf2 - Swap output arguments of the Hodrick-Prescott filter with tunes
%   fft - Discrete Fourier transform of tseries object
%   llf - Local level filter (random walk plus white noise) with tunes
%   llf2 - Swap output arguments of the local linear trend filter with tunes
%   moving - Apply function to moving window of time series observations
%   trend - Estimate time trend in time series data
%   x12 - Access to X13-ARIMA-SEATS seasonal adjustment program
%
%
% __Estimation and Sample Characteristics__
%
% Standard sample characteristics are listed at the end in the Maths and
% Statistics Functions and Operators section.
%
%   acf - Sample autocovariance and autocorrelation functions
%   hpdi - Highest probability density interval
%   chowlin - Chow-Lin distribution of low-frequency observations over higher-frequency periods
%   regress - Ordinary or weighted least-square regression
%
%
% __Visualising Time Series__
%
%   area - Area graph for tseries objects
%   band - Line-and-band graph for tseries objects
%   bar - Bar graph for tseries objects
%   barcon - Contribution bar graph for tseries objects
%   bubble - Bubble graph for tseries objects
%   errorbar - Line plot with error bars
%   plot - Line graph for tseries objects
%   plotcmp - Comparison graph for two time series
%   plotpred - Visualize multi-step-ahead predictions
%   plotyy - Line plot function with LHS and RHS axes for time series
%   scatter - Scatter graph for tseries objects
%   spy - Visualise tseries observations that pass a test
%   stem - Plot tseries as discrete sequence data
%
%
% __Manipulating Time Series Objects__
%
%   empty - Create empty time series or empty an existing time series
%   ifelse - Replace time series values based on a test condition
%   flipud - Flip time series data up to down
%   permute - Permute dimensions of a tseries object
%   repmat - Repeat copies of time series data
%   redate - Change time dimension of time series
%   reshape - Reshape size of time series in 2nd and higher dimensions
%   resize - Clip tseries object to specified date range
%   sort - Sort tseries columns by specified criterion
%
%
% __Converting Time Series__
%
%   convert - Convert tseries object to a different frequency
%   double - Return tseries observations as double-precision numeric array
%   doubledata - Convert tseries observations to double precision
%   single - Return tseries observations as single-precision numeric array
%   singledata - Convert tseries observations to single precision
%
%
% __Other Functions__
%
%   apct - Annualized percent rate of change
%   bsxfun - Implement bsxfun for tseries class
%   cumsumk - Cumulative sum with a k-period leap
%   destdize - Destandardize time series by multiplying it by std dev and adding mean
%   diff - First difference
%   interp - Interpolate missing observations
%   normalize - Normalise (or rebase) data to particular date
%   pct - Percent rate of change
%   round - Round tseries values to specified number of decimals
%   rmse - Compute RMSE for given observations and predictions
%   stdize - Standardize tseries data by subtracting mean and dividing by std deviation
%   windex - Simple weighted or Divisia index
%   wmean - Weighted average of time series observations
%
%

% -IRIS Macroeconomic Modeling Toolbox
% -Copyright (c) 2007-2018 IRIS Solutions Team

classdef (CaseInsensitiveProperties=true, InferiorClasses={?matlab.graphics.axis.Axes, ?DateWrapper}) ...
         tseries < TimeSubscriptable ...
                 & shared.GetterSetter ...
                 & shared.UserDataContainer
    properties
        Start = DateWrapper.NaD % Date of first observation available 
        Data = double.empty(0, 1) % Numeric array of time series data
        MissingValue = NaN % Representation of missing value
    end


    properties (Dependent)
        % MissingTest  Test for missing values
        MissingTest 

        % ColumnNames  Comments attached to each column of time series
        ColumnNames
    end


    methods
        function this = tseries(varargin)
            % tseries  Create new time series (tseries) object.
            %
            % __Syntax__
            %
            % Input arguments marked with a `~` sign may be omitted.
            %
            %     X = tseries( )
            %     X = tseries(Dates, Values, ~ColumnComments, ~UserData)
            %
            %
            % __Input Arguments__
            %
            % * `Dates` [ numeric | char ] - Dates for which observations will be
            % supplied; `dates` do not need to be sorted in ascending order or create a
            % continuous date range. If `dates` is scalar and `values` have multiple
            % rows, then the date is interpreted as the start date for the entire time
            % series.
            %
            % * `Values` [ numeric | function_handle ] - Numerical values
            % (observations) arranged columnwise, or a function that will be used to
            % create an N-by-1 array of values, where N is the number of `dates`.
            %
            % * `~Comment` [ char | cellstr | string ] - Comment or
            % comments attached to each column of observations; if omitted,
            % comments will be empty strings.
            %
            % * `~UserData` [ * ] - Any kind of user data attached to the
            % object; if omitted, user data will be empty.
            %
            %
            % __Output Arguments__
            %
            % * `X` [ tseries ] - New times series.
            %
            %
            % __Description__
            %
            %
            % __Example__
            %
            
            % -IRIS Macroeconomic Modeling Toolbox.
            % -Copyright (c) 2007-2018 IRIS Solutions Team.
            
            this = this@shared.UserDataContainer( );
            this = this@shared.GetterSetter( );
            this = resetComment(this);
            
            % Empty call
            if nargin==0
                return
            end
            
            % tseries input
            if nargin==1 && isequal(class(varargin{1}), 'tseries')
                this = varargin{1};
                return
            end

            % Cast struct or Series as tseries
            if nargin==1 && isstruct(varargin{1}) 
                this = struct2obj(this, varargin{1});
                return
            end

            persistent parser
            if isempty(parser)
                parser = extend.InputParser('tseries.tseries');
                parser.addRequired('Dates', @DateWrapper.validateDateInput);
                parser.addRequired('Values', @(x) isnumeric(x) || islogical(x) || isa(x, 'function_handle'));
                parser.addOptional('Comment', {char.empty(1, 0)}, @(x) isempty(x) || ischar(x) || iscellstr(x) || isa(x, 'string'));
                parser.addOptional('UserData', [ ], @(x) true);
            end

            parser.parse(varargin{:});
            dates = parser.Results.Dates;
            values = parser.Results.Values;
            comment = parser.Results.Comment;
            userData = parser.Results.UserData;

            if ischar(dates) || isa(dates, 'string')
                dates = textinp2dat(dates);
            end
            numOfDates = numel(dates);            

            if isempty(dates)
                freq = double.empty(1, 0);
            else
                if isa(dates, 'DateWrapper')
                    freq = DateWrapper.getFrequencyAsNumeric(getFirst(dates));
                else
                    freq = DateWrapper.getFrequencyAsNumeric(dates(1));
                end
                freq = freq(~isnan(freq));
                DateWrapper.checkMixedFrequency(freq);
            end
            serials = DateWrapper.getSerial(dates);
            serials = serials(:);
            
            %--------------------------------------------------------------
            
            % Create data from function handle.
            if isa(values, 'function_handle') 
                if isequal(values, @ltrend)
                    values = (1:numOfDates).';
                else
                    values = feval(values, [numOfDates, 1]);
                end
            elseif isnumeric(values) || islogical(values)
                if sum(size(values)>1)==1 && length(values)>1 && numOfDates>1
                    % Squeeze `Data` if scalar time series is entered as an non-columnwise
                    % vector.
                    values = values(:);
                elseif numel(values)==1 && numOfDates>1
                    % Expand scalar observation to match more than one of `Dates`.
                    values = repmat(values, size(serials));
                end
            end

            this = initMissingValue(this, values);
            
            % If `Dates` is scalar and `Data` have multiple rows, treat
            % `Dates` as a start date and expand the dates accordingly.
            numOfRowsInValues = size(values, 1);
            if numOfDates==1 && numOfRowsInValues>1
                serials = serials + (0 : numOfRowsInValues-1);
            end
            
            % Initialize the time series start date and data.
            this = init(this, freq, serials, values);
            
            % Populate comments for each column
            this = resetComment(this);
            if ~isempty(comment)
                this.Comment = comment;
            end
            
            this = userdata(this, userData);

            if ~isempty(this.Data) 
                this = trim(this);
            end
        end%
    end
    
    
    methods
        varargout = acf(varargin)
        varargout = apct(varargin)
        varargout = area(varargin)
        varargout = arf(varargin)
        varargout = arma(varargin)
        varargout = band(varargin)
        varargout = bar(varargin)
        varargout = barcon(varargin)
        varargout = bpass(varargin)
        varargout = bubble(varargin)
        varargout = bwf(varargin)
        varargout = bwf2(varargin)
        varargout = bsxfun(varargin)
        varargout = chowlin(varargin)
        varargout = conbar(varargin)
        varargout = convert(varargin)
        varargout = cumsumk(varargin)


        varargout = destdize(varargin)
        function varargout = destdise(varargin)
            [varargout{1:nargout}] = destdize(varargin{:});
        end


        varargout = detrend(varargin)
        varargout = diff(varargin)
        varargout = double(varargin)
        varargout = doubledata(varargin)
        varargout = errorbar(varargin)


        varargout = expsm(varargin)
        function varargout = expsmooth(varargin)
            [varargout{1:nargout}] = expsm(varargin{:});
        end


        varargout = fft(varargin)
        varargout = find(varargin)
        varargout = flipud(varargin)


        % Backward compatibility
        function varargout = freq(this)
            varargout = { this.Frequency };
        end%


        varargout = get(varargin)
        varargout = histogram(varargin)
        varargout = horzcat(varargin)
        varargout = hpdi(varargin)
        varargout = hpf(varargin)
        varargout = hpf2(varargin)
        varargout = infoset2line(varargin)
        varargout = interp(varargin)
        varargout = isempty(varargin)
        varargout = isequal(varargin)
        varargout = isscalar(varargin)
        varargout = length(varargin)
        varargout = llf(varargin)
        varargout = llf2(varargin)
        varargout = moving(varargin)
        varargout = ndims(varargin)


        varargout = normalize(varargin)
        function varargout = normalise(varargin)
            [varargout{1:nargout}] = normalize(varargin{:});
        end


        varargout = pct(varargin)
        varargout = pctmean(varargin)
        varargout = permute(varargin)
        varargout = plot(varargin)
        varargout = plotcmp(varargin)
        varargout = plotyy(varargin)
        varargout = plotpred(varargin)
        varargout = range(varargin)
        varargout = rebase(varargin)
        varargout = regress(varargin)
        varargout = repmat(varargin)
        varargout = reshape(varargin)
        varargout = resize(varargin)
        varargout = rmse(varargin)
        varargout = round(varargin)
        varargout = scatter(varargin)
        varargout = select(varargin)


        function obj = Series(this)
            obj = Series( );
            obj = struct2obj(obj, this);
        end


        varargout = single(varargin)
        varargout = singledata(varargin)
        varargout = size(varargin)
        varargout = sort(varargin)
        varargout = specrange(varargin)        
        varargout = spy(varargin)


        varargout = stdize(varargin)
        function varargout = stdise(varargin)
            [varargout{1:nargout}] = stdize(varargin{:});
        end%


        varargout = stem(varargin)
        varargout = subsasgn(varargin)
        varargout = subsref(varargin)
        varargout = trend(varargin)
        varargout = vertcat(varargin)
        varargout = wmean(varargin)
        varargout = x12(varargin)
        varargout = yearly(varargin)
        

        function date = startdate(this)
            date = this.Start;
        end%
        

        function date = enddate(this)
            date = this.End;
        end%   

        
        function varargout = x13(varargin)
            [varargout{1:nargout}] = x12(varargin{:});
        end%
    end
    
    
    methods (Hidden)
        disp(varargin)
        varargout = chkConsistency(varargin)
        varargout = max(varargin)
        varargout = min(varargin)
        varargout = cat(varargin)
        varargout = cut(varargin)
        varargout = df(varargin)
        varargout = divisia(varargin)


        varargout = fill(varargin)
        function varargout = replace(varargin)
            [varargout{1:nargout}] = fill(varargin{:});
        end%


        varargout = getDataFromTo(varargin)
        varargout = implementGet(varargin)
        varargout = maxabs(varargin)
        varargout = rearrangePred(varargin)
        varargout = rangedata(varargin)
        varargout = saveobj(varargin)
        varargout = setData(varargin)
        varargout = trim(varargin)
    end
    
    
    methods (Access=protected, Hidden)
        varargout = binop(varargin)
        varargout = catcheck(varargin)
        varargout = myfilter(varargin)
        varargout = init(varargin)
        varargout = mylagorlead(varargin)
        varargout = recognizeShift(varargin)
        varargout = unop(varargin)
        varargout = unopinx(varargin)
        
        
        function dispComment(varargin)
        end%


        function startDate = startDateWhenEmpty(this, varargin)
            if isa(this.Start, 'DateWrapper')
                startDate = DateWrapper.NaD( );
            else
                startDate = NaN;
            end
        end%


        function this = initMissingValue(this, values)
            if isa(values, 'single')
                this.MissingValue = single(NaN);
            elseif isa(values, 'logical')
                this.MissingValue = false;
            else
                this.MissingValue = NaN;
            end
        end%
    end
    
    
    methods (Static, Hidden)
        varargout = clpf(varargin)
        varargout = loadobj(varargin)        

        varargout = myband(varargin)
        varargout = mybarcon(varargin)
        varargout = myerrorbar(varargin)
        varargout = mynanmean(varargin)
        varargout = mynanstd(varargin)
        varargout = mynansum(varargin)
        varargout = mynanvar(varargin)
    end
    
    
    methods (Hidden)
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
            if (isa(x, 'tseries') && isa(y, 'tseries')) ...
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
            if (isa(x, 'tseries') && isa(y, 'tseries')) ...
                    || (isnumeric(x) && length(x)==1)
                x = binop(@rdivide, x, y);
            else
                x = binop(@mrdivide, x, y);
            end
        end%
        function x = mtimes(x, y)
            if isa(x, 'tseries') && isa(y, 'tseries')
                x = binop(@times, x, y);
            else
                x = binop(@mtimes, x, y);
            end
        end%
        function x = nanmean(x, dim)
            if nargin<2
                dim = 1;
            end
            % @@@@@ MOSW
            x = unop(@(varargin) tseries.mynanmean(varargin{:}), ...
                x, dim, dim);
        end%
        function This = nanstd(This, Flag, Dim)
            if nargin<2
                Flag = 0;
            end
            if nargin<3
                Dim = 1;
            end
            % @@@@@ MOSW
            This = unop(@(varargin) tseries.mynanstd(varargin{:}), ...
                This, Dim, Flag, Dim);
        end%
        function This = nansum(This, Dim)
            if nargin<2
                Dim = 1;
            end
            % @@@@@ MOSW
            This = unop(@(varargin) tseries.mynansum(varargin{:}), ...
                This, Dim, Dim);
        end%
        function This = nanvar(This, Flag, Dim)
            if nargin<2
                Flag = 0;
            end
            if nargin<3
                Dim = 1;
            end
            % @@@@@ MOSW
            This = unop(@(varargin) tseries.mynanvar(varargin{:}), ...
                This, Dim, Flag, Dim);
        end%
        function This = ne(This, Y)
            This = binop(@ne, This, Y);
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
        
        
        % Distribution functions (Stats Toolbox)
        %----------------------------------------
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
        
        
        
        
        % Functions whose behaviour differs in different dimensions
        %-----------------------------------------------------------
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
        function x = cumprod(x, dim)
            if nargin<2
                dim = 1;
            end
            x = unop(@cumprod, x, 0, dim);
        end%
        function x = cumsum(x, dim)
            if nargin<2
                dim = 1;
            end
            x = unop(@cumsum, x, 0, dim);
        end%
        function output = fillmissing(x, varargin)
            dim = 1;
            output = unop(@fillmissing, x, dim, varargin{:}, dim);
        end%
        function a = geomean(x, dim)
            if nargin<2
                dim = 1;
            end
            a = unop(@geomean, x, dim, dim);
        end%
        function x = mean(x, dim)
            if nargin <2
                dim = 1;
            end
            x = unop(@mean, x, dim, dim);
        end%
        function x = median(x, dim)
            if nargin <2
                dim = 1;
            end
            x = unop(@median, x, dim, dim);
        end%
        function x = mode(x, dim)
            if nargin <2
                dim = 1;
            end
            x = unop(@mode, x, dim, dim);
        end%


        function x = prctile(x, p, dim)
            if nargin<3
                dim = 2;
            end
            x = unop(@numeric.prctile, x, dim, p, dim);
        end%
        function varargout = pctile(varargin)
            [varargout{1:nargout}] = prctile(varargin{:});
        end%


        function x = std(x, flag, dim)
            if nargin<2
                flag = 0;
            end
            if nargin<3
                dim = 1;
            end
            x = unop(@std, x, dim, flag, dim);
        end%
        function x = sum(x, dim)
            if nargin<2
                dim = 1;
            end
            x = unop(@sum, x, dim, dim);
        end%
        function x = var(x, flag, dim)
            if nargin<2
                flag = 0;
            end
            if nargin<3
                dim = 1;
            end
            x = unop(@var, x, dim, flag, dim);
        end%

        %
        % Indexing
        %

        function index = end(this, k, varargin)
            if k==1
                numericStart = double(this.Start);
                index = numericStart + size(this.Data, 1) - 1;
                if isa(this.Start, 'DateWrapper')
                    index = DateWrapper(index);
                end
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
                missingTest = @isnan;
            else
                missingTest = @(x) x==missingValue;
            end
        end%
    end


    methods (Static)
        varargout = fromFred(varargin)
        varargout = linearTrend(varargin)
        varargout = implementPlot(varargin)
        varargout = empty(varargin)
    end
 end
