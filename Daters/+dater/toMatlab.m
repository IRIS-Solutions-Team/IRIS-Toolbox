function datetimeObj = toMatlab(input, varargin)

freq = dater.getFrequency(input);
if ~all(freq(1)==freq(:))
    throw( exception.Base('DateWrapper:InvalidInputsIntoDatetime', 'error') )
end
datetimeObj = dater.matlabFromSerial(freq(1), dater.getSerial(input), varargin{:});

end%

