function args = splitArguments(text) 
% splitArguments  Split text into input arguments
%
% Backend IRIS function
% No help provided

% -IRIS Macroeconomic Modeling Toolbox
% -Copyright (c) 2007-2020 IRIS Solutions Team

persistent INPUT_PARSER
if isempty(INPUT_PARSER)
    INPUT_PARSER = extend.InputParser('textual.splitArguments');
    INPUT_PARSER.addRequired('Text', @(x) ischar(x) && isvector(x) && ~isempty(x) && x(1)=='(' && x(end)==')');
end
INPUT_PARSER.parse(text);

%--------------------------------------------------------------------------

level = zeros(size(text), 'int64');
level(text=='(' | text=='[' | text=='{') = 1;
level(text==')' | text==']' | text=='}') = -1;
level = cumsum(level);

assert( ...
    level(end)==0, ...
    'textual:splitArguments', ...
    'Unmatched bracket in input expression.' ...
);

indexDelimiters = level==1 & text==',';
numDelimiters = nnz(indexDelimiters);
args = cell(1, numDelimiters+1);
pos = [1, find(indexDelimiters), length(text)];
for i = 1 : length(pos)-1
    range = pos(i)+1 : pos(i+1)-1;
    args{i} = text(range);
end

end
