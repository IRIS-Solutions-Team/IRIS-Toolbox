function outputData = fromFred(varargin)

container = DatafeedContainer.fromFred(varargin{:});
outputData = export(container, struct( ), @Date.fromSerial, @TimeSeries);

end
