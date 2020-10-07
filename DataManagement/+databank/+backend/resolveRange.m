% resolveRange  Resolve start and end dates from databank time series
%
% Backend [IrisToolbox] method
% No help provided

% -[IrisToolbox] for Macroeconomic Modeling
% -Copyright (c) 2007-2020 [IrisToolbox] Solutions Team

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
    freq = locallyDetermineAndVerifyFrequency(from, to);
    range = databank.range(inputDb, "nameList", names, "frequency", freq);
    if isempty(range)
        hereReportEmptyRange( );
    end
    if iscell(range)
        hereReportMultipleRange( );
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

%
% Local Functions
%

function freq = locallyDetermineAndVerifyFrequency(from, to)
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
end%




%
% Unit Tests
%
%{
##### SOURCE BEGIN #####
% saveAs=databank/resolveRangeUnitTest.m

testCase = matlab.unittest.FunctionTestCase.fromFunction(@(x)x);

% Set up Once
    d = struct( );
    d.a = Series(qq(2001,1):qq(2010,4), 1);
    d.b = Series(qq(2002,1):qq(2011,4), 1);
    d.c = Series(mm(2001,1), 1);


%% Test Names All Inf
    [from, to] = databank.backend.resolveRange(d, "a", -Inf, Inf);
    assertEqual(testCase, [from, to], [dater.qq(2001,1), dater.qq(2010,4)]);
    %
    [from, to] = databank.backend.resolveRange(d, ["a", "b"], -Inf, Inf);
    assertEqual(testCase, [from, to], [dater.qq(2001,1), dater.qq(2011,4)]);


%% Test Names Explicit Start
    [from, to] = databank.backend.resolveRange(d, ["a", "b"], qq(2005,1), Inf);
    assertEqual(testCase, [from, to], [dater.qq(2005,1), dater.qq(2011,4)]);


%% Test Names Explicit End
    [from, to] = databank.backend.resolveRange(d, ["a", "b"], -Inf, qq(2005,1));
    assertEqual(testCase, [from, to], [dater.qq(2001,1), dater.qq(2005,1)]);

##### SOURCE END #####
%}
