% clip  Clip time series range
%{
% ## Syntax ##
%
%     outputSeries = clip(inputSeries, newStart, newEnd)
%
%
% ## Input Arguments ##
%
%
% __`inputSeries`__ [ TimeSubscriptable ]
% >
% Input time series whose date range will be clipped.
%
%
% __`newStart`__ [ DateWrapper | `-Inf` ]
% >
% New start date; `-Inf` means keep the current start date.
%
%
% __`newEnd`__ [ DateWrapper | `Inf` ]
% >
% New end date; `Inf` means keep the current enddate.
%
%
% ## Output Arguments ##
%
%
% __`outputSeries`__ [ TimeSubscriptable ]
% Output time series  with its date range clipped to the new range from
% `newStart` to `newEnd`.
%
%
% ## Description ##
%
%
%
% ## Example ##
%
%}

% -[IrisToolbox] for Macroeconomic Modeling
% -Copyright (c) 2007-2020 [IrisToolbox] Solutions Team

% >=R2019b
%(
function [this, newStart, newEnd] = clip(this, newStart, newEnd)

arguments
    this TimeSubscriptable
    newStart {validate.dateInput(newStart)}
    newEnd {validate.mustBeScalarOrEmpty, validate.dateInput(newEnd)} = []
end

newStart = double(newStart);
newEnd = double(newEnd);
if all(isinf(newStart)) && all(isinf(newEnd))
    return
end
%)
% >=R2019b

% <=R2019a
%{
function [this, newStart, newEnd] = clip(this, newStart, varargin)

%
% Fast track for `x = clip(x, Inf)`
%
if isempty(varargin) && nargout<2 && isequal(newStart, Inf)
    return
end

persistent pp
if isempty(pp)
    pp = extend.InputParser('TimeSubscriptable.clip');
    addRequired(pp, 'inputSeries', @(x) isa(x, 'TimeSubscriptable'));
    addRequired(pp, 'newStart', @(x) DateWrapper.validateDateInput(x));
    addOptional(pp, 'newEnd', [ ], @(x) isempty(x) || (DateWrapper.validateDateInput(x) && isscalar(x) && ~isequal(x, -Inf)));
end
parse(pp, this, newStart, varargin{:});
newStart = double(newStart);
newEnd = double(pp.Results.newEnd);
%}
% <=R2019a

if isempty(newEnd)
    newEnd = newStart(end);
end
newStart = newStart(1);

%--------------------------------------------------------------------------

if isa(this.Start, "DateWrapper")
    outputDateFunc = @DateWrapper;
else
    outputDateFunc = @double;
end

thisStart = double(this.Start);
if isnan(thisStart) && isempty(this.Data)
    newStart = outputDateFunc(thisStart);
    newEnd = newStart;
    return
end

if isequaln(newStart, NaN) || isequaln(newEnd, NaN)
    this = emptyData(this);
    newStart = outputDateFunc(newStart);
    newEnd = outputDateFunc(newEnd);
    return
end

thisEnd = dater.plus(thisStart, size(this.Data, 1)-1);
isStartInf = isequal(newStart, -Inf) || isequal(newStart, Inf);
isEndInf = isequal(newEnd, Inf);
if isStartInf && isEndInf
    if nargout>1
        newStart = outputDateFunc(thisStart);
        newEnd = outputDateFunc(thisEnd);
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
        newStart = outputDateFunc(thisStart);
        newEnd = outputDateFunc(thisEnd);
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
        newStart = outputDateFunc(thisStart);
        newENd = outputDateFunc(thisEnd);
    end
    return
end

sizeData = size(this.Data);
ndimsData = ndims(this.Data);
if serialNewStart>serialThisStart
    numRowsToRemove = round(serialNewStart - serialThisStart);
    this.Data(1:numRowsToRemove, :) = [ ];
    this.Start = outputDateFunc(dater.fromSerial(freqThis, serialNewStart));
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
