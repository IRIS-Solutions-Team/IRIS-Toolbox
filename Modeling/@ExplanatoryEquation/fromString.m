function varargout = fromString(inputString, varargin)
% fromString  Create ExplanatoryEquation object from string
%{
% ## Syntax ##
%
%
%     this = function(inputString, ...)
%
%
% ## Input Arguments ##
%
%
% __`inputString`__ [ string ]
% >
% Input string, or an array of strings, that will be converted to
% ExplanatoryEquation object or array.
%
%
% ## Output Arguments ##
%
%
% __`this`__ [ ExplanatoryEquation ]
% >
% New ExplanatoryEquation object or array created from the `inputString`.
%
%
% ## Options ##
%
%
% __`EnforceCase=[ ]`__ [ empty | `@lower` | `@upper` ]
% >
% Force the variable names, residual names and fitted names to be all
% lowercase or uppercase.
%
%
% __`ResidualNamePattern=["res_", ""]`__ [ string ]
% >
% A two-element string array with the prefix and the suffix used to create
% the name for residuals, based on the LHS variable name.
%
%
% __`FittedNamePattern=["fit_", ""]`__ [ string ]
% >
% A two-element string array with the prefix and the suffix used to create
% the name for fitted values, based on the LHS variable name.
%
%
% ## Description ##
%
%
% ## Example ##
%
%
% Create an array of three ExplanatoryEquation objects, with `x`, `y`, and
% `z` being the LHS variables:
%
%     q = ExplanatoryEquation.fromString([
%         "x = 0.8*x{-1} + z"
%         "diff(y) = 2*x + a + b"
%         "z = 0.5*z{-1} + 0.3*z{-2}
%     ]);
%}

% -[IrisToolbox] for Macroeconomic Modeling
% -Copyright (c) 2007-2019 IRIS Solutions Team

%--------------------------------------------------------------------------

% -[IrisToolbox] for Macroeconomic Modeling
% -Copyright (c) 2007-2020 IRIS Solutions Team

% Invoke unit tests
%(
if nargin==1 && isequal(inputString, '--test')
    varargout{1} = unitTests( );
    return
end
%)


persistent pp
if isempty(pp)
    pp = extend.InputParser('ExplanatoryEquation.fromString');
    addRequired(pp, 'inputString', @validate.list);
    addParameter(pp, 'EnforceCase', [ ], @(x) isempty(x) || isequal(x, @upper) || isequal(x, @lower));
    addParameter(pp, 'ResidualNamePattern', @default, @(x) isequal(x, @default) || ((isstring(x) || iscellstr(x)) && numel(x)==2));
    addParameter(pp, 'FittedNamePattern', @default, @(x) isequal(x, @default) || ((isstring(x) || iscellstr(x)) && numel(x)==2));
    addParameter(pp, 'DateReference', @default, @(x) isequal(x, @default) || validate.stringScalar(x));
end
parse(pp, inputString, varargin{:});
opt = pp.Options;

%--------------------------------------------------------------------------

inputString = string(inputString);
numEquations = numel(inputString);
array = cell(1, numEquations);

numEmpty = 0;
inputString = strtrim(inputString);

for j = 1 : numel(inputString)
    inputString__ = inputString(j);
    [inputString__, attributes__] = ExplanatoryEquation.extractAttributes(inputString__);
    [inputString__, label__] = ExplanatoryEquation.extractLabel(inputString__);

    inputString__ = regexprep(inputString__, "\s+", "");
    if inputString__=="" || inputString__==";"
        numEmpty = numEmpty + 1;
        continue
    end

    %
    % Create a new ExplanatoryEquation object, assign ResidualNamePattern
    % and FittedNamePattern, and enforce lower or upper case on
    % ResidualNamePattern and FittedNamePattern if requested
    %
    this__ = hereCreateObject( );

    %
    % Collect all variables names from the input string, enforcing lower or
    % upper case if requested
    %
    this__.VariableNames = hereCollectAllVariableNames( );

    this__.InputString = hereComposeUserInputString(inputString__, label__, attributes__);

    %
    % Split the input equation string into LHS and RHS using the first
    % equal sign found; there may be more than one equal sign such as == in
    % if( )
    %
    split__ = split(inputString__, "=");
    if numel(split__)<2
        hereThrowInvalidInputString( );
    end
    lhsString = split__(1);
    rhsString = join(split__(2:end), "=");

    if lhsString==""
        hereThrowEmptyLhs( );
    end
    if rhsString==""
        hereThrowEmptyRhs( );
    end

    %
    % Populate the ExplanatoryEquation object
    %
    this__ = defineDependent(this__, lhsString);
    hereParseExplanatory( );
    this__.Label = label__;
    this__.Attributes = attributes__;
    array{j} = this__;
end

if numEmpty>0
    hereWarnEmptyEquations( );
end

this = [array{:}];


%<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<
varargout{1} = reshape(this, [ ], 1);
%<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<

return


    function obj = hereCreateObject( )
        obj = ExplanatoryEquation( );
        if ~isequal(opt.ResidualNamePattern, @default)
            obj.ResidualNamePattern = string(opt.ResidualNamePattern);
        end
        if ~isequal(opt.FittedNamePattern, @default)
            obj.FittedNamePattern = string(opt.FittedNamePattern);
        end
        if ~isequal(opt.DateReference, @default)
            obj.DateReference = string(opt.DateReference);
        end
        if ~isempty(opt.EnforceCase)
            obj.ResidualNamePattern = opt.EnforceCase(obj.ResidualNamePattern);
            obj.FittedNamePattern = opt.EnforceCase(obj.FittedNamePattern);
            obj.DateReference = opt.EnforceCase(obj.DateReference);
        end
    end%




    function variableNames = hereCollectAllVariableNames( )
        if isempty(opt.EnforceCase)
            variableNames = regexp(inputString__, ExplanatoryEquation.VARIABLE_NO_SHIFT, 'match');
        else
            variableNames = string.empty(1, 0);
            enforceCaseFunc = opt.EnforceCase;
            replaceFunc = @hereEnforceCase;
            inputString__ = regexprep(inputString__, ExplanatoryEquation.VARIABLE_NO_SHIFT, '${replaceFunc($0)}');
        end

        %
        % Collect unique names of all variables
        %
        variableNames = unique(string(variableNames), 'stable');

        %
        % Remove DateReference from the list of variables
        %
        variableNames(variableNames==this__.DateReference) = [ ];

        return
            function c = hereEnforceCase(c)
                c = enforceCaseFunc(c);
                variableNames(end+1) = c;
            end%
    end% 




    function hereParseExplanatory( )
        %
        % Legacy syntax for free parameters
        %
        rhsString = replace(rhsString, "?", "@");

        rhsString = char(rhsString);
        if rhsString(end)==';'
            rhsString(end) = '';
        end
        %
        % Add an implicit plus sign if RHS starts with an @ to make the
        % start of all regression terms of one of the following forms: +@
        % or -@ 
        %
        if rhsString(1)=='@'
            rhsString = ['+', rhsString];
        end

        %
        % Find all characters outside any brackets (round, curly, square);
        % these characters will have level==0
        %
        [level, allClosed] = textual.bracketLevel(rhsString, {'()', '{}', '[]'});

        %
        % Find the starts of all regression terms
        %
        posStart = sort([strfind(rhsString, '+@'), strfind(rhsString, '-@')]);

        %
        % Collect all regression terms first and see what's left afterwards
        %
        numTerms = numel(posStart);
        termStrings = repmat("", 1, numTerms);
        fixed = nan(1, numTerms);
        for ii = 1 : numTerms
            ithPosStart = posStart(ii);
            after = false(size(rhsString));
            after(ithPosStart+1:end) = true;
            %
            % Find the end of the current regression term; the end is
            % either a plus or minus sign outside brackets, or the end of
            % the string
            %
            ithPosEnd = find((rhsString=='+' | rhsString=='-') & level==0 & after, 1);
            if ~isempty(ithPosEnd)
                ithPosEnd = ithPosEnd - 1;
            else
                ithPosEnd = numel(rhsString);
            end
            temp = [rhsString(ithPosStart), rhsString(ithPosStart+3:ithPosEnd)];
            temp = strrep(temp, ' ', '');

            %
            % if the term string consists only of a plus or minus sign, it
            % is a regressin constant, e.g. +@ or -@; make it a valid
            % expression by creating a +1 or -1 string
            %
            if numel(temp)==1
                temp = [temp, '1'];
            end
            if strncmp(temp, '+', 1)
                temp(1) = '';
            end
            termStrings(ii) = string(temp);
            rhsString(ithPosStart:ithPosEnd) = ' ';
        end

        %
        % Add a fixed term (lump sum) if there is anything left
        %
        rhsString = regexprep(rhsString, '\s+', '');
        if strncmp(rhsString, '+', 1)
            rhsString(1) = '';
        end
        if ~isempty(rhsString)
            termStrings(end+1) = string(rhsString);
            fixed(end+1) = true;
        end
        termStrings = strtrim(termStrings);

        % 
        % Create an explanatory term for each regression term and for the
        % fixed lump-sum term
        %
        for ii = 1 : numel(termStrings)
            this__ = addExplanatory(this__, termStrings(ii), 'Fixed=', fixed(ii));
        end
    end%




    function hereThrowInvalidInputString( )
        thisError = [ 
            "ExplanatoryEquation:InvalidInputString"
            "Invalid input string to define ExplanatoryEquation: %s" 
        ];
        throw(exception.Base(thisError, 'error'), this__.InputString);
    end%




    function hereThrowEmptyLhs( )
        thisError = [ 
            "ExplanatoryEquation:EmptyLhs"
            "This ExplanatoryEquation specification has an empty LHS: %s " 
        ];
        throw(exception.Base(thisError, 'error'), this__.InputString);
    end%




    function hereThrowEmptyRhs( )
        thisError = [ 
            "ExplanatoryEquation:EmptyRhs"
            "This ExplanatoryEquation specification has an empty RHS: %s" 
        ];
        throw(exception.Base(thisError, 'error'), this__.InputString);
    end%




    function hereWarnEmptyEquations( )
        thisWarning = [ 
            "ExplanatoryEquation:EmptyEquations"
            "A total number of %g empty equation(s) excluded from the input string."
        ];
        throw(exception.Base(thisWarning, 'warning'), numEmpty);
    end%

end%


%
% Local Functions
%


function userInputString = hereComposeUserInputString(inputString__, label, attributes)
    userInputString = inputString__;
    %{
    if label~=""
        userInputString = """" + label + """ " + userInputString;
    end
    if ~isempty(attributes)
        userInputString = join(attributes) + " " + userInputString;
    end
    %}
    if ~endsWith(userInputString, ";")
        userInputString = userInputString + ";";
    end
end%




%
% Unit Tests
%
%(
function tests = unitTests( )
    tests = functiontests({
        @fromStringTest
        @fromStringExogenousTest
        @fromLegacyStringTest
        @sumTest
        @sumExogenousTest
        @lowerTest
        @upperTest
        @ifStaticTest
        @ifDynamicTest
        @compareDynamicStaticTest
        @switchVariableTest
        @residualNameTest
        @fittedNameTest
    });
    tests = reshape(tests, [ ], 1);
end%


function fromStringTest(testCase)
    input = "x = @*a + b*x{-1} + @*log(c);";
    act = ExplanatoryEquation.fromString(input);
    exp = ExplanatoryEquation( );
    exp.VariableNames = ["x", "a", "b", "c"];
    exp.InputString = regexprep(input, "\s+", "");
    exp = defineDependent(exp, 1);
    exp = addExplanatory(exp, 2);
    exp = addExplanatory(exp, 4, "Transform=", "log");
    exp = addExplanatory(exp, "b*x{-1}", "Fixed=", 1);
    assertEqual(testCase, act, exp);
    assertEqual(testCase, act.RhsContainsLhsName, true);
end%


function fromStringExogenousTest(testCase)
    input = "x = @*a + b*z{-1} + @*log(c);";
    act = ExplanatoryEquation.fromString(input);
    exp = ExplanatoryEquation( );
    exp.VariableNames = ["x", "a", "b", "z", "c"];
    exp.InputString = regexprep(input, "\s+", "");
    exp = defineDependent(exp, 1);
    exp = addExplanatory(exp, 2);
    exp = addExplanatory(exp, 5, "Transform=", "log");
    exp = addExplanatory(exp, "b*z{-1}", "Fixed=", 1);
    assertEqual(testCase, act, exp);
    assertEqual(testCase, act.RhsContainsLhsName, false);
end%


function fromLegacyStringTest(testCase)
    input = "x = @*a + b*x{-1} + @*log(c);";
    legacyInput = replace(input, "@", "?");
    act = ExplanatoryEquation.fromString(legacyInput);
    act.InputString = replace(act.InputString, "?", "@");
    exp = ExplanatoryEquation.fromString(input);
    assertEqual(testCase, act, exp);
    assertEqual(testCase, act.RhsContainsLhsName, true);
end%


function sumTest(testCase)
    act = ExplanatoryEquation.fromString("x = y{-1} + x{-2};");
    exp_Explanatory = regression.Term( );
    exp_Explanatory.Position = NaN;
    exp_Explanatory.Shift = 0;
    exp_Explanatory.Incidence = sort([complex(2, -1), complex(1, -2)]); 
    exp_Explanatory.Transform = "";
    exp_Explanatory.Expression = @(x,t,date__)x(2,t-1,:)+x(1,t-2,:);
    exp_Explanatory.Fixed = 1;
    exp_Explanatory.ContainsLhsName = true;
    exp_Explanatory.MinShift = -2;
    exp_Explanatory.MaxShift = 0;
    act.Explanatory.Incidence = sort(act.Explanatory.Incidence);
    assertEqual(testCase, act.Explanatory, exp_Explanatory);
    assertEqual(testCase, act.RhsContainsLhsName, true);
end%


function sumExogenousTest(testCase)
    act = ExplanatoryEquation.fromString("x = y{-1} + z{-2};");
    exp_Explanatory = regression.Term( );
    exp_Explanatory.Position = NaN;
    exp_Explanatory.Shift = 0;
    exp_Explanatory.Incidence = sort([complex(2, -1), complex(3, -2)]); 
    exp_Explanatory.Transform = "";
    exp_Explanatory.Expression = @(x,t,date__)x(2,t-1,:)+x(3,t-2,:);
    exp_Explanatory.Fixed = 1;
    exp_Explanatory.ContainsLhsName = false;
    exp_Explanatory.MinShift = -2;
    exp_Explanatory.MaxShift = 0;
    act.Explanatory.Incidence = sort(act.Explanatory.Incidence);
    assertEqual(testCase, act.Explanatory, exp_Explanatory);
    assertEqual(testCase, act.RhsContainsLhsName, false);
end%


function lowerTest(testCase)
    act = ExplanatoryEquation.fromString( ...
        ["xa = Xa{-1} + xA{-2} + xb", "XB = xA{-1}"], ...
        'EnforceCase=', @lower ...
    );
    exp = ExplanatoryEquation.fromString( ...
        ["xa = xa{-1} + xa{-2} + xb", "xb = xa{-1}"] ...
    );
    assertEqual(testCase, act, exp);
end%


function upperTest(testCase)
    act = ExplanatoryEquation.fromString( ...
        ["xa = Xa{-1} + xA{-2} + xb", "XB = xA{-1}"], ...
        'EnforceCase=', @upper ...
    );
    exp = ExplanatoryEquation.fromString( ...
        ["XA = XA{-1} + XA{-2} + XB", "XB = XA{-1}"] ...
    );
    for i = 1 : numel(exp)
        exp(i).ResidualNamePattern = upper(exp(i).ResidualNamePattern);
        exp(i).FittedNamePattern = upper(exp(i).FittedNamePattern);
        exp(i).DateReference = upper(exp(i).DateReference);
    end
    assertEqual(testCase, act, exp);
end%


function ifStaticTest(testCase)
    q = ExplanatoryEquation.fromString("x = z + if(isfreq(date__, 1) & date__<yy(5), -10, 10)");
    inputDb = struct( );
    inputDb.x = Series(0, 0);
    inputDb.z = Series(1:10, @rand);
    simDb1 = simulate(q, inputDb, 1:10);
    assertEqual(testCase, simDb1.x(1:10), inputDb.z(1:10)+10);
    inputDb = struct( );
    inputDb.x = Series(yy(0), 0);
    inputDb.z = Series(yy(1:10), @rand);
    [simDb2, info2] = simulate(q, inputDb, yy(1:10));
    add = [-10; -10; -10; -10; 10; 10; 10; 10; 10; 10];
    assertEqual(testCase, simDb2.x(yy(1:10)), inputDb.z(yy(1:10))+add, 'AbsTol', 1e-14);
    assertEqual(testCase, info2.DynamicStatus, false);
    [simDb3, info3] = simulate(q, inputDb, yy(1:10), 'Blazer=', {'Dynamic=', true});
    add = [-10; -10; -10; -10; 10; 10; 10; 10; 10; 10];
    assertEqual(testCase, simDb3.x(yy(1:10)), inputDb.z(yy(1:10))+add, 'AbsTol', 1e-14);
    assertEqual(testCase, info3.DynamicStatus, true);
end%


function ifDynamicTest(testCase)
    q = ExplanatoryEquation.fromString("x = x{-1} + if(isfreq(date__, 1) & date__<yy(5), dummy1, dummy0)");
    inputDb = struct( );
    inputDb.x = Series(0, 0);
    inputDb.dummy1 = Series(1:10, @rand);
    inputDb.dummy0 = -Series(1:10, @rand);
    simDb1 = simulate(q, inputDb, 1:10);
    assertEqual(testCase, simDb1.x(1:10), cumsum(inputDb.dummy0(1:10)), 'AbsTol', 1e-14);
    inputDb = struct( );
    inputDb.x = Series(yy(0), 0);
    inputDb.dummy1 = Series(yy(1:10), @rand);
    inputDb.dummy0 = -Series(yy(1:10), @rand);
    simDb2 = simulate(q, inputDb, yy(1:10));
    temp = [inputDb.dummy1(yy(1:4)); inputDb.dummy0(yy(5:10))];
    assertEqual(testCase, simDb2.x(yy(1:10)), cumsum(temp), 'AbsTol', 1e-14);
end%


function compareDynamicStaticTest(testCase)
    q = ExplanatoryEquation.fromString([
        "x = x{-1} + if(isfreq(date__, 1) & date__<yy(5), dummy1, dummy0)"
        "y = 1 + if(isfreq(date__, 1) & date__<yy(5), dummy1, dummy0)"
    ]);
    inputDb = struct( );
    inputDb.x = Series(yy(0:9), 1);
    inputDb.dummy1 = Series(yy(1:10), @rand);
    inputDb.dummy0 = -Series(yy(1:10), @rand);
    simDb = simulate(q, inputDb, yy(1:10), 'Blazer=', {'Dynamic=', false});
    temp = 1 + [inputDb.dummy1(yy(1:4)); inputDb.dummy0(yy(5:10))];
    assertEqual(testCase, simDb.x(yy(1:10)), temp, 'AbsTol', 1e-14);
    assertEqual(testCase, simDb.y(yy(1:10)), temp, 'AbsTol', 1e-14);
end%


function switchVariableTest(testCase)
    q = ExplanatoryEquation.fromString([
        "x = if(switch__, dummy1, dummy0)"
    ]);
    inputDb = struct( );
    inputDb.x = Series(yy(0:9), 1);
    inputDb.dummy1 = Series(yy(1:10), @rand);
    inputDb.dummy0 = -Series(yy(1:10), @rand);
    inputDb.switch__ = false;
    simDb1 = simulate(q, inputDb, yy(1:10));
    assertEqual(testCase, simDb1.x(yy(1:10)), inputDb.dummy0(yy(1:10)));
    inputDb.switch__ = true;
    simDb2 = simulate(q, inputDb, yy(1:10));
    assertEqual(testCase, simDb2.x(yy(1:10)), inputDb.dummy1(yy(1:10)));
end%


function residualNameTest(testCase)
    q = ExplanatoryEquation.fromString([
        "x = x{-1}"
        "y = y{-1}"
    ], 'ResidualNamePattern=', ["", "_ma"]);
    assertEqual(testCase, [q.LhsName], ["x", "y"]);
    assertEqual(testCase, [q.ResidualName], ["x_ma", "y_ma"]);
    q = ExplanatoryEquation.fromString([
        "x = x{-1}"
        "y = y{-1}"
    ], 'ResidualNamePattern=', ["", "_ma"], 'EnforceCase=', @upper);
    assertEqual(testCase, [q.LhsName], ["X", "Y"]);
    assertEqual(testCase, [q.ResidualName], ["X_MA", "Y_MA"]);
end%


function fittedNameTest(testCase)
    q = ExplanatoryEquation.fromString([
        "x = x{-1}"
        "y = y{-1}"
    ], 'FittedNamePattern=', ["", "_fitted"]);
    assertEqual(testCase, [q.LhsName], ["x", "y"]);
    assertEqual(testCase, [q.FittedName], ["x_fitted", "y_fitted"]);
    q = ExplanatoryEquation.fromString([
        "x = x{-1}"
        "y = y{-1}"
    ], 'FittedNamePattern=', ["", "_fitted"], 'EnforceCase=', @upper);
    assertEqual(testCase, [q.LhsName], ["X", "Y"]);
    assertEqual(testCase, [q.FittedName], ["X_FITTED", "Y_FITTED"]);
end%
%)
