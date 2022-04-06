% Type `web Model/fromSnippet.md` to get help on this function
%
% -[IrisToolbox] for Macroeconomic Modeling
% -Copyright (c) 2007-2021 [IrisToolbox] Solutions Team

function varargout = fromSnippet(snippetNames, varargin)

[snippets, snippetNames, callerFileName] = textual.readSnippet(snippetNames);
source = ModelSource();
source.FileName = string(callerFileName) + "#" + snippetNames;
source.Code = char(join(snippets, ModelSource.CODE_SEPARATOR));
[varargout{1:nargout}] = Model(source, varargin{:});

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


%% Test options

m = Model.fromSnippet("linear", "linear", true);

% linear>>>
% !variables
%     x
% !shocks
%     eps_x
% !parameters
%     rho_x
% !equations
%     x = rho_x*x{-1} + eps_x;
% <<<linear

act = access(m, "equations");
exp = "x=rho_x*x{-1}+eps_x;";
assertEqual(testCase, act, exp);
assertTrue(testCase, isLinear(m));


%% Test multiple snippets

m = Model.fromSnippet(["test2", "test3"]);

% test2>>>
% !variables
%     x
% !shocks
%     eps_x
% !parameters
%     rho_x
% !equations
%     x = rho_x*x{-1} + eps_x;
% <<<test2

% test3>>>
% !variables
%     y
% !shocks
%     eps_y
% !parameters
%     rho_y
% !equations
%     y = rho_y*y{-1} + eps_y;
% <<<test3

act = access(m, "equations");
exp = ["x=rho_x*x{-1}+eps_x;", "y=rho_y*y{-1}+eps_y;"];
assertEqual(testCase, act, exp);

##### SOURCE END #####
%}

