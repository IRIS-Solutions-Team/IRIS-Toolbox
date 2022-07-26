function outputDate = str2dat(string, varargin)
    dateCode = numeric.str2dat(string, varargin{:});
    outputDate = Dater(dateCode);
end%

