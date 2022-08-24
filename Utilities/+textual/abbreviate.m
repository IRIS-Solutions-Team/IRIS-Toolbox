% abbreviate  Abbreviate a long text string not to exceed a given number of characters
%{
% ## Syntax ##
%
%
%     output = function(input, ...)
%
%
% ## Input Arguments ##
%
%
% __`input`__ [ char | string ]
% >
% Input string that will be abbreviated.
%
%
% ## Output Arguments ##
%
%
% __`output`__ [ | ]
% >
% Output string that is no longer that `MaxLength=`; if abbreviated from
% the `input` string, an `Ellipsis` character (a single character) will be
% added in place of the last character.
%
%
% ## Options ##
%
%
% __`Ellipsis=char(8230)`__ [ `@auto` | numeric ]
% >
% A single character that will be added at the end of the `output` string
% to indicate that the `input` string has been abbreviated;
% `Ellipsis=@auto` means that the ellipsis character will be determined
% from `iris.get( )`. 
%
%
% __`MaxLength=20`__ [ numeric ]
% >
% Maximum length of the output string including possibly the ellipsis
% character (if the input string needs to be abbreviated).
%
%
% ## Description ##
%
%
% ## Example ##
%
%}

% -[IrisToolbox] for Macroeconomic Modeling
% -Copyright (c) 2007-2022 [IrisToolbox] Solutions Team

function x = abbreviate(x, varargin)

%( Input parser
persistent pp
if isempty(pp)
     pp = extend.InputParser('textual.abbreviate');
     addRequired(pp, 'inputString', @validate.stringScalar);

     addParameter(pp, 'MaxLength', 20, @(x) validate.roundScalar(x, 1, Inf));
     addParameter(pp, 'Ellipsis', char(8230), @(x) isequal(x, @auto) || (validate.stringScalar(x) && strlength(x)==1));
end
%)
opt = parse(pp, x, varargin{:});

inputClass = class(x);

x = join(splitlines(string(x)), " ");
if strlength(x)>opt.MaxLength
    x = extractBefore(x, opt.MaxLength) + string(opt.Ellipsis);
end

if all(strcmpi(inputClass, 'char'))
    x = char(x);
end

end%




%
% Unit Tests 
%
%{
##### SOURCE BEGIN #####
% saveAs=textual/abbreviateUnitTest.m

testCase = matlab.unittest.FunctionTestCase.fromFunction(@(x)x);


%% Test Char
    act = textual.abbreviate('abcdefg', 'MaxLength', 5);
    exp = ['abcd', char(8230)];
    assertEqual(testCase, act, exp);


%% Test String
    act = textual.abbreviate("abcdefg", "MaxLength", 5);
    exp = "abcd" + string(char(8230));
    assertEqual(testCase, act, exp);


%% Test Short String
    exp = "abcdefg";
    act = textual.abbreviate(exp);
    assertEqual(testCase, act, exp);

##### SOURCE END #####
%}
