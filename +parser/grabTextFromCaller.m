function code = grabTextFromCaller(tag, outputFileName)
% grabTextFromCaller  Retrieve block comment from calling m-file
%
% Backend IRIS function
% No help provided

% -IRIS Macroeconomic Modeling Toolbox
% -Copyright (c) 2007-2022 IRIS Solutions Team

PATTERN = '%\{\n$tag$>>>>>\n(.*?)\n<<<<<$tag$\n%\}';

%--------------------------------------------------------------------------

code = '';

% Determine the name of the calling m-file.
stack = exception.Base.getStack( );
if length(stack)<2
   return
end
inputFileName = stack(2).file;

% Read the m-file and convert all end-of-lines to \n.
file = file2char(inputFileName);
file = textual.convertEndOfLines(file);

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
    textual.write(code, outputFileName);
end

end%

