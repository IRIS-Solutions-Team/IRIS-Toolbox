function [outputDb, status, info] = vintages(seriesId, varargin)

[outputDb, status, info] = databank.fromFred.master("vintages", seriesId, varargin{:});

end%

