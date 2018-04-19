function outputData = fromFred(varargin)

container = DatafeedContainer.fromFred(varargin{:});
outputData = export(container, struct( ), @DateWrapper.fromSerial, @tseries);

end
