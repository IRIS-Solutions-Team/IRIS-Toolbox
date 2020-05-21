% # tseries Objects #
%{
% ## Description ##
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
% ## Categorical List ##
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
%   get - Query time series property
%   isequal - True if two time series are identical
%   length - Length of time series data in time dimension
%   ndims - Number of dimensions in time series data
%   size - Size of time series data
%   specrange - Time series specific range
%   tabular - Display time series in tabular view
%
%
% __Referencing Time Series__
%
%   subsasgn - Subscripted assignment to time series
%   subsref - Subscripted reference to time series
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
%   fft - Discrete Fourier transform of time series
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
%   area - Area graph for time series
%   band - Line-and-band graph for time series
%   bar - Bar graph for time series
%   barcon - Contribution bar graph for time series
%   bubble - Bubble graph for time series
%   errorbar - Line plot with error bars
%   plot - Line graph for time series
%   plotcmp - Comparison graph for two time series
%   plotpred - Visualize multi-step-ahead predictions
%   plotyy - Line plot function with LHS and RHS axes for time series
%   scatter - Scatter graph for time series
%   spy - Visualise time series that pass a test
%   stem - Plot time series discrete sequence data
%
%
% __Manipulating Time Series Objects__
%
%   empty - Create empty time series or empty an existing time series
%   ifelse - Replace time series values based on a test condition
%   flipud - Flip time series data up to down
%   permute - Permute dimensions of time series
%   repmat - Repeat copies of time series data
%   redate - Change time dimension of time series
%   reshape - Reshape size of time series in 2nd and higher dimensions
%   resize - Clip time series to specified date range
%   sort - Sort time series by specified criterion
%
%
% __Converting Time Series__
%
%   convert - Convert time series to a different frequency
%   double - Return time series data as double-precision numeric array
%   doubledata - Convert time series to double precision
%   single - Return time series data as single-precision numeric array
%   singledata - Convert time series data single precision
%
%
% __Other Functions__
%
%   apct - Annualized percent rate of change
%   aroc - Annualized gross rate of change
%   bsxfun - Implement bsxfun for time series
%   cumsumk - Cumulative sum with a k-period leap
%   destdize - Destandardize time series by multiplying it by std dev and adding mean
%   diff - First difference
%   fillMissing - 
%   interp - Interpolate missing observations
%   normalize - Normalise (or rebase) data to particular date
%   pct - Percent rate of change
%   removeWeekends - 
%   roc - Gross rate of change
%   rmse - Compute RMSE for given observations and predictions
%   stdize - Standardize time series data by subtracting mean and dividing by std deviation
%   windex - Simple weighted or Divisia index
%   wmean - Weighted average of time series observations
%
% __Standard Matlab Functions Implemented on Time Series Data__
%
%   round
%
%}

% -IRIS Macroeconomic Modeling Toolbox
% -Copyright (c) 2007-2020 IRIS Solutions Team

classdef (CaseInsensitiveProperties=true, InferiorClasses={?matlab.graphics.axis.Axes, ?DateWrapper}) ...
         tseries < NumericTimeSubscriptable

    methods % Constructor
        function this = tseries(varargin)
            this = this@NumericTimeSubscriptable(varargin{:});
        end%
    end




    methods
        varargout = area(varargin)
        varargout = arma(varargin)
        varargout = band(varargin)

        function varargout = bands(varargin)
            [varargout{1:nargout}] = tseries.implementPlot(@bands, varargin{:});
        end%

        varargout = bar(varargin)
        varargout = barcon(varargin)

        function varargout = binscatter(varargin)
            [varargout{1:nargout}] = tseries.implementPlot(@binscatter, varargin{:});
        end%

        varargout = bpass(varargin)
        varargout = bsxfun(varargin)
        varargout = chowlin(varargin)
        varargout = conbar(varargin)
        varargout = convert(varargin)
        varargout = detrend(varargin)
        varargout = double(varargin)
        varargout = doubledata(varargin)
        varargout = errorbar(varargin)


        varargout = expsm(varargin)
        function varargout = expsmooth(varargin)
            [varargout{1:nargout}] = expsm(varargin{:});
        end%


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
        varargout = infoset2line(varargin)
        varargout = interp(varargin)
        varargout = isempty(varargin)
        varargout = isequal(varargin)
        varargout = isscalar(varargin)
        varargout = length(varargin)
        varargout = moving(varargin)
        varargout = ndims(varargin)


        varargout = normalize(varargin)
        function varargout = normalise(varargin)
            [varargout{1:nargout}] = normalize(varargin{:});
        end%


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
        varargout = scatter(varargin)
        varargout = select(varargin)


        function obj = Series(this)
            obj = Series( );
            obj = struct2obj(obj, this);
        end%


        varargout = single(varargin)
        varargout = singledata(varargin)
        varargout = size(varargin)
        varargout = sort(varargin)
        varargout = specrange(varargin)        
        varargout = spy(varargin)
        varargout = stem(varargin)
        varargout = subsasgn(varargin)
        varargout = subsref(varargin)
        varargout = trend(varargin)
        varargout = wmean(varargin)
        varargout = x12(varargin)
        

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
        varargout = max(varargin)
        varargout = min(varargin)
        varargout = cat(varargin)
        varargout = cut(varargin)
        varargout = df(varargin)
        varargout = divisia(varargin)


        function disp(varargin)
            implementDisp(varargin{:});
            textual.looseLine( );
        end%


        varargout = implementGet(varargin)
        varargout = maxabs(varargin)
        varargout = rearrangePred(varargin)
        varargout = rangedata(varargin)
        varargout = saveobj(varargin)
    end
    
    


    methods (Access=protected, Hidden)
        varargout = catcheck(varargin)


        function implementDisp(varargin)
            implementDisp@NumericTimeSubscriptable(varargin{:});
            implementDisp@shared.UserDataContainer(varargin{:});
        end%
    end


    
    
    methods (Static, Hidden)
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
        function index = end(this, k, varargin)
            if k==1
                index = this.End;
            else
                index = size(this.Data, k);
            end
        end%
        

        function n = numel(~, varargin)
            n = 1;
        end%
    end




    methods (Static)
        varargout = linearTrend(varargin)
        varargout = implementPlot(varargin)
        varargout = empty(varargin)
    end
 end
