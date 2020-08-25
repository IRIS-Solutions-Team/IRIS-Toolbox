classdef (Abstract, InferiorClasses={?matlab.graphics.axis.Axes}) ...
         TimeSubscriptable

    properties 
        % Start  Date of first observation in time series
        Start = DateWrapper.NaD

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
        varargout = checkDataClass(varargin)
        varargout = createDataFromFunction(varargin)
        varargout = resetMissingValue(varargin)
    end




    methods (Access=protected)
        varargout = resolveRange(varargin)
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
            frequency = dater.getFrequency(double(this.Start));
        end%


        function frequency = getFrequency(this)
            frequency = DateWrapper.getFrequency(double(this.Start));
        end%


        function frequency = getFrequencyAsNumeric(this)
            frequency = dater.getFrequency(double(this.Start));
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


        function range = get.RangeAsDateWrapper(this)
            range = this.RangeAsNumeric;
            range = DateWrapper(range);
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

