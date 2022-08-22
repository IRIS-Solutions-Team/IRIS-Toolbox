% # Overview of Series objects
% 
% Series objects are two- or higher-dimensional arrays whose rows (indexing along first dimension) are
% referenced by dates. The arrays can be one of the following types:
% 
% * numeric arrays
% * string arrays
% * cell arrays
% 
% The time dimension of the Series objects can be any of the IrisT date frequencies:
% 
% * yearly
% * half-yearly
% * quarterly
% * monthly
% * weekly
% * daily
% * integer
% 
% 
% ## Categorical list of functions
% 
%     acf     - Ffffff
% 
% 
% ### Constructing time series objects
% 
% Function                                                     | Description
% -------------------------------------------------------------|----------------------------------------------------------
% [`Series`](Series.md)                                        | Create new time series object
% [`Series.linearTrend`](linearTrend.md)                       | Create time series with linear trend
% [`Series.empty`](empty.md)                                   | Create empty time series or empty existing time series
% [`Series.seasonDummy`](seasonDummy.md)                       | Create time series with seasonal dummies
% [`Series.randomlyGrowing`](randomlyGrowing.md)               | Create randomly growing time series
% 
% 
% ### Generating new time series
% 
% [`Series.grow`](grow.md)                                     | Cumulate level time series from differences or rates of growth
% 
% 
% #### Converting and modifying time series
% 
% Function | Description
% ---|---
% [`convert`](convert.md)                                      | Convert time series to another frequency
% [`rebase`](rebase.md)                                        | Rebase times series data to specified period
% [`fillMissing`](fillMissing.md)                              | Fill missing time series observations
% 
% 
% #### Filtering and aggregating time series
% 
% Function | Description 
% ---|---
% [`arf`](arf.md)                                              | Create autoregressive time series from input data
% [`hpf`](hpf.md)                                              | Hodrick-Prescott filter with conditioning information
% [`moving`](moving.md)                                        | Apply function to moving window of time series observations
% [`chainlink`](chainlink.md)                                  | Calculate chain linked aggregate level series from level components and weights
% 
% 
% #### Regression and statistics
% 
% Function | Description 
% ---|---
% [`rmse`](rmse.md)                                            | Calculate RMSE for given observations and predictions
% [`regress`](regress.md)                                      | Ordinary or weighted least-square regression
% 



classdef ( ...
    CaseInsensitiveProperties=true, ...
    InferiorClasses={?matlab.graphics.axis.Axes, ?DateWrapper, ?Dater} ...
) Series < tseries 

    methods % Constructor
        function this = Series(varargin)
%
% Series  Construct new time series object
% Type <a href="matlab: ihelp Series/Series">xxx</a> to get help
%

%{

# Series

{== Construct new time series object ==}
%}
            this = this@tseries(varargin{:});
        end%


        function obj = tseries(this)
            obj = tseries( );
            obj = struct2obj(obj, this);
        end%
    end




    methods % Plotting
        %(
        varargout = band(varargin)
        varargout = plot(varargin)


        function varargout = bands(varargin)
            [varargout{1:nargout}] = Series.implementPlot(@bands, varargin{:});
        end%


        function varargout = barcon(varargin)
            [varargout{1:nargout}] = Series.implementPlot(@series.barcon, varargin{:});
        end%


        function varargout = errorbar(varargin)
            [varargout{1:nargout}] = Series.implementPlot(@series.errorbar, varargin{:});
        end%
        %)
    end


    methods
        varargout = spy(varargin)
    end


    methods (Static)
        varargout = linearTrend(varargin)
        varargout = implementPlot(varargin)
        varargout = empty(varargin)
        varargout = seasonDummy(varargin)
        varargout = randomlyGrowing(varargin)

        function this = template(varargin)
            persistent persistentSeries
            if ~isa(persistentSeries, 'Series')
                persistentSeries = Series( );
            end
            this = persistentSeries;
        end%
    end
end
