function varargout = eval(d, varargin)

persistent parser
if isempty(parser)
    parser = extend.InputParser('databank/eval');
    parser.addRequired('Database', @isstruct);
    parser.addRequired('Expression', @(x) cellfun(@(y) ischar(y) || isa(y, 'string'), x));
end

parser.parse(d, varargin);

%--------------------------------------------------------------------------

varargout = cell(size(varargin));
varargin = cellfun(@char, varargin, 'UniformOUtput', false);
varargin = regexprep(varargin, '(?<!\.)(\<[A-Za-z]\w*\>)(?!\()', '?.$0');
varargin = strrep(varargin, '?.', 'd.');
varargout = cellfun(@(x) evalInDatabank(d, x), varargin, 'UniformOutput', false);

end%


function varargout = evalInDatabank(d, varargin)
    varargout{1} = eval(varargin{1});
end%

