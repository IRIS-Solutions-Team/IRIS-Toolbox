function c = subsCase(this, timeReference)

start = this.Start;

if isequaln(timeReference, NaN)
    ref = 'NaD';
elseif isequal(class(start), class(timeReference))
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
        'TimeSubscriptable:subsCase:IllegalSubscript', ...
        'Illegal subscripted reference or assignment to %s object.', ...
        class(this) ...
    );
end

freq = DateWrapper.getFrequencyAsNumeric(start);
if isnan(freq)
    start = 'NaD';
elseif isempty(start)
    start = 'Empty';
else
    start = 'Date';
end

c = [start, '_', ref];

end
