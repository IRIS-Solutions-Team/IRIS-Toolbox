function code = grabTextFromCaller(tag, fileName)
% grabTextFromCaller  Retrieve block comment from calling m-file.
%
% Backend IRIS function.
% No help provided.

% -IRIS Macroeconomic Modeling Toolbox.
% -Copyright (c) 2007-2019 IRIS Solutions Team.

PATTERN = '%\{\n$tag$>>>>>\n(.*?)\n<<<<<$tag$\n%\}';

%--------------------------------------------------------------------------

code = '';

% Determine the name of the calling m-file.
stack = dbstack('-completenames');
if length(stack)<2
   return
end
filename = stack(2).file;

% Read the m-file and convert all end-of-lines to \n.
file = file2char(filename);
file = textfun.converteols(file);

% Find the following block comment
%{
TAG>>>>>
...
<<<<<TAG
%}

ptn = strrep(PATTERN, '$tag$', tag);
tkn = regexp(file, ptn, 'once', 'tokens');
if isempty(tkn)
    return
end
code = tkn{1};

if nargin>1
    char2file(code, fileName);
end

end
