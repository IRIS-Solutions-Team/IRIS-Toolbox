function c = subsCase(start, timeReference)

if isa(timeReference, 'Date')
    if isequaln(timeReference, NaN) || isnad(timeReference)
        ref = 'NaD';
    else
        ref = 'Date';
    end
elseif isequal(timeReference, ':') || isequal(timeReference, Inf)
    ref = ':';
elseif isempty(timeReference)
    ref = '[]';
else
    error( ...
        'TimeSeries:subsCase', ...
        'Invalid subscripted reference or assignment to TimeSeries.' ...
    );
end

frequency = start.Frequency;
if isnaf(frequency)
    start = 'NaD';
elseif isempty(start)
    start = 'Empty';
else
    start = 'Date';
end

c = [start, '_', ref];

end
