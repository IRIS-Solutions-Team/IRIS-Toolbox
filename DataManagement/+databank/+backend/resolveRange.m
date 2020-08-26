function [from, to] = resolveRange(inputDb, names, from, to)
% resolveRange  Resolve start and end dates from databank time series
%
% Backend [IrisToolbox] method
% No help provided

% -[IrisToolbox] for Macroeconomic Modeling
% -Copyright (c) 2007-2020 [IrisToolbox] Solutions Team

%-------------------------------------------------------------------------- 

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
    freq = @all;
    if ~isinf(from)
        freq = dater.getFrequency(from);
    elseif ~isinf(to)
        freq = dater.getFrequency(to);
    end
    range = databank.range(inputDb, "NameList=", names, "Frequency=", freq);
    if isempty(range)
        hereReportEmptyRange( );
    end
    if iscell(range)
        hereReportMultipleRange( );
    end
    range = double(range);
    from = range(1);
    to = range(end);
end

return

    function hereReportEmptyRange( )
        %(
        thisError = [
            "Databank:EmptyDatabankRange"
            "Cannot resolve the databank range because there are no non-empty time series "
            "of the relevant date frequency."
        ];
        throw(exception.Base(thisError, 'error'));
        %)
    end%

    function hereReportMultipleRange( )
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

