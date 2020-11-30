classdef (Abstract, InferiorClasses={?matlab.graphics.axis.Axes}) ...
         TimeSubscriptable
        % Exchange Rate Valuation Effect
    properties 
        % Start  Date of first observation in time series
        Start (1, 1) = DateWrapper.NaD

        % Comment  User comments attached to individual columns of time series
        Comment = { TimeSubscriptable.EMPTY_COMMENT }
    end


    properties (Abstract)
        % Data  Array of time series data
        Data

        % MissingValue  Value representing missing observations in time series
        MissingValue
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

        % EndAsDate  Date of last observation in time series returned as DateWrapper
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

        % RangeAsDate  Date range from first to last observation in time series returned as DateWrapper
        RangeAsDate
        RangeAsDateWrapper
    end


    properties (Abstract, Dependent)
        MissingTest
    end


    properties (Constant)
        EMPTY_COMMENT = char.empty(1, 0)
    end


    methods (Abstract, Access=protected, Hidden)
        varargout = checkDataClass(varargin)
        varargout = createDataFromFunction(varargin)
        varargout = resetMissingValue(varargin)
    end


    methods
        varargout = clip(varargin)
        varargout = comment(varargin)
        varargout = getData(varargin)
        varargout = getDataFromTo(varargin)
        varargout = getDataNoFrills(varargin)
        varargout = getDataFromMultiple(varargin)
        varargout = ifelse(varargin)
        varargout = init(varargin)
        varargout = redate(varargin)
        varargout = removeWeekends(varargin)
        varargout = resetComment(varargin)
        varargout = retrieveColumns(varargin)
        varargout = setData(varargin)
        varargout = shift(varargin)


        function value = get.Self(this)
            value = this;
        end%


        function startDateAsNumeric = get.StartAsNumeric(this)
            startDateAsNumeric = double(this.Start);
        end%
         

        function startAsDate = get.StartAsDate(this)
            startAsDate = this.Start;
            if ~isa(startAsDate, 'Date')
                startAsDate = Date(startAsDate);
            end
        end%
         

        function startAsDate = get.StartAsDateWrapper(this)
            startAsDate = this.StartAsDate;
        end%


        function value = get.BalancedStart(this)
            if isa(this.Start, "DateWrapper")
                outputFunction = @DateWrapper;
            else
                outputFunction = @double;
            end
            if isnan(this.Start) || isempty(this.Data)
                value = outputFunction(NaN);
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
            value = outputFunction(value);
        end%
                

        function endDate = get.End(this)
            if isnan(this.Start)
                endDate = this.Start;
                return
            end
            numRows = size(this.Data, 1);
            if isa(this.Start, 'DateWrapper')
                endDate = addTo(this.Start, numRows-1);
            else
                endDate = dater.plus(this.Start, numRows-1);
            end
        end%


        function endDateAsNumeric = get.EndAsNumeric(this)
            endDateAsNumeric = double(this.End);
        end%
         

        function endAsDate = get.EndAsDate(this)
            endAsDate = this.End;
            if ~isa(endAsDate, 'DateWrapper')
                endAsDate = DateWrapper(endAsDate);
            end
        end%
         

        function endAsDate = get.EndAsDateWrapper(this)
            endAsDate = this.EndAsDate;
        end%


        function value = get.BalancedEnd(this)
            if isa(this.Start, "DateWrapper")
                outputFunction = @DateWrapper;
            else
                outputFunction = @double;
            end
            if isnan(this.Start) || isempty(this.Data)
                value = outputFunction(NaN);
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
            value = outputFunction(value);
        end%
         

        function frequency = get.Frequency(this)
            frequency = DateWrapper.getFrequency(double(this.Start));
        end%


        function frequency = get.FrequencyAsNumeric(this)
            frequency = dater.getFrequency(double(this.Start));
        end%


        function frequency = getFrequency(this)
            frequency = dater.getFrequency(double(this.Start));
            frequency = Frequency.fromNumeric(frequency);
        end%


        function frequency = getFrequencyAsNumeric(this)
            frequency = dater.getFrequency(double(this.Start));
        end%


        function numericRange = getRangeAsNumeric(this)
            numericStart = double(this.Start);
            numericRange = dater.plus(double(this.Start), 0:size(this.Data, 1)-1);
            numericRange = reshape(numericRange, [ ], 1);
        end%


        function range = getRange(this)
            range = getRangeAsNumeric(this);
            if isa(this.Start, 'DateWrapper')
               range = DateWrapper(range);
            end 
        end%


        function range = get.Range(this)
            range = this.RangeAsNumeric;
            if isa(this.Start, 'DateWrapper')
               range = DateWrapper(range);
            end 
        end%


        function numericRange = get.RangeAsNumeric(this)
            numericStart = double(this.Start);
            numericRange = dater.plus(double(this.Start), 0:size(this.Data, 1)-1);
            numericRange = reshape(numericRange, [ ], 1);
        end%


        function range = get.RangeAsDate(this)
            range = this.RangeAsNumeric;
            range = DateWrapper(range);
        end%


        function range = get.RangeAsDateWrapper(this)
            range = this.RangeAsDate;
        end%


        function this = set.Comment(this, newValue)
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
                sizeOfData = size(this.Data);
                sizeOfNewComment = size(newValue);
                expectedSizeOfComment = [1, sizeOfData(2:end)];
                if isequal(sizeOfNewComment, expectedSizeOfComment)
                    thisValue = newValue;
                elseif isequal(sizeOfNewComment, [1, 1])
                    thisValue = repmat(newValue, expectedSizeOfComment);
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
        varargout = trim(varargin)
        varargout = resolveShift(varargin)
        varargout = resolveRange(varargin)
    end




    methods (Access=protected, Hidden)
        function startDate = startDateWhenEmpty(this, varargin)
            if isa(this.Start, 'DateWrapper')
                startDate = DateWrapper.NaD( );
            else
                startDate = NaN;
            end
        end%
    end




    methods
        varargout = checkFrequency(varargin)


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
            flag = dater.getFrequency(this.Start)==dater.getFrequency(dates) ...
                 | isnan(dates);
        end%


        function flag = validateFrequencyOrInf(this, dates)
            flag = isinf(dates) | validateFrequency(this, dates);
        end%


    end




    methods (Static)
        varargout = createDateAxisData(varargin)
    end




    methods (Static, Access=protected)
        varargout = trimRows(varargin)
    end
end

