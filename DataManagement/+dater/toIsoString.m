function isoString = toIsoString(date, varargin)

date = double(date);

if isempty(date)
    isoString = string.empty(size(date));
    return
end

reshapeOutput = size(date);
isoString = repmat("", reshapeOutput);
freq = dater.getFrequency(date);
inxNaN = isnan(freq);
if all(inxNaN)
    return
end

freq(inxNaN) = [ ];
if ~Frequency.sameFrequency(freq)
    exception.error([
        "Dater"
        "Cannot convert date vectors with mixed date frequencies "
        "in one run of the function dater.toIsoString( )."
    ]);
end

freq = freq(1);
if freq==0
    isoString = string(double(date));
    return
end
[year, month, day] = dater.ymdFromSerial(freq, floor(date), varargin{:});
isoString(~inxNaN) = compose("%04g-%02g-%02g", [year(:), month(:), day(:)]);
isoString = reshape(isoString, reshapeOutput);

end%

