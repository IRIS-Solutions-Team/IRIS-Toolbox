function c = subsCase(this, timeRef)

ERROR_INVALID_SUBSCRIPT = { 'TimeSubscriptable:subsCase:IllegalSubscript'
                            'Illegal subscripted reference or assignment to %s object' };

%--------------------------------------------------------------------------

start = this.Start;

if isequaln(timeRef, NaN)
    ref = 'NaD';
elseif isempty(timeRef)
    ref = '[]';
elseif isequal(timeRef, ':') || isequal(timeRef, Inf)
    ref = ':';
elseif isnumeric(timeRef)
    ref = 'Date';
else
    throw( exception.Base(ERROR_INVALID_SUBSCRIPT, 'error'), ...
           class(this) );
end

freq = DateWrapper.getFrequencyAsNumeric(start);
if isnan(freq) || isempty(start)
    start = 'NaD';
else
    start = 'Date';
end

c = [start, '_', ref];

end%
