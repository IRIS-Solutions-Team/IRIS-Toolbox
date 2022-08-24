% getDataNoFrills  Get time series data for specified dates with no checks
%
% -[IrisToolbox] for Macroeconomic Modeling
% -Copyright (c) 2007-2022 [IrisToolbox] Solutions Team

function [data, inxWithinRange, posTimes, this] = getDataNoFrills(this, timeRef, varargin)

timeRef = reshape(double(timeRef), 1, []);

% Apply references in 2nd and higher dimensions
if ~isempty(varargin)
    this.Data = this.Data(:, varargin{:});
    this.Comment = this.Comment(:, varargin{:});
end
data = this.Data;

sizeData = size(data);
ndimsData = numel(sizeData);
numPeriods = sizeData(1);
missingValue = this.MissingValue;


%( return postTime
    serialTimes = floor(timeRef);
    freqTimes = round(100*(timeRef - serialTimes));

    thisStart = double(this.Start);
    serialStart = floor(thisStart);
    freqStart = round(100*(thisStart - serialStart));

    numTimes = numel(serialTimes);
    if numTimes==1 && isequal(serialTimes, Inf)
        % Inf
        posTimes = 1 : numPeriods;
    elseif numTimes==2 && isequal(serialTimes, [-Inf, Inf])
        % [-Inf, Inf]
        posTimes = 1 : numPeriods;
    elseif numTimes==2 && isequal(serialTimes(1), -Inf)
        % [-Inf, Date]
        if freqTimes(2)==freqStart
            % [-Inf, Date of valid frequency]
            posLast = round(serialTimes(2) - serialStart + 1);
            posTimes = 1 : posLast;
        else
            % [-Inf, Date of invalid frequency]
            posTimes = double.empty(1, 0);
        end
    elseif numTimes==2 && isequal(serialTimes(2), Inf)
        % [Date, Inf]
        if freqTimes(1)==freqStart
            % [Date of valid frequency, Inf]
            posFirst = round(serialTimes(1) - serialStart + 1);
            posTimes = posFirst : numPeriods;
        else
            % [Date of invalid frequency, Inf]
            posTimes = double.empty(1, 0);
        end
    else
        posTimes = round(serialTimes - serialStart + 1);
        inxValidFreq = freqTimes==freqStart;
        posTimes(~inxValidFreq) = NaN;
    end
%)


numTimes = numel(posTimes);
inxWithinRange = posTimes>=1 & posTimes<=numPeriods;

needsCreateOutputSeries = nargout>=4;

if needsCreateOutputSeries
    inxToKeep = false(1, numPeriods);
    inxToKeep(posTimes(inxWithinRange)) = true;
end

if all(inxWithinRange)
    % All time references are within time series range
    data = data(:, :);
    data = data(posTimes, :);
    if ndimsData>2
        data = reshape(data, [numTimes, sizeData(2:end)]);
    end
    if needsCreateOutputSeries
        createOutputSeries( );
    end
elseif ~any(inxWithinRange)
    % No time references are within time series range
    data = repmat(this.MissingValue, [numTimes, sizeData(2:end)]);
    if needsCreateOutputSeries
        this = emptyData(this);
    end
else
    % Some time references are within time series range, some not
    temp = data;
    data = repmat(this.MissingValue, [numTimes, sizeData(2:end)]);
    data(inxWithinRange, :) = temp(posTimes(inxWithinRange), :);
    if needsCreateOutputSeries
        createOutputSeries( );
    end
end

return

    function posTimes = hereGetPosTimes( )
        %(
        serialTimes = dater.getSerial(timeRef);
        serialTimes = transpose(serialTimes(:));
        freqTimes = dater.getFrequency(timeRef);
        freqTimes = transpose(freqTimes(:));
        thisStart = double(this.Start);
        serialStart = dater.getSerial(thisStart);
        freqStart = dater.getFrequency(thisStart);
        numTimes = numel(serialTimes);
        if numTimes==1 && isequal(serialTimes, Inf)
            % Inf
            posTimes = 1 : numPeriods;
        elseif numTimes==2 && isequal(serialTimes, [-Inf, Inf])
            % [-Inf, Inf]
            posTimes = 1 : numPeriods;
        elseif numTimes==2 && isequal(serialTimes(1), -Inf)
            % [-Inf, Date]
            if freqTimes(2)==freqStart
                % [-Inf, Date of valid frequency]
                posLast = round(serialTimes(2) - serialStart + 1);
                posTimes = 1 : posLast;
            else
                % [-Inf, Date of invalid frequency]
                posTimes = double.empty(1, 0);
            end
        elseif numTimes==2 && isequal(serialTimes(2), Inf)
            % [Date, Inf]
            if freqTimes(1)==freqStart
                % [Date of valid frequency, Inf]
                posFirst = round(serialTimes(1) - serialStart + 1);
                posTimes = posFirst : numPeriods;
            else
                % [Date of invalid frequency, Inf]
                posTimes = double.empty(1, 0);
            end
        else
            posTimes = round(serialTimes - serialStart + 1);
            inxValidFreq = freqTimes==freqStart;
            posTimes(~inxValidFreq) = NaN;
        end
        %)
    end%


    function createOutputSeries( )
        %(
        this.Data(~inxToKeep, :) = missingValue;
        this.Data = reshape(this.Data, sizeData);
        this = trim(this);
        %)
    end%
end%
