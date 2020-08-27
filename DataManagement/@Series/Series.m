% # Series Objects #
%
% Series objects are numerical time series (possibly multivariate)
% constructed at one of the following time frequencies:
%
% * yearly
% * half-yearly
% * quarterly
% * monthly
% * weekly
% * daily
% * integer
%

classdef ( ...
    CaseInsensitiveProperties=true, ...
    InferiorClasses={?matlab.graphics.axis.Axes, ?DateWrapper} ...
) Series < tseries 

    methods % Constructor
        function this = Series(varargin)
            this = this@tseries(varargin{:});
        end%


        function obj = tseries(this)
            obj = tseries( );
            obj = struct2obj(obj, this);
        end%
    end




    methods % Plotting
        %(
        varargout = plot(varargin)


        function varargout = bar(varargin)
            [varargout{1:nargout}] = Series.implementPlot(@bar, varargin{:});
        end%


        function varargout = binscatter(varargin)
            [varargout{1:nargout}] = Series.implementPlot(@binscatter, varargin{:});
        end%


        function varargout = area(varargin)
            [varargout{1:nargout}] = Series.implementPlot(@area, varargin{:});
        end%


        function varargout = bands(varargin)
            [varargout{1:nargout}] = Series.implementPlot(@bands, varargin{:});
        end%


        function varargout = histogram(varargin)
            [varargout{1:nargout}] = Series.implementPlot(@histogram, varargin{:});
        end%


        function varargout = scatter(varargin)
            [varargout{1:nargout}] = Series.implementPlot(@scatter, varargin{:});
        end%


        function varargout = stem(varargin)
            [varargout{1:nargout}] = Series.implementPlot(@stem, varargin{:});
        end%


        function varargout = stairs(varargin)
            [varargout{1:nargout}] = Series.implementPlot(@stairs, varargin{:});
        end%


        function varargout = barcon(varargin)
            [varargout{1:nargout}] = Series.implementPlot(@numeric.barcon, varargin{:});
        end%


        function varargout = errorbar(varargin)
            [varargout{1:nargout}] = Series.implementPlot(@numeric.errorbar, varargin{:});
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

        function this = template(varargin)
            persistent persistentSeries
            if ~isa(persistentSeries, "Series")
                persistentSeries = Series( );
            end
            this = persistentSeries;
        end%
    end
end
