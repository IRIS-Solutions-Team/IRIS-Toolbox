classdef (Abstract, InferiorClasses={?matlab.graphics.axis.Axes}) TimeSubscriptable
    properties (Abstract)
        % Start  Date of first observation in time series
        Start

        % Data  Array of time series data
        Data

        % MissingValue  Value representing missing observations in time series
        MissingValue
    end


    properties (Dependent)
        % StartAsNumeric  Date of first observation in time series returned as numeric value (double)
        StartAsNumeric

        % StartAsDateWrapper  Date of first observation in time series returned as DateWrapper
        StartAsDateWrapper

        % End  Date of last observation in time series
        End

        % EndAsNumeric  Date of last observation in time series returned as numeric value (double)
        EndAsNumeric

        % EndAsDateWrapper  Date of last observation in time series returned as DateWrapper
        EndAsDateWrapper

        % Frequency  Date frequency of time series
        Frequency

        % FrequencyAsNumeric  Date frequency of times series returned as numeric value (double)
        FrequencyAsNumeric

        % Range  Date range from first to last observation in time series
        Range

        % RangeAsDateWrapper  Date range from first to last observation in time series returned as numeric value
        RangeAsNumeric

        % RangeAsDateWrapper  Date range from first to last observation in time series returned as DateWrapper
        RangeAsDateWrapper
    end


    properties (Abstract, Dependent)
        MissingTest
    end


    properties (Constant)
        EMPTY_COMMENT = char.empty(1, 0)
    end


    methods (Abstract, Access=protected, Hidden)
        varargout = startDateWhenEmpty(varargin)
    end


    methods (Access=protected)
        varargout = resolveRange(varargin)
    end


    methods
        varargout = clip(varargin)
        varargout = getData(varargin)
        varargout = getDataNoFrills(varargin)
        varargout = ifelse(varargin)
        varargout = ellone(varargin)
        varargout = shift(varargin)
        varargout = spy(varargin)


        function varargout = plot(varargin)
            [varargout{1:nargout}] = TimeSubscriptable.implementPlot(@plot, varargin{:});
        end%


        function varargout = bar(varargin)
            [varargout{1:nargout}] = TimeSubscriptable.implementPlot(@bar, varargin{:});
        end%


        function varargout = area(varargin)
            [varargout{1:nargout}] = TimeSubscriptable.implementPlot(@area, varargin{:});
        end%


        function varargout = stem(varargin)
            [varargout{1:nargout}] = TimeSubscriptable.implementPlot(@stem, varargin{:});
        end%


        function varargout = stairs(varargin)
            [varargout{1:nargout}] = TimeSubscriptable.implementPlot(@stairs, varargin{:});
        end%


        function varargout = barcon(varargin)
            [varargout{1:nargout}] = TimeSubscriptable.implementPlot(@numeric.barcon, varargin{:});
        end%


        function varargout = errorbar(varargin)
            [varargout{1:nargout}] = TimeSubscriptable.implementPlot(@numeric.errorbar, varargin{:});
        end%


        function varargout = binscatter(varargin)
            [~, time, yData, axesHandle, xData, unmatched] = TimeSubscriptable.implementPlot([ ], varargin{:});
            indexOfNaN = any(isnan(yData), 2);
            plotHandle = binscatter(yData(~indexOfNaN, 1), yData(~indexOfNaN, 2), unmatched{:});
            varargout = {plotHandle, time, yData, axesHandle, xData};
        end%



        function startDateAsNumeric = get.StartAsNumeric(this)
            startDateAsNumeric = double(this.Start);
        end%
         

        function startDateAsDateWrapper = get.StartAsDateWrapper(this)
            startDateAsDateWrapper = this.Start;
            if ~isa(startDateAsDateWrapper, 'DateWrapper')
                startDateAsDateWrapper = DateWrapper(startDateAsDateWrapper);
            end
        end%
         

        function endDate = get.End(this)
            if isnan(this.Start)
                endDate = this.Start;
                return
            end
            endDate = addTo(this.Start, size(this.Data, 1)-1);
        end%


        function endDateAsNumeric = get.EndAsNumeric(this)
            endDateAsNumeric = double(this.End);
        end%
         

        function endDateAsDateWrapper = get.EndAsDateWrapper(this)
            endDateAsDateWrapper = this.End;
            if ~isa(endDateAsDateWrapper, 'DateWrapper')
                endDateAsDateWrapper = DateWrapper(endDateAsDateWrapper);
            end
        end%
         

        function frequency = get.Frequency(this)
            frequency = DateWrapper.getFrequency(double(this.Start));
        end%


        function frequency = get.FrequencyAsNumeric(this)
            frequency = DateWrapper.getFrequencyAsNumeric(double(this.Start));
        end%


        function frequency = getFrequency(this)
            frequency = DateWrapper.getFrequency(double(this.Start));
        end%


        function frequency = getFrequencyAsNumeric(this)
            frequency = DateWrapper.getFrequencyAsNumeric(double(this.Start));
        end%


        function range = get.Range(this)
            range = this.RangeAsNumeric;
            if isa(this.Start, 'DateWrapper')
               range = DateWrapper(range);
            end 
        end%


        function numericRange = get.RangeAsNumeric(this)
            numericStart = double(this.Start);
            numericRange = numericStart + (0 : size(this.Data, 1)-1);
            numericRange = transpose(numericRange);
        end%


        function range = get.RangeAsDateWrapper(this)
            range = this.RangeAsNumeric;
            range = DateWrapper(range);
        end%


        function this = emptyData(this)
            if isnan(this.Start) || size(this.Data, 1)==0
                return
            end
            sizeOfData = size(this.Data);
            newSizeOfData = [0, sizeOfData(2:end)];
            this.Start = startDateWhenEmpty(this);
            this.Data = repmat(this.MissingValue, newSizeOfData);
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
            flag = DateWrapper.getFrequencyAsNumeric(this.Start)==DateWrapper.getFrequencyAsNumeric(dates) ...
                 | isnan(dates);
        end%


        function flag = validateFrequencyOrInf(this, dates)
            flag = isinf(dates) | validateFrequency(this, dates);
        end%


        function checkFrequencyOrInf(this, dates)
            if any(~validateFrequencyOrInf(this, dates))
                freqOfThis = DateWrapper.getFrequencyAsNumeric(this.Start);
                freqOfDates = DateWrapper.getFrequencyAsNumeric(dates);
                freqOfDates = unique(freqOfDates, 'stable');
                charFreqOfDates = arrayfun(@Frequency.toChar, freqOfDates, 'UniformOutput', false);
                throw( exception.Base('TimeSubscriptable:FrequencyMismatch', 'error'), ...
                       Frequency.toChar(freqOfThis),charFreqOfDates{:} );
            end
        end%
    end


    methods (Static)
        varargout = getExpSmoothMatrix(varargin)
        varargout = createDateAxisData(varargin)
        varargout = implementPlot(varargin)
    end


    methods (Static, Access=protected)
        varargout = trimRows(varargin)
    end
end
