function outputData = fromFred(varargin)

container = DatafeedContainer.fromFred(varargin{:});
outputData = export(container, @Date.fromSerial, @(varargin) TimeSeries(varargin{1:2}, 'ColumnNames=', varargin{3}, 'UserData=', varargin{4}));

end
