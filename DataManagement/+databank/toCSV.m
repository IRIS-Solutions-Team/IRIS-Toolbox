function fieldsSaved = toCSV(inputDatabank, fileName, varargin)

%( Input parser
persistent parser
if isempty(parser)
    parser = extend.InputParser('+databank/toCSV');
    addRequired(parser, 'fileName', @validate.string);
end
%)
parse(parser, fileName);

[c, fieldsSaved] = databank.serialize(inputDatabank, varargin{:});
textual.write(c, fileName);

end%

