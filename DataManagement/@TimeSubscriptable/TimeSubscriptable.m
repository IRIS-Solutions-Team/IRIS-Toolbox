classdef (Abstract, InferiorClasses={?matlab.graphics.axis.Axes}) ...
         TimeSubscriptable
    properties 
        % Start  Date of first observation in time series
        Start (1, 1) = NaN

        % Comment  User comments attached to individual columns of time series
        Comment string = "" 
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
    end


    properties (Abstract, Dependent)
        MissingTest
    end


    properties (Constant)
        StartDateWhenEmpty = NaN 
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
        varargout = resolveRange(varargin)
        varargout = retrieveColumns(varargin)
        varargout = setData(varargin)
        varargout = shift(varargin)


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
        varargout = trim(varargin)
        varargout = resolveShift(varargin)
    end


    methods
        varargout = checkFrequency(varargin)


        function this = emptyData(this)
            if isnan(this.Start) || size(this.Data, 1)==0
                return
            end
            sizeData = size(this.Data);
            newSizeData = [0, sizeData(2:end)];
            this.Start = TimeSubscriptable.StartDateWhenEmpty;
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




    methods (Static)
        varargout = createDateAxisData(varargin)
    end




    methods (Static, Access=protected)
        varargout = trimRows(varargin)
    end
end

