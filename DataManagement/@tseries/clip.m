function [this, newStart, newEnd] = clip(this, newStart, newEnd)
% resize  Clip time series range
%
% __Syntax__
%
%     X = resize(X, NewStart, NewEnd)
%
%
% __Input Arguments__
%
% * `X` [ tseries ] - Input time series whose date range will be clipped.
%
% * `NewStart` [ DateWrapper | `-Inf` ] - New start date; `-Inf` means keep
% the current start date.
%
% * `NewEnd` [ DateWrapper | `Inf` ] - New end date; `Inf` means keep
% the current enddate.
%
%
% __Output Arguments__
%
% * `X` [ tseries ] - Output time series  with its date range clipped to
% the new range from `NewStart` to `NewEnd`.
%
%
% __Description__
%
%
% __Example__
%

% -IRIS Macroeconomic Modeling Toolbox
% -Copyright (c) 2007-2018 IRIS Solutions Team

persistent parser
if isempty(parser)
    parser = extend.InputParser([class(this), '.clip']);
    parser.addRequired('InputSeries', @(x) isa(x, 'tseries'));
    parser.addRequired('NewStart', @(x) DateWrapper.validateDateInput(x) && isscalar(x));
    parser.addRequired('NewEnd', @(x) DateWrapper.validateDateInput(x) && isscalar(x) && ~isequal(x, -Inf));
end
parser.parse(this, newStart, newEnd);

%--------------------------------------------------------------------------

isStartInf = isequal(newStart, -Inf) || isequal(newStart, Inf);
isEndInf = isequal(newEnd, Inf);
if isStartInf && isEndInf
    if nargout>1
        newStart = this.Start;
        newEnd = this.End;
    end
    return
end

serialXStart = round(this.Start);
serialXEnd = serialXStart + size(this.Data, 1) - 1;
freqOfX = DateWrapper.getFrequencyAsNumeric(this.Start);

serialNewStart = getSerialNewStart( );
serialNewEnd = getSerialNewEnd( );

% Return immediately the input time series if the new start is before the
% input start and the new end is after the input end
if serialNewStart<=serialXStart && serialNewEnd>=serialXEnd
    if nargout>1
        newStart = this.Start;
        newEnd = this.End;
    end
    return
end

% Return immediately an empty time series if the new start is after the new
% end
if serialNewStart>serialNewEnd
    this = this.empty(this);
    if nargout>1
        newStart = this.Start;
        newENd = this.End;
    end
    return
end

sizeOfData = size(this.Data);
ndimsOfData = ndims(this.Data);
if serialNewStart>serialXStart
    numRowsToRemove = serialNewStart - serialXStart;
    this.Data(1:numRowsToRemove, :) = [ ];
    this.Start = DateWrapper.fromSerial(freqOfX, serialNewStart);
end

if serialNewEnd<serialXEnd
    numRowsToRemove = serialXEnd - serialNewEnd;
    this.Data(end-numRowsToRemove+1:end, :) = [ ];
end

if ndimsOfData>2
    sizeOfData(1) = size(this.Data, 1);
    this.Data = reshape(this.Data, sizeOfData);
end

return


    function serialNewStart = getSerialNewStart( )
        if isStartInf
            serialNewStart = serialXStart;
        else
            freqOfNewStart = DateWrapper.getFrequencyAsNumeric(newStart);
            if freqOfNewStart~=freqOfX
                throw( exception.Base('Series:FrequencyMismatch', 'error'), ...
                       Frequency.toChar(freqOfX), Frequency.toChar(freqOfNewStart) );
            end
            serialNewStart = round(newStart);
        end
    end%


    function serialNewEnd = getSerialNewEnd( )
        if isEndInf
            serialNewEnd = serialXEnd;
        else
            freqOfNewEnd = DateWrapper.getFrequencyAsNumeric(newEnd);
            if freqOfNewEnd~=freqOfX
                throw( exception.Base('Series:FrequencyMismatch', 'error'), ...
                       Frequency.toChar(freqOfX), Frequency.toChar(freqOfNewEnd) );
            end
            serialNewEnd = round(newEnd);
        end
    end%
end%
