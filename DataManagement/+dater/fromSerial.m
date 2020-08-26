function dateCode = fromSerial(freq, serial)

freq = double(freq);
inxFreqCodes = freq~=0 & freq~=365;
freqCode = zeros(size(freq));
freqCode(inxFreqCodes) = double(freq(inxFreqCodes)) / 100;
dateCode = round(serial) + freqCode;

end%

