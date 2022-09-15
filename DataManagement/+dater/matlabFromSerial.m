function datetimeObj = matlabFromSerial(freq, serial, varargin)

freq = double(freq);
serial = double(serial);

if isequaln(freq, NaN)
    datetimeObj = NaT(size(serial));
    return
end

year = zeros(size(serial));
month = zeros(size(serial));
day = zeros(size(serial));
inxInf = isinf(serial);
[year(~inxInf), month(~inxInf), day(~inxInf)] = dater.ymdFromSerial(freq, serial(~inxInf), varargin{:});

if freq==double(Frequency.WEEKLY)
    day(~inxInf) = day(~inxInf) - 3; % Return Monday, not Thursday, for display
end

year(inxInf) = serial(inxInf);
datetimeObj = datetime(year, month, day, 'Format', dater.getFormatForMatlab(freq));

end%

