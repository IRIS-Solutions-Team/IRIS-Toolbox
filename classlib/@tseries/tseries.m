classdef (CaseInsensitiveProperties=true, InferiorClasses={?matlab.graphics.axis.Axes, ?dates.Date}) ...
        tseries < shared.GetterSetter & shared.UserDataContainer 
    % tseries  Time Series (tseries Objects).
    %
    %
    % tseries methods:
    %
    % Constructor
    % ============
    %
    % * [`tseries`](tseries/tseries) - Create new time series (tseries) object.
    %
    %
    % Getting information about tseries objects
    % ==========================================
    %
    % * [`endDate`](tseries/endDate) - Date of the last available observation in a tseries object.
    % * [`freq`](tseries/freq) - Date frequency of tseries object.
    % * [`get`](tseries/get) - Query tseries object property.
    % * [`isequal`](tseries/isequal) - [Not a public function] Compare two tseries objects.
    % * [`length`](tseries/length) - Length of tseries object.
    % * [`ndims`](tseries/ndims) - Number of dimensions in tseries object data.
    % * [`size`](tseries/size) - Size of tseries object data.
    % * [`specrange`](tseries/specrange) - Time series specific range.
    % * [`startDate`](tseries/startDate) - Date of the first available observation in a tseries object.
    % * [`yearly`](tseries/yearly) - Display tseries object one calendar year per row.
    %
    %
    % Referencing tseries objects
    % ============================
    %
    % * [`subsasgn`](tseries/subsasgn) - Subscripted assignment for tseries objects.
    % * [`subsref`](tseries/subsref) - Subscripted reference function for tseries objects.
    %
    %
    % Maths and statistics functions and operators
    % =============================================
    %
    % Some of the following functions require the Statistics Toolbox.
    %
    % `+`, `-`, `*`, `\`, `/`, `^`, `&`, `|`, `~`, `==`, `~=`, `>=`, `>`, `<`, 
    % `<=`, `abs`, `acos`, `asin`, `atan`, `atan2`, `ceil`, `cos`,  `exp`, 
    % `fix`, `floor`, `imag`, `isinf`, `isnan`, `log`, `log10`, `real`, `round`, 
    % `sin`, `sqrt`, `tan`, `normpdf`, `normcdf`, `prctile`, `lognpdf`, 
    % `logncdf`
    %
    % The behaviour of the following functions depend on the dimension along
    % which they are performed.
    %
    % Some of the following functions require the Statistics Toolbox.
    %
    % `all`, `any`, `cumprod`, `cumsum`, `find`, `geomean`, `max`, `mean`, 
    % `median`, `min`, `mode`, `nanmean`, `nanstd`, `nansum`, `nanvar`, `prod`, 
    % `std`, `sum`, `var`
    %
    %
    % Filters and evaluation
    % =======================
    %
    % * [`arf`](tseries/arf) - Run autoregressive function on time series.
    % * [`arma`](tseries/arma) - Apply ARMA model to input series.
    % * [`bpass`](tseries/bpass) - Band-pass filter.
    % * [`bwf`](tseries/bwf) - Butterworth filter with tunes.
    % * [`bwf2`](tseries/bwf2) - Swap output arguments of the Butterworth filter with tunes.
    % * [`detrend`](tseries/detrend) - Remove a linear time trend.
    % * [`expsmooth`](tseries/expsmooth) - Exponential smoothing.
    % * [`hpf`](tseries/hpf) - Hodrick-Prescott filter with tunes (aka LRX filter).
    % * [`hpf2`](tseries/hpf2) - Swap output arguments of the Hodrick-Prescott filter with tunes.
    % * [`fft`](tseries/fft) - Discrete Fourier transform of tseries object.
    % * [`llf`](tseries/llf) - Local level filter (aka random walk plus white noise) with tunes.
    % * [`llf2`](tseries/llf2) - Swap output arguments of the local linear trend filter with tunes.
    % * [`moving`](tseries/moving) - Apply function to moving window of observations.
    % * [`trend`](tseries/trend) - Estimate a time trend.
    % * [`x12`](tseries/x12) - Access to X13-ARIMA-SEATS seasonal adjustment program.
    %
    %
    % Estimation and sample characteristics
    % ======================================
    %
    % Note that most of the sample characteristics are listed above in the
    % Maths and statistics functions and operators section.
    %
    % * [`acf`](tseries/acf) - Sample autocovariance and autocorrelation functions.
    % * [`hpdi`](tseries/hpdi) - Highest probability density interval.
    % * [`chowlin`](tseries/chowlin) - Chow-Lin distribution of low-frequency observations over higher-frequency periods.
    % * [`regress`](tseries/regress) - Ordinary or weighted least-square regression.
    %
    %
    % Visualising tseries objects
    % ============================
    %
    % * [`area`](tseries/area) - Area graph for tseries objects.
    % * [`band`](tseries/band) - Line-and-band graph for tseries objects.
    % * [`bar`](tseries/bar) - Bar graph for tseries objects.
    % * [`barcon`](tseries/barcon) - Contribution bar graph for tseries objects.
    % * [`bubble`](tseries/bubble) - Bubble graph for tseries objects.
    % * [`errorbar`](tseries/errorbar) - Line plot with error bars.
    % * [`plot`](tseries/plot) - Line graph for tseries objects.
    % * [`plotcmp`](tseries/plotcmp) - Comparison graph for two time series.
    % * [`plotpred`](tseries/plotpred) - Visualize multi-step-ahead predictions.
    % * [`plotyy`](tseries/plotyy) - Line plot function with LHS and RHS axes for time series.
    % * [`scatter`](tseries/scatter) - Scatter graph for tseries objects.
    % * [`spy`](tseries/spy) - Visualise tseries observations that pass a test.
    % * [`stem`](tseries/stem) - Plot tseries as discrete sequence data.
    %
    %
    % Manipulating tseries objects
    % =============================
    %
    % * [`empty`](tseries/empty) - Empty time series preserving the size in 2nd and higher dimensions.
    % * [`flipud`](tseries/flipud) - Flip time series data up to down.
    % * [`permute`](tseries/permute) - Permute dimensions of a tseries object.
    % * [`repmat`](tseries/repmat) - Repeat copies of time series data.
    % * [`redate`](tseries/redate) - Change time dimension of time series.
    % * [`reshape`](tseries/reshape) - Reshape size of time series in 2nd and higher dimensions.
    % * [`resize`](tseries/resize) - Clip tseries object down to a specified date range.
    % * [`sort`](tseries/sort) - Sort tseries columns by specified criterion.
    %
    %
    % Converting tseries objects
    % ===========================
    %
    % * [`convert`](tseries/convert) - Convert tseries object to a different frequency.
    % * [`double`](tseries/double) - Return tseries observations as double-precision numeric array.
    % * [`doubledata`](tseries/doubledata) - Convert tseries observations to double precision.
    % * [`single`](tseries/single) - Return tseries observations as single-precision numeric array.
    % * [`singledata`](tseries/singledata) - Convert tseries observations to single precision.
    %
    %
    % Other tseries functions
    % ========================
    %
    % * [`apct`](tseries/apct) - Annualised percent rate of change.
    % * [`bsxfun`](tseries/bsxfun) - Implement bsxfun for tseries class.
    % * [`cumsumk`](tseries/cumsumk) - Cumulative sum with a k-period leap.
    % * [`destdise`](tseries/destdise) - Destandardise tseries object by applying specified standard deviation and mean to it.
    % * [`diff`](tseries/diff) - First difference.
    % * [`interp`](tseries/interp) - Interpolate missing observations.
    % * [`normalise`](tseries/normalise) - Normalise (or rebase) data to particular date.
    % * [`pct`](tseries/pct) - Percent rate of change.
    % * [`round`](tseries/round) - Round tseries values to specified number of decimals.
    % * [`rmse`](tseries/rmse) - Compute RMSE for given observations and predictions.
    % * [`stdise`](tseries/stdise) - Standardise tseries data by subtracting mean and dividing by std deviation.
    % * [`windex`](tseries/windex) - Simple weighted or Divisia index.
    % * [`wmean`](tseries/wmean) - Weighted average of time series observations.
    %
    %
    % Getting on-line help on tseries functions
    % ==========================================
    %
    %     help tseries
    %     help tseries/function_name
    %
    
    % -IRIS Macroeconomic Modeling Toolbox.
    % -Copyright (c) 2007-2017 IRIS Solutions Team.
    
    
    properties
        Start = NaN % Date of first available observation
        Data = zeros(0, 1) % Time series data
    end
    
    
    
    
    methods
        function this = tseries(varargin)
            % tseries  Create new time series (tseries) object.
            %
            %
            % Syntax
            % =======
            %
            %     x = tseries( )
            %     x = tseries(dates, values)
            %     x = tseries(dates, values, comment)
            %
            %
            % Input arguments
            % ================
            %
            % * `dates` [ numeric | char ] - Dates for which observations will be
            % supplied; `dates` do not need to be sorted in ascending order or create a
            % continuous date range. If `dates` is scalar and `values` have multiple
            % rows, then the date is interpreted as the start date for the entire time
            % series.
            %
            % * `values` [ numeric | function_handle ] - Numerical values
            % (observations) arranged columnwise, or a function that will be used to
            % create an N-by-1 array of values, where N is the number of `dates`.
            %
            % * `comment` [ char | cellstr ] - Comment or comments attached to each
            % column of observations.
            %
            %
            % Output arguments
            % =================
            %
            % * `x` [ tseries ] - New times series.
            %
            %
            % Description
            % ============
            %
            %
            % Example
            % ========
            %
            
            % -IRIS Macroeconomic Modeling Toolbox.
            % -Copyright (c) 2007-2017 IRIS Solutions Team.
            
            this = this@shared.UserDataContainer( );
            this = this@shared.GetterSetter( );
            this.Comment = {''};
            
            % Empty call.
            if nargin==0
                return
            end
            
            % Tseries input.
            if nargin==1 && isa(varargin{1}, 'tseries')
                this = varargin{1};
                return
            end
            
            % Struct input; called from within load( ), loadobj( ), loadstruct( ), cat( ), 
            % hdataouput( ).
            if nargin==1 && isstruct(varargin{1})
                this = struct2obj(this, varargin{1});
                return
            end

            [dat, values, cmt, varargin] = ...
                irisinp.parser.parse('tseries.tseries', varargin{:}); %#ok<ASGLU>
            dat = double(dat); % Store start date as double, not dates.Date.
            dat = dat(:);
            nPer = length(dat);            
            
            %--------------------------------------------------------------
            
            % Find out the date frequency and check its consistency.
            freq = datfreq(dat);
            freq(isnan(freq)) = [ ];
            dates.Date.chkMixedFrequency(freq);
            
            % Create data from function handle.
            if isa(values, 'function_handle') 
                if isequal(values, @ltrend)
                    values = (1:nPer).';
                else
                    values = feval(values, [nPer, 1]);
                end
            elseif isnumeric(values) || islogical(values)
                if sum(size(values)>1)==1 && length(values)>1 && nPer>1
                    % Squeeze `Data` if scalar time series is entered as an non-columnwise
                    % vector.
                    values = values(:);
                elseif length(values)==1 && nPer>1
                    % Expand scalar `Data` point to match more than one of `Dates`.
                    values = values(ones(size(dat)));
                end
            end
            
            % If `Dates` is scalar and `Data` have multiple rows, treat
            % `Dates` as a start date and expand the dates accordingly.
            if nPer==1 && size(values, 1)>1
                dat = dat + (0 : size(values, 1)-1);
            end
            
            % Initialize the time series start date and data.
            this = init(this, dat, values);
            
            % Populate comments for each column.
            sizeCmt = size(this.Data);
            sizeCmt(1) = 1;
            this.Comment = cell(sizeCmt);
            this.Comment(:) = {''};
            if isempty(cmt)
                % Do nothing.
            elseif ischar(cmt)
                this.Comment(:) = { cmt };
            elseif iscellstr(cmt)
                try
                    this.Comment(:) = cmt(:);
                catch Error
                    throw( exception.Base('Series:InvalidCommentSize', 'error') );
                end
            end
            
            if ~isempty(this.Data) && any(any(isnan(this.Data([1, end], :))))
                this = trim(this);
            end
        end
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
        varargout = comment(varargin)
        varargout = conbar(varargin)
        varargout = convert(varargin)
        varargout = cumsumk(varargin)
        varargout = destdise(varargin)
        varargout = detrend(varargin)
        varargout = diff(varargin)
        varargout = double(varargin)
        varargout = doubledata(varargin)
        varargout = empty(varargin)
        varargout = endDate(varargin)
        varargout = errorbar(varargin)
        varargout = expsmooth(varargin)
        varargout = fft(varargin)
        varargout = find(varargin)
        varargout = flipud(varargin)
        varargout = freq(varargin)
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
        varargout = normalise(varargin)
        varargout = pct(varargin)
        varargout = pctmean(varargin)
        varargout = permute(varargin)
        varargout = plot(varargin)
        varargout = plotcmp(varargin)
        varargout = plotyy(varargin)
        varargout = plotpred(varargin)
        varargout = range(varargin)
        varargout = rebase(varargin)
        varargout = repmat(varargin)
        varargout = regress(varargin)
        varargout = reshape(varargin)
        varargout = resize(varargin)
        varargout = rmse(varargin)
        varargout = round(varargin)
        varargout = scatter(varargin)
        varargout = select(varargin)
        varargout = single(varargin)
        varargout = singledata(varargin)
        varargout = size(varargin)
        varargout = sort(varargin)
        varargout = specrange(varargin)        
        varargout = spy(varargin)
        varargout = startDate(varargin)
        varargout = stdise(varargin)
        varargout = stem(varargin)
        varargout = subsasgn(varargin)
        varargout = subsref(varargin)
        varargout = trend(varargin)
        varargout = vertcat(varargin)
        varargout = wmean(varargin)
        varargout = x12(varargin)
        varargout = yearly(varargin)
        
        
        
        
        % Alias:
        function varargout = startdate(varargin)
            [varargout{1:nargout}] = startDate(varargin{:});
        end
        function varargout = enddate(varargin)
            [varargout{1:nargout}] = endDate(varargin{:});
        end        
    end
    
    
    
    
    methods (Hidden)
        disp(varargin)
        varargout = chkConsistency(varargin)
        varargout = max(varargin)
        varargout = min(varargin)
        varargout = mygetdata(varargin)        
        varargout = cat(varargin)
        varargout = cut(varargin)
        varargout = destdize(varargin)
        varargout = df(varargin)
        varargout = divisia(varargin)
        varargout = implementGet(varargin)
        varargout = maxabs(varargin)
        varargout = normalize(varargin)
        varargout = rearrangePred(varargin)
        varargout = rangedata(varargin)
        varargout = replace(varargin)
        varargout = saveobj(varargin)
        varargout = trim(varargin)
        varargout = stdize(varargin)
    end
    
    
    
    
    methods (Access=protected, Hidden)
        varargout = myfilter(varargin)
        varargout = init(varargin)
        varargout = mylagorlead(varargin)
        varargout = binop(varargin)
        varargout = unop(varargin)
        varargout = unopinx(varargin)
        varargout = catcheck(varargin)
        
        
        
        
        function dispComment(varargin)
        end
    end
    
    
    
    
    methods (Static, Hidden)
        varargout = loadobj(varargin)        
        varargout = myband(varargin)
        varargout = mybarcon(varargin)
        varargout = mybpass(varargin)
        varargout = mychristianofitzgerald(varargin)
        varargout = mycumsumk(varargin)
        varargout = mydestdize(varargin)
        varargout = mydiff(varargin)
        varargout = myexpsmooth(varargin)
        varargout = myhpdi(varargin)
        varargout = myerrorbar(varargin)
        varargout = mymoving(varargin)
        varargout = mynanmean(varargin)
        varargout = mynanstd(varargin)
        varargout = mynansum(varargin)
        varargout = mynanvar(varargin)
        varargout = myprctile(varargin)
        varargout = mypct(varargin)
        varargout = myplot(varargin)
        varargout = myshift(varargin)
        varargout = mystdize(varargin)
        varargout = mytrend(varargin)
    end

    
    
    
    methods (Hidden)
        function x = abs(x)
            x.Data = abs(x.Data);
        end
        function x = acos(x)
            x.Data = acos(x.Data);
            x = trim(x);
        end
        function x = and(x, y)
            x = binop(@and, x, y);
        end
        function x = asin(x)
            x.Data = asin(x.Data);
            x = trim(x);
        end
        function x = atan(x)
            x.Data = atan(x.Data);
            x = trim(x);
        end
        function x = atan2(x)
            x.Data = atan2(x.Data);
            x = trim(x);
        end
        function x = ceil(x)
            x.Data = ceil(x.Data);
        end
        function x = complex(x)
            x.Data = complex(x.Data);
        end
        function x = cos(x)
            x.Data = cos(x.Data);
            x = trim(x);
        end
        function x = eq(a, b)
            x = binop(@eq, a, b);
        end
        function x = exp(x)
            x.Data = exp(x.Data);
            x = trim(x);
        end
        function x = fix(x)
            x.Data = fix(x.Data);
            x = trim(x);
        end
        function x = floor(x)
            x.Data = floor(x.Data);
        end
        function x = ge(a, b)
            x = binop(@ge, a, b);
        end
        function x = gt(a, b)
            x = binop(@gt, a, b);
        end
        function x = imag(x)
            x = unop(@imag, x, 0);
            x = trim(x);
        end
        function x = isinf(x)
            x.Data = isinf(x.Data);
        end
        function x = isnan(x)
            x.Data = isnan(x.Data);
        end
        function flag = isreal(x)
            flag = isreal(x.Data);
        end
        function x = ldivide(a, b)
            x = binop(@ldivide, a, b);
        end
        function x = le(a, b)
            x = binop(@le, a, b);
        end
        function x = log(x)
            x.Data = log(x.Data);
            x = trim(x);
        end
        function x = log10(x)
            x.Data = log10(x.Data);
            x = trim(x);
        end
        function x = lt(a, b)
            x = binop(@lt, a, b);
        end
        function x = minus(a, b)
            x = binop(@minus, a, b);
        end
        function x = mldivide(x, y)
            if (isa(x, 'tseries') && isa(y, 'tseries')) ...
                    || (isnumeric(y) && length(y)==1)
                x = binop(@ldivide, x, y);
            else
                x = binop(@mldivide, x, y);
            end
        end
        function x = mpower(x, y)
            x = binop(@power, x, y);
        end
        function x = mrdivide(x, y)
            if (isa(x, 'tseries') && isa(y, 'tseries')) ...
                    || (isnumeric(x) && length(x)==1)
                x = binop(@rdivide, x, y);
            else
                x = binop(@mrdivide, x, y);
            end
        end
        function x = mtimes(x, y)
            if isa(x, 'tseries') && isa(y, 'tseries')
                x = binop(@times, x, y);
            else
                x = binop(@mtimes, x, y);
            end
        end
        function x = nanmean(x, dim)
            if nargin<2
                dim = 1;
            end
            % @@@@@ MOSW
            x = unop(@(varargin) tseries.mynanmean(varargin{:}), ...
                x, dim, dim);
        end
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
        end
        function This = nansum(This, Dim)
            if nargin<2
                Dim = 1;
            end
            % @@@@@ MOSW
            This = unop(@(varargin) tseries.mynansum(varargin{:}), ...
                This, Dim, Dim);
        end
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
        end
        function This = ne(This, Y)
            This = binop(@ne, This, Y);
        end
        function x = norm(x, varargin)
            x = norm(x.Data, varargin{:}) ;
        end
        function x = not(x)
            x.Data = not(x.Data);
        end
        function x = or(x, y)
            x = binop(@or, x, y);
        end
        function x = plus(x, y)
            x = binop(@plus, x, y);
        end
        function x = power(x, y)
            x = binop(@power, x, y);
        end
        function x = prod(x, dim)
            if nargin<2
                dim = 1;
            end
            x = unop(@prod, x, dim, dim);
        end
        function x = rdivide(x, y)
            x = binop(@rdivide, x, y);
        end
        function x = real(x)
            x.Data = real(x.Data);
            x = trim(x);
        end
        function x = sin(x)
            x.Data = sin(x.Data);
            x = trim(x);
        end
        function x = sqrt(x)
            x.Data = sqrt(x.Data);
            x = trim(x);
        end
        function x = tan(x)
            x.Data = tan(x.Data);
            x = trim(x);
        end
        function x = times(x, y)
            x = binop(@times, x, y);
        end
        function x = uminus(x)
            x.Data = -x.Data;
        end
        function x = uplus(x)
        end
        
        
        
        
        % Distribution functions (Stats Toolbox)
        %----------------------------------------
        function x = normcdf(x, varargin)
            x.Data = normcdf(x.Data, varargin{:});
            x = trim(x);
        end
        function x = normpdf(x, varargin)
            x.Data = normpdf(x.Data, varargin{:});
            x = trim(x);
        end
        function x = norminv(x, varargin)
            x.Data = norminv(x.Data, varargin{:});
            x = trim(x);
        end
        function x = logncdf(x, varargin)
            x.Data = logncdf(x.Data, varargin{:});
            x = trim(x);
        end
        function x = lognpdf(x, varargin)
            x.Data = lognpdf(x.Data, varargin{:});
            x = trim(x);
        end
        function x = logninv(x, varargin)
            x.Data = logninv(x.Data, varargin{:});
            x = trim(x);
        end
        function x = gevcdf(x, varargin)
            x.Data = gevcdf(x.Data, varargin{:});
            x = trim(x);
        end
        function x = gevpdf(x, varargin)
            x.Data = gevpdf(x.Data, varargin{:});
            x = trim(x);
        end
        function x = gevinv(x, varargin)
            x.Data = gevinv(x.Data, varargin{:});
            x = trim(x);
        end
        
        
        
        
        % Functions whose behaviour differs in different dimensions
        %-----------------------------------------------------------
        function x = any(x, dim)
            if nargin<2
                dim = 1;
            end
            x = unop(@any, x, dim, dim);
        end
        function x = all(x, dim)
            if nargin<2
                dim = 1;
            end
            x = unop(@all, x, dim, dim);
        end
        function x = cumprod(x, dim)
            if nargin<2
                dim = 1;
            end
            x = unop(@cumprod, x, 0, dim);
        end
        function x = cumsum(x, dim)
            if nargin<2
                dim = 1;
            end
            x = unop(@cumsum, x, 0, dim);
        end
        function a = geomean(x, dim)
            if nargin<2
                dim = 1;
            end
            a = unop(@geomean, x, dim, dim);
        end
        function x = mean(x, dim)
            if nargin <2
                dim = 1;
            end
            x = unop(@mean, x, dim, dim);
        end
        function x = median(x, dim)
            if nargin <2
                dim = 1;
            end
            x = unop(@median, x, dim, dim);
        end
        function x = mode(x, dim)
            if nargin <2
                dim = 1;
            end
            x = unop(@mode, x, dim, dim);
        end
        function x = prctile(x, p, dim)
            if nargin<3
                dim = 1;
            end
            % @@@@@ MOSW
            x = unop(@(varargin) tseries.myprctile(varargin{:}), ...
                x, dim, p, dim);
        end
        % Alias for prctile.
        function varargout = pctile(varargin)
            [varargout{1:nargout}] = prctile(varargin{:});
        end
        function x = std(x, flag, dim)
            if nargin<2
                flag = 0;
            end
            if nargin<3
                dim = 1;
            end
            x = unop(@std, x, dim, flag, dim);
        end
        function x = sum(x, dim)
            if nargin<2
                dim = 1;
            end
            x = unop(@sum, x, dim, dim);
        end
        function x = var(x, flag, dim)
            if nargin<2
                flag = 0;
            end
            if nargin<3
                dim = 1;
            end
            x = unop(@var, x, dim, flag, dim);
        end
    
        
        
        
        % Indexing
        %----------
        function index = end(x, k, n) %#ok<INUSD>
            if k==1
                index = x.Start + size(x.Data, 1) - 1;
            else
                index = size(x.Data, k);
            end
        end
        function n = numel(~, varargin)
            n = 1;
        end
    end
 end
