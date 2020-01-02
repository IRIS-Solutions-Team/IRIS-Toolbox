function x = abbreviate(x, varargin)
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
% the `input` string, an `Ellipsis=` character (a single character) will be
% added in place of the last character.
%
%
% ## Options ##
%
%
% __`Ellipsis=@config`__ [ `@config` | numeric ]
% >
% A single character that will be added at the end of the `output` string
% to indicate that the `input` string has been abbreviated;
% `Ellipsis=@config` means that the ellipsis character will be determined
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
% -Copyright (c) 2007-2019 IRIS Solutions Team

%--------------------------------------------------------------------------

% -[IrisToolbox] for Macroeconomic Modeling
% -Copyright (c) 2007-2019 IRIS Solutions Team

% Invoke unit tests
%(
if nargin==1 && isequal(x, '--test')
    x = functiontests({
        @setupOnce
        @charTest
        @stringTest
    });
    x = reshape(x, [ ], 1);
    return
end
%)


persistent pp
if isempty(pp)
     pp = extend.InputParser('textual.abbreviate');
     addRequired(pp, 'inputString', @validate.string);
     addParameter(pp, 'MaxLength', 20, @(x) validate.roundScalar(x, [1, Inf]));
     addParameter(pp, 'Ellipsis', @config, @(x) isequal(x, @config) || (validate.string(x) && strlength(x)==1));
end
parse(pp, x, varargin{:});
opt = pp.Options;

%--------------------------------------------------------------------------

if strlength(x)<=opt.MaxLength
    return
end

ellipsis = opt.Ellipsis;
if isequal(ellipsis, @config)
    ellipsis = iris.get('Ellipsis');
end

x = extractBefore(x, opt.MaxLength);
if ischar(x)
    x = [x, char(ellipsis)];
else
    x = string(x) + string(ellipsis);
end

end%




%
% Unit Tests 
%
%(
function setupOnce(testCase)
end%


function charTest(testCase)
    act = textual.abbreviate('abcdefg', 'MaxLength=', 5);
    exp = ['abcd', char(iris.get('Ellipsis'))];
    assertEqual(testCase, act, exp);
end%


function stringTest(testCase)
    act = textual.abbreviate("abcdefg", "MaxLength=", 5);
    exp = "abcd" + string(iris.get("Ellipsis"));
    assertEqual(testCase, act, exp);
end%
%)
