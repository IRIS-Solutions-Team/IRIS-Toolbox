function checkMixedFrequency(varargin)

if Frequency.sameFrequency(varargin{:})
    return
end

freq = reshape(varargin{1}, 1, [ ]);
if nargin>=2
    freq = [freq, reshape(varargin{2}, 1, [ ])];
end
if nargin>=3
    context = varargin{3};
else
    context = 'in this context';
end

exception.error([
    "Dates:MixedFrequency"
    "Dates with mixed date frequencies are not allowed %1: %s"
], string(context), Frequency.toString(unique(freq, 'stable')));

end%

