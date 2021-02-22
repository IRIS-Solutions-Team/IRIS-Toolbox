% Type `web +databank/toCSV.md` for help on this function

% -[IrisToolbox] for Macroeconomic Modeling
% -Copyright (c) 2007-2020 [IrisToolbox] Solutions Team

function fieldsSaved = toCSV(inputDatabank, fileName, varargin);

%( Input parser
persistent parser
if isempty(parser)
    parser = extend.InputParser('+databank/toCSV');
    addRequired(parser, 'fileName', @validate.string);
end
%)
parse(parser, fileName);

[c, fieldsSaved] = databank.serialize(inputDatabank, varargin{:});
char2file(c, fileName);

end%

