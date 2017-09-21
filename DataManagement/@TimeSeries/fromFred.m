function outputData = fromFred(varargin)

container = DatafeedContainer.fromFred(varargin{:});
outputData = export(container, @Date.fromSerial, @TimeSeries);

end
