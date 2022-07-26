function datetimeObj = toMatlab(input, varargin)

freq = dater.getFrequency(input);
if ~all(freq(1)==freq(:))
    exception.error([
        "Dater"
        "All input dates must be the same date frequency."
    ]);
end
datetimeObj = dater.matlabFromSerial(freq(1), dater.getSerial(input), varargin{:});

end%

