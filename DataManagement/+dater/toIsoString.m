function isoString = toIsoString(this, varargin)

this = double(this);

if isempty(this)
    isoString = string.empty(size(this));
    return
end

reshapeOutput = size(this);
isoString = repmat("", reshapeOutput);
freq = dater.getFrequency(this);
inxNaN = isnan(freq);
if all(inxNaN)
    return
end

freq(inxNaN) = [ ];
if ~Frequency.sameFrequency(freq)
    exception.error([
        "DateWrapper:ToIsoString"
        "Cannot convert dates of multiple date frequencies "
        "in one run of the function dater.toIsoString( )."
    ]);
end

freq = freq(1);
if freq==0
    isoString = string(double(this));
    return
end
[year, month, day] = dater.ymdFromSerial(freq, floor(this), varargin{:});
isoString(~inxNaN) = compose("%04g-%02g-%02g", [year(:), month(:), day(:)]);
isoString = reshape(isoString, reshapeOutput);

end%

