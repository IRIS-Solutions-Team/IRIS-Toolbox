function [data, inxWithinRange, posOfTimes, this] = getDataNoFrills(this, timeRef, varargin)
% getDataNoFrills  Get time series data for specified dates with no checks
%
% Backend IRIS function
% No help provided

% -IRIS Macroeconomic Modeling Toolbox
% -Copyright (c) 2007-2020 IRIS Solutions Team

%--------------------------------------------------------------------------

% Apply references in 2nd and higher dimensions
if ~isempty(varargin)
    this.Data = this.Data(:, varargin{:});
    this.Comment = this.Comment(:, varargin{:});
end
data = this.Data;

sizeOfData = size(data);
ndimsOfData = numel(sizeOfData);
numOfPeriods = sizeOfData(1);
missingValue = this.MissingValue;

posOfTimes = getPosOfTimes( );
numOfTimes = numel(posOfTimes);
inxWithinRange = posOfTimes>=1 & posOfTimes<=numOfPeriods;

if nargout>3
    inxToKeep = false(1, numOfPeriods);
    inxToKeep(posOfTimes(inxWithinRange)) = true;
end

if all(inxWithinRange)
    % All time references are within time series range
    data = data(:, :);
    data = data(posOfTimes, :);
    if ndimsOfData>2
        data = reshape(data, [numOfTimes, sizeOfData(2:end)]);
    end
    if nargout>3
        createOutputSeries( );
    end
elseif ~any(inxWithinRange)
    % No time references are within time series range
    data = repmat(this.MissingValue, [numOfTimes, sizeOfData(2:end)]);
    if nargout>3
        this = emptyData(this);
    end
else
    % Some time references are within time series range, some not
    temp = data;
    data = repmat(this.MissingValue, [numOfTimes, sizeOfData(2:end)]);
    data(inxWithinRange, :) = temp(posOfTimes(inxWithinRange), :);
    if nargout>=4
        createOutputSeries( );
    end
end

return


    function posOfTimes = getPosOfTimes( )
        serialOfTimes = DateWrapper.getSerial(timeRef);
        serialOfTimes = transpose(serialOfTimes(:));
        freqOfTimes = DateWrapper.getFrequencyAsNumeric(timeRef);
        freqOfTimes = transpose(freqOfTimes(:));
        serialOfStart = DateWrapper.getSerial(this.Start);
        freqOfStart = DateWrapper.getFrequencyAsNumeric(this.Start);
        numOfTimes = numel(serialOfTimes);
        if numOfTimes==1 && isequal(serialOfTimes, Inf)
            % Inf
            posOfTimes = 1 : numOfPeriods;
            return
        end
        if numOfTimes==2 && isequal(serialOfTimes, [-Inf, Inf])
            % [-Inf, Inf]
            posOfTimes = 1 : numOfPeriods;
            return
        end
        if numOfTimes==2 && isequal(serialOfTimes(1), -Inf)
            % [-Inf, Date]
            if freqOfTimes(2)==freqOfStart
                % [-Inf, Date of valid frequency]
                posOfLast = round(serialOfTimes(2) - serialOfStart + 1);
                posOfTimes = 1 : posOfLast;
                return
            else
                % [-Inf, Date of invalid frequency]
                posOfTimes = double.empty(1, 0);
                return
            end
        end
        if numOfTimes==2 && isequal(serialOfTimes(2), Inf)
            % [Date, Inf]
            if freqOfTimes(1)==freqOfStart
                % [Date of valid frequency, Inf]
                posOfFirst = round(serialOfTimes(1) - serialOfStart + 1);
                posOfTimes = posOfFirst : numOfPeriods;
                return
            else
                % [Date of invalid frequency, Inf]
                posOfTimes = double.empty(1, 0);
                return
            end
        end
        posOfTimes = round(serialOfTimes - serialOfStart + 1);
        inxOfValidFreq = freqOfTimes==freqOfStart;
        posOfTimes(~inxOfValidFreq) = NaN;
    end%


    function createOutputSeries( )
        this.Data(~inxToKeep, :) = missingValue;
        this.Data = reshape(this.Data, sizeOfData);
        this = trim(this);
    end%
end%
