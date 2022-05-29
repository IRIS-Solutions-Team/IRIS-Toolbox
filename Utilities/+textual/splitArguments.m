% splitArguments  Split text into input arguments
%
% Backend IRIS function
% No help provided

% -IRIS Macroeconomic Modeling Toolbox
% -Copyright (c) 2007-2022 IRIS Solutions Team

function args = splitArguments(text)

%--------------------------------------------------------------------------

convertToString = isstring(text);
text = char(text);
level = zeros(size(text));
level(text=='(' | text=='[' | text=='{') = 1;
level(text==')' | text==']' | text=='}') = -1;
level = cumsum(level);

if level(end)~=0
    exception.error([
        "SplitArguments:UnmatchedBracket"
        "Unmatched parentheses or brackets in this expression: %s "
    ], text);
end

inxDelims = level==0 & text==',';
numDelimiters = nnz(inxDelims);
args = cell(1, numDelimiters+1);
pos = [0, find(inxDelims), numel(text)+1];
for i = 1 : numel(pos)-1
    range = pos(i)+1 : pos(i+1)-1;
    args{i} = text(range);
end

if convertToString
    args = string(args);
end

end%

