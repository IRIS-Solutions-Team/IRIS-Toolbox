function varargout = eval(d, varargin)

persistent INPUT_PARSER
if isempty(INPUT_PARSER)
    INPUT_PARSER = extend.InputParser('databank/eval');
    INPUT_PARSER.addRequired('Database', @isstruct);
    INPUT_PARSER.addRequired('Expression', @(x) cellfun(@(y) ischar(y) || isstring(y), x));
end

INPUT_PARSER.parse(d, varargin);

%--------------------------------------------------------------------------

varargout = cell(size(varargin));
varargin = cellfun(@char, varargin, 'UniformOUtput', false);
varargin = regexprep(varargin, '(?<!\.)(\<[A-Za-z]\w*\>)(?!\()', '?.$0');
varargin = strrep(varargin, '?.', 'd.');
varargout = cellfun(@(x) evalInDatabank(d, x), varargin, 'UniformOutput', false);

end


function varargout = evalInDatabank(d, varargin)
varargout{1} = eval(varargin{1});
end

