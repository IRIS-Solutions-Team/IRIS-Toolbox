% Type `web Model/fromSnippet.md` to get help on this function
%
% -[IrisToolbox] for Macroeconomic Modeling
% -Copyright (c) 2007-2021 [IrisToolbox] Solutions Team

% >=R2019b
%(
function varargout = fromSnippet(snippetName, args)

arguments
    snippetName (1, :) string {mustBeNonempty}
end

arguments (Repeating)
    args
end
%)
% >=R2019b


% <=R2019a
%{
function varargout = fromSnippet(snippetName, varargin)

args = varargin;
%}
% <=R2019a


OPEN_SNIPPET = ">>>";
CLOSE_SNIPPET = "<<<";

stack = dbstack("-completenames");
callerFileName = stack(2).file;
callerCode = string(fileread(callerFileName));

inputModelFiles = model.File.empty(1, 0);
snippetName = reshape(strip(snippetName), 1, []);
for n = snippetName
    open = n + OPEN_SNIPPET;
    close =  CLOSE_SNIPPET + n;
    snippet = extractBetween(callerCode, "% " + open, "% " + close);
    snippet = regexprep(snippet, "^%", "", "lineAnchors");   
    if isempty(snippet)
        snippet = extractBetween(callerCode, open, close);
    end
    if ~isscalar(snippet)
        hereThrowError();
    end

    mf = model.File;
    mf.FileName = callerFileName + "#" + n;
    mf.Code = char(snippet);
    inputModelFiles(end+1) = mf;
end

[varargout{1:nargout}] = Model(mf, args{:});

return

    function hereThrowError()
        if isempty(snippet)
            exception.error([
                "Model:NoSnippetFound"
                "No snippet of code named %s found in %s"
            ], snippetName, callerFileName);
        else
            exception.error([
                "Model:NoSnippetFound"
                "Multiple snippets of code named %s found in %s"
            ], snippetName, callerFileName);
        end
    end%
end%




%
% Unit tests
%
%{
##### SOURCE BEGIN #####
% saveAs=Model/fromSnippetUnitTest.m

testCase = matlab.unittest.FunctionTestCase.fromFunction(@(x)x);

%% Test plain vanilla

m = Model.fromSnippet("test");
% test>>>
% !variables
%     x
% !shocks
%     eps_x
% !parameters
%     rho_x
% !equations
%     x = rho_x*x{-1} + eps_x;
% <<<test

act = access(m, "equations");
exp = "x=rho_x*x{-1}+eps_x;";
assertEqual(testCase, act, exp);

##### SOURCE END #####
%}

