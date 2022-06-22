% resolveRange  Resolve start and end dates from databank time series
%
% Backend [IrisToolbox] method
% No help provided

% -[IrisToolbox] for Macroeconomic Modeling
% -Copyright (c) 2007-2022 [IrisToolbox] Solutions Team

function [from, to] = resolveRange(inputDb, names, from, to)

if nargin<2
    names = @all;
end

if nargin>=3
    from = double(from);
    from = from(1);
    if isinf(from)
        from = -Inf;
    end
else
    from = -Inf;
end

if nargin>=4
    to = double(to);
    to = to(end);
    if isinf(to)
        to = Inf;
    end
else
    to = Inf;
end
    
if isinf(from) || isinf(to)
    freq = local_determineAndVerifyFrequency(from, to);
    range = databank.range(inputDb, "sourceNames", names, "frequency", freq);
    if isempty(range)
        here_reportEmptyRange( );
    end
    if iscell(range)
        here_reportMultipleRange( );
    end
    range = double(range);
    if isinf(from)
        from = range(1);
    end
    if isinf(to)
        to = range(end);
    end
end

return

    function here_reportEmptyRange( )
        %(
        thisError = [
            "Databank:EmptyDatabankRange"
            "Cannot resolve the databank range because there are no non-empty time series "
            "of the relevant date frequency."
        ];
        throw(exception.Base(thisError, 'error'));
        %)
    end%

    function here_reportMultipleRange( )
        %(
        thisError = [
            "Databank:MultipleDatabankRangeFrequency"
            "Cannot resolve the databank range because there are time series "
            "of multiple date frequencies included in the databank."
        ];
        throw(exception.Base(thisError, 'error'));
        %)
    end%
end%

%
% Local functions
%

function freq = local_determineAndVerifyFrequency(from, to)
    %(
    freq = @all;
    freqFrom = [ ];
    freqTo = [ ];
    if ~isinf(from)
        freqFrom = dater.getFrequency(from);
    end
    if ~isinf(to)
        freqTo = dater.getFrequency(to);
    end
    if ~isempty(freqFrom) && ~isempty(freqTo) && ~isequal(freqFrom, freqTo)
        exception.error([
            "Databank:FrequencyMismatch"
            "Frequency mismatch in the input data range: %s x %s"
        ], Frequency.fromNumeric(freqFrom), Frequency.fromNumeric(freqTo));
    end
    if ~isempty(freqFrom)
        freq = freqFrom;
    elseif ~isempty(freqTo)
        freq = freqTo;
    end
    %)
end%

