function [outputDb, status, info] = data(seriesId, varargin)

[outputDb, status, info] = databank.fromFred.master("data", seriesId, varargin{:});

end%

