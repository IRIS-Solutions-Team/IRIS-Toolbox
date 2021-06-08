% Type `web Model/fromString.md` to get help on this function
%
% -[IrisToolbox] for Macroeconomic Modeling
% -Copyright (c) 2007-2021 [IrisToolbox] Solutions Team

% >=R2019b
%{
function varargout = fromString(inputStrings, args)

arguments
    inputStrings (1, :) string {mustBeNonempty}
end

arguments (Repeating)
    args
end
%}
% >=R2019b


% <=R2019a
%(
function varargout = fromString(inputStrings, varargin)

args = varargin;
%)
% <=R2019a

inputModelFile = model.File();
inputModelFile.FileName = Model.FILE_NAME_WHEN_INPUT_STRING;
inputModelFile.Code = char(join(inputStrings, sprintf("\n\n")));
[varargout{1:nargout}] = Model(inputModelFile, args{:});

end%




%
% Unit tests
%
%{
##### SOURCE BEGIN #####
% saveAs=Model/fromStringUnitTest.m

testCase = matlab.unittest.FunctionTestCase.fromFunction(@(x)x);

%% Test plain vanilla

m = Model.fromString([
    "!variables"
    "    x"
    "!shocks"
    "    eps_x"
    "!parameters"
    "    rho_x"
    "!equations"
    "    x = rho_x*x{-1} + eps_x;"
]);

act = access(m, "equations");
exp = "x=rho_x*x{-1}+eps_x;";
assertEqual(testCase, act, exp);
assertEqual(testCase, access(m, "fileName"), Model.FILE_NAME_WHEN_INPUT_STRING);


%% Test options

m = Model.fromString([ "!variables"
    "    x"
    "!shocks"
    "    eps_x"
    "!parameters"
    "    rho_x"
    "!equations"
    "    x = rho_x*x{-1} + eps_x;"
], "linear", true);

act = access(m, "equations");
exp = "x=rho_x*x{-1}+eps_x;";
assertEqual(testCase, act, exp);
assertTrue(testCase, isLinear(m));

##### SOURCE END #####
%}

