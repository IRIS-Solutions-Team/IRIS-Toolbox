function varargout = eval(d, varargin)

persistent parser
if isempty(parser)
    parser = extend.InputParser('databank/eval');
    parser.addRequired('Database', @isstruct);
    parser.addRequired('Expression', @(x) all(cellfun(@(y) ischar(y) || isa(y, 'string'), x)));
end

parse(parser, d, varargin);

%--------------------------------------------------------------------------

varargout = cell(size(varargin));
expressions = cellfun(@char, varargin, 'UniformOUtput', false);
expressions = preprocess(expressions);
expressions = strrep(expressions, '?.', 'd.');
varargout = cellfun(@(x) evalInDatabank(d, x), expressions, 'UniformOutput', false);

end%


function varargout = evalInDatabank(d, varargin)
    varargout{1} = eval(varargin{1});
end%


function expressions = preprocess(expressions)
    expressions = strtrim(expressions);
    expressions = regexprep(expressions, ';$', '');
    expressions = regexprep(expressions, '=[ ]*#', '=');
    expressions = regexprep(expressions, '=(.*)', '-($1)', 'once');
    expressions = regexprep(expressions, '(?<!\.)(\<[A-Za-z]\w*\>)(?!\()', '?.$0');
end%

