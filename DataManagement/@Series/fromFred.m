function outputData = fromFred(varargin)

container = DatafeedContainer.fromFred(varargin{:});
outputData = export(container, @DateWrapper.fromSerial, @Series);

end
