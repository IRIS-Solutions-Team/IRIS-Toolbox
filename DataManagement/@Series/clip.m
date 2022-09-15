
% >=R2019b
%{
function [this, newStart, newEnd] = clip(this, newStart, newEnd)

arguments
    this Series
    newStart {validate.mustBeDate(newStart)}

    newEnd {validate.mustBeScalarOrEmpty, validate.mustBeDate(newEnd)} = []
end
%}
% >=R2019b


% <=R2019a
%(
function [this, newStart, newEnd] = clip(this, newStart, varargin)

persistent ip
if isempty(ip)
    ip = inputParser();
    addOptional(ip, "newEnd", [], @(x) isempty(x) || isnumeric(x));
end
parse(ip, varargin{:});
newEnd = ip.Results.newEnd;
%)
% <=R2019a


    newStart = double(newStart);
    newEnd = double(newEnd);

    if all(isinf(newStart)) && (isempty(newEnd) || all(isinf(newEnd)))
        return
    end

    if isempty(newEnd)
        newEnd = newStart(end);
    end
    newStart = newStart(1);

    thisStart = double(this.Start);
    thisEnd = this.EndAsNumeric;

    if isnan(thisStart) && isempty(this.Data)
        newStart = NaN;
        newEnd = NaN;
        return
    end

    if isequaln(newStart, NaN) || isequaln(newEnd, NaN)
        this = emptyData(this);
        newStart = NaN;
        newEnd = NaN;
        return
    end

    isStartInf = isequal(newStart, -Inf) || isequal(newStart, Inf);
    isEndInf = isequal(newEnd, Inf);
    if isStartInf && isEndInf
        if nargout>1
            thisEnd = dater.plus(thisStart, size(this.Data, 1)-1);
            newStart = thisStart;
            newEnd = thisEnd;
        end
        return
    end

    serialThisStart = floor(thisStart);
    serialThisEnd = floor(thisEnd);
    freqThis = dater.getFrequency(thisStart);

    serialNewStart = getSerialNewStart( );
    serialNewEnd = getSerialNewEnd( );

    % Return immediately the input time series if the new start is before the
    % input start and the new end is after the input end
    if serialNewStart<=serialThisStart && serialNewEnd>=serialThisEnd
        if nargout>1
            newStart = thisStart;
            newEnd = thisEnd;
        end
        return
    end

    % Return immediately an empty time series if 
    % * the new start is after the new end
    % * both the new start and end are before the start of the series
    % * both the new start and end are after the end of the series
    if serialNewStart>serialNewEnd ...
       || (serialNewStart<serialThisStart && serialNewEnd<serialThisStart) ...
       || (serialNewStart>serialThisEnd && serialNewEnd>serialThisEnd)
        this = this.empty(this);
        if nargout>1
            newStart = thisStart;
            newEnd = thisEnd;
        end
        return
    end

    sizeData = size(this.Data);
    ndimsData = ndims(this.Data);
    if serialNewStart>serialThisStart
        numRowsToRemove = round(serialNewStart - serialThisStart);
        this.Data(1:numRowsToRemove, :) = [ ];
        this.Start = dater.fromSerial(freqThis, serialNewStart);
    end

    if serialNewEnd<serialThisEnd
        numRowsToRemove = round(serialThisEnd - serialNewEnd);
        this.Data(end-numRowsToRemove+1:end, :) = [ ];
    end

    if ndimsData>2
        sizeData(1) = size(this.Data, 1);
        this.Data = reshape(this.Data, sizeData);
    end

    this = trim(this);

return

    function serialNewStart = getSerialNewStart( )
        if isStartInf
            serialNewStart = serialThisStart;
        else
            freqNewStart = dater.getFrequency(newStart);
            if freqNewStart~=freqThis
                throw( exception.Base('Series:FrequencyMismatch', 'error'), ...
                       Frequency.toChar(freqThis), Frequency.toChar(freqNewStart) );
            end
            serialNewStart = floor(newStart);
        end
    end%


    function serialNewEnd = getSerialNewEnd( )
        if isEndInf
            serialNewEnd = serialThisEnd;
        else
            freqNewEnd = dater.getFrequency(newEnd);
            if freqNewEnd~=freqThis
                throw( exception.Base('Series:FrequencyMismatch', 'error'), ...
                       Frequency.toChar(freqThis), Frequency.toChar(freqNewEnd) );
            end
            serialNewEnd = floor(newEnd);
        end
    end%
end%

