% fromString  Create Explanatory object from string
%{
% Syntax
%--------------------------------------------------------------------------
%
%     this = function(inputString, ...)
%
%
% Input Arguments
%--------------------------------------------------------------------------
%
% __`inputString`__ [ string ]
%
%>    Input string, or an array of strings, that will be converted to
%>    Explanatory object or array.
%
%
% Output Arguments
%--------------------------------------------------------------------------
%
% __`this`__ [ Explanatory ]
%
%>    New Explanatory object or array created from the `inputString`.
%
%
% Options
%--------------------------------------------------------------------------
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
% Description
%--------------------------------------------------------------------------
%
%
% Example
%--------------------------------------------------------------------------
%
% Create an array of three Explanatory objects, with `x`, `y`, and
% `z` being the LHS variables:
%
%     q = Explanatory.fromString([
%         "x = 0.8*x{-1} + z"
%         "diff(y) = 2*x + a + b"
%         "z = 0.5*z{-1} + 0.3*z{-2}
%     ]);
%}

% -[IrisToolbox] for Macroeconomic Modeling
% -Copyright (c) 2007-2019 [IrisToolbox] Solutions Team

function this = fromString(inputString, varargin)

% Parse input arguments
%(
persistent pp INIT_EXPLANATORY
if isempty(pp) || isempty(INIT_EXPLANATORY)
    pp = extend.InputParser('Explanatory.fromString');

    addRequired(pp, 'inputString', @validate.list);

    addParameter(pp, 'ControlNames', string.empty(1, 0), @(x) isempty(x) || isa(x, 'string') || iscellstr(x));
    addParameter(pp, 'EnforceCase', [ ], @(x) isempty(x) || isequal(x, @upper) || isequal(x, @lower));
    addParameter(pp, 'ResidualNamePattern', @default, @(x) isequal(x, @default) || ((isstring(x) || iscellstr(x)) && numel(x)==2));
    addParameter(pp, 'FittedNamePattern', @default, @(x) isequal(x, @default) || ((isstring(x) || iscellstr(x)) && numel(x)==2));
    addParameter(pp, 'LhsReference', @default, @(x) isequal(x, @default) || validate.stringScalar(x));

    INIT_EXPLANATORY = Explanatory( );
end
parse(pp, inputString, varargin{:});
opt = pp.Options;
%)

%--------------------------------------------------------------------------

inputString = string(inputString);
numEquations = numel(inputString);
array = cell(1, numEquations);

numEmpty = 0;
inputString = strtrim(inputString);

for j = 1 : numel(inputString)
    inputString__ = inputString(j);
    [inputString__, attributes__] = Explanatory.extractAttributes(inputString__);
    [inputString__, label__] = Explanatory.extractLabel(inputString__);

    inputString__ = regexprep(inputString__, "\s+", "");
    if inputString__=="" || inputString__==";"
        numEmpty = numEmpty + 1;
        continue
    end


    %
    % Create a new Explanatory object, assign ResidualNamePattern
    % and FittedNamePattern, and enforce lower or upper case on
    % ResidualNamePattern and FittedNamePattern if requested
    %
    this__ = hereCreateObject( );


    %
    % Assign control names
    %
    if ~isempty(opt.ControlNames)
        if ~isempty(opt.EnforceCase)
            opt.ControlNames = opt.EnforceCase(opt.ControlNames);
        end
        this__.ControlNames = opt.ControlNames;
    end


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
    [split__, sign__] = split(inputString__, ["=#", "===", "="]);
    if isempty(sign__)
        hereThrowInvalidInputString( );
    end
    lhsString = split__(1);
    equalSign = sign__(1);
    rhsString = join(split__(2:end), "=");

    if lhsString==""
        hereThrowEmptyLhs( );
    end
    if rhsString==""
        hereThrowEmptyRhs( );
    end

    this__.IsIdentity = equalSign~="=";

    %
    % Populate the Explanatory object
    %
    this__ = defineDependentTerm(this__, lhsString);
    hereParseExplanatoryTerms( );
    this__ = seal(this__);
    this__.Label = label__;
    this__.Attributes = attributes__;
    array{j} = this__;
end

if numEmpty>0
    hereWarnEmptyEquations( );
end

this = reshape([array{:}], [ ], 1);

return


    function obj = hereCreateObject( )
        obj = INIT_EXPLANATORY;
        if ~isequal(opt.ResidualNamePattern, @default)
            obj.ResidualNamePattern = string(opt.ResidualNamePattern);
        end
        if ~isequal(opt.FittedNamePattern, @default)
            obj.FittedNamePattern = string(opt.FittedNamePattern);
        end
        if ~isequal(opt.LhsReference, @default)
            obj.LhsReference = string(opt.LhsReference);
        end
        if ~isempty(opt.EnforceCase)
            obj.ResidualNamePattern = opt.EnforceCase(obj.ResidualNamePattern);
            obj.FittedNamePattern = opt.EnforceCase(obj.FittedNamePattern);
        end
    end%




    function variableNames = hereCollectAllVariableNames( )
        if isempty(opt.EnforceCase)
            variableNames = regexp(inputString__, Explanatory.VARIABLE_NO_SHIFT, 'match');
        else
            variableNames = string.empty(1, 0);
            enforceCaseFunc = opt.EnforceCase;
            replaceFunc = @hereEnforceCase;
            inputString__ = regexprep(inputString__, Explanatory.VARIABLE_NO_SHIFT, '${replaceFunc($0)}');
        end

        %
        % Collect unique names of all variables
        %
        variableNames = unique(string(variableNames), 'stable');

        %
        % Remove control parameter names from the list of variables
        %
        if ~isempty(this__.ControlNames)
            variableNames = setdiff(variableNames, this__.ControlNames);
        end

        return
            function c = hereEnforceCase(c)
                c = enforceCaseFunc(c);
                variableNames(end+1) = c;
            end%
    end% 




    function hereParseExplanatoryTerms( )
        %
        % Legacy syntax for free parameters
        %
        rhsString = replace(rhsString, "?", "@");

        if endsWith(rhsString, ";")
            len__ = strlength(rhsString);
            rhsString = eraseBetween(rhsString, len__, len__);
        end

        %
        % Add an implicit plus sign if RHS starts with an @ to make the
        % start of all regression terms of one of the following forms: +@
        % or -@ 
        %
        if startsWith(rhsString, "@")
            rhsString = "+" + rhsString;
        end

        %
        % Find all characters outside any brackets (round, curly, square);
        % these characters will have level==0
        %
        rhsString = char(rhsString);
        [level, allClosed] = textual.bracketLevel(rhsString, {'()', '{}', '[]'}, '--skip');

        %
        % Find the starts of all regression terms
        %
        posStart = sort([strfind(rhsString, '+@'), strfind(rhsString, '-@')]);
        if ~isempty(posStart) && this__.IsIdentity
            hereReportRegressionCoefficientsInIdentity( );
        end

        %
        % Collect all regression terms first and see what's left afterwards
        %
        numRegressionTerms = numel(posStart);
        termStrings = repmat("", 1, numRegressionTerms);
        fixed = nan(1, numRegressionTerms);
        for ii = 1 : numRegressionTerms
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
            fixed(1, end+1) = 1;
        end
        termStrings = strtrim(termStrings);

        % 
        % Create an explanatory term for each regression term and for the
        % fixed lump-sum term
        %
        for ii = 1 : numel(termStrings)
            this__ = addExplanatoryTerm(this__, fixed(ii), termStrings(ii));
        end

        return

            function hereReportRegressionCoefficientsInIdentity( )
                thisError = [ 
                    "Explanatory:RegressionInIdentity"
                    "This Explanatory object specification includes regression "
                    "coefficients even though it is marked as an identity: %s "
                ];
                throw(exception.Base(thisError, 'error'), this__.InputString);
            end%
    end%




    function hereThrowInvalidInputString( )
        thisError = [ 
            "Explanatory:InvalidInputString"
            "Invalid input string to define ExplanatoryTerm: %s" 
        ];
        throw(exception.Base(thisError, 'error'), this__.InputString);
    end%




    function hereThrowEmptyLhs( )
        thisError = [ 
            "Explanatory:EmptyLhs"
            "This Explanatory object specification has an empty LHS: %s " 
        ];
        throw(exception.Base(thisError, 'error'), this__.InputString);
    end%




    function hereThrowEmptyRhs( )
        thisError = [ 
            "Explanatory:EmptyRhs"
            "This Explanatory object specification has an empty RHS: %s" 
        ];
        throw(exception.Base(thisError, 'error'), this__.InputString);
    end%




    function hereWarnEmptyEquations( )
        thisWarning = [ 
            "Explanatory:EmptyEquations"
            "Excluded a total number of %g empty equation(s) from the input string."
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
%{
##### SOURCE BEGIN #####
% saveAs=Explanatory/fromStringUnitTest.m

testCase = matlab.unittest.FunctionTestCase.fromFunction(@(x)x);

%% Test Plain Vanilla
    input = "x = @*a + b*x{-1} + @*log(c);";
    act = Explanatory.fromString(input);
    exp = Explanatory( );
    exp = setp(exp, 'VariableNames', ["x", "a", "b", "c"]);
    exp = setp(exp, 'InputString', regexprep(input, "\s+", ""));
    exp = defineDependentTerm(exp, "x");
    exp = addExplanatoryTerm(exp, NaN, "a");
    exp = addExplanatoryTerm(exp, NaN, "log(c)");
    exp = addExplanatoryTerm(exp, 1, "b*x{-1}");
    exp = seal(exp);
    %
    exp_struct = struct(exp);
    act_struct = struct(act);
    assertEqual(testCase, sort(fieldnames(exp_struct)), sort(fieldnames(act_struct)));
    for n = keys(exp_struct)
        if isa(exp_struct.(n), 'function_handle')
            assertEqual(testCase, char(exp_struct.(n)), char(act_struct.(n)));
        else
            assertEqual(testCase, exp_struct.(n), act_struct.(n));
        end
    end
    %
    assertEqual(testCase, act.RhsContainsLhsName, true);


%% Test Exogenous
    input = "x = @*a + b*z{-1} + @*log(c);";
    act = Explanatory.fromString(input);
    exp = Explanatory( );
    exp = setp(exp, 'VariableNames', ["x", "a", "b", "z", "c"]);
    exp = setp(exp, 'InputString', regexprep(input, "\s+", ""));
    exp = defineDependentTerm(exp, "x");
    exp = addExplanatoryTerm(exp, NaN, "a");
    exp = addExplanatoryTerm(exp, NaN, "log(c)");
    exp = addExplanatoryTerm(exp, 1, "b*z{-1}");
    exp = seal(exp);
    %
    exp_struct = struct(exp);
    act_struct = struct(act);
    assertEqual(testCase, sort(fieldnames(exp_struct)), sort(fieldnames(act_struct)));
    for n = keys(exp_struct)
        if isa(exp_struct.(n), 'function_handle')
            assertEqual(testCase, char(exp_struct.(n)), char(act_struct.(n)));
        else
            assertEqual(testCase, exp_struct.(n), act_struct.(n));
        end
    end
    %
    assertEqual(testCase, act.RhsContainsLhsName, false);


%% Test Legacy String
    input = "x = @*a + b*x{-1} + @*log(c);";
    legacyInput = replace(input, "@", "?");
    act = Explanatory.fromString(legacyInput);
    act = setp(act, 'InputString', replace(getp(act, 'InputString'), "?", "@"));
    exp = Explanatory.fromString(input);
    %
    exp_struct = struct(exp);
    act_struct = struct(act);
    assertEqual(testCase, sort(fieldnames(exp_struct)), sort(fieldnames(act_struct)));
    for n = keys(exp_struct)
        if isa(exp_struct.(n), 'function_handle')
            assertEqual(testCase, char(exp_struct.(n)), char(act_struct.(n)));
        else
            assertEqual(testCase, exp_struct.(n), act_struct.(n));
        end
    end
    %
    assertEqual(testCase, act.RhsContainsLhsName, true);


%% Test Lower
    act = Explanatory.fromString( ...
        ["xa = Xa{-1} + xA{-2} + xb", "XB = xA{-1}"], ...
        'EnforceCase=', @lower ...
    );
    exp = Explanatory.fromString( ...
        ["xa = xa{-1} + xa{-2} + xb", "xb = xa{-1}"] ...
    );
    %
    exp_struct = struct(exp);
    act_struct = struct(act);
    assertEqual(testCase, sort(fieldnames(exp_struct)), sort(fieldnames(act_struct)));
    for n = keys(exp_struct)
        if isa(exp_struct.(n), 'function_handle')
            assertEqual(testCase, char(exp_struct.(n)), char(act_struct.(n)));
        else
            assertEqual(testCase, exp_struct.(n), act_struct.(n));
        end
    end


%% Test Upper
    act = Explanatory.fromString( ...
        ["xa = Xa{-1} + xA{-2} + xb", "XB = xA{-1}"], ...
        'EnforceCase=', @upper ...
    );
    exp = Explanatory.fromString( ...
        ["XA = XA{-1} + XA{-2} + XB", "XB = XA{-1}"] ...
    );
    for i = 1 : numel(exp)
        exp(i) = setp(exp(i), 'ResidualNamePattern', upper(getp(exp(i), 'ResidualNamePattern')));
        exp(i) = setp(exp(i), 'FittedNamePattern', upper(getp(exp(i), 'FittedNamePattern')));
    end
    %
    exp_struct = struct(exp);
    act_struct = struct(act);
    assertEqual(testCase, sort(fieldnames(exp_struct)), sort(fieldnames(act_struct)));
    for n = keys(exp_struct)
        if isa(exp_struct.(n), 'function_handle')
            assertEqual(testCase, char(exp_struct.(n)), char(act_struct.(n)));
        else
            assertEqual(testCase, exp_struct.(n), act_struct.(n));
        end
    end


%% Test Static If
    q = Explanatory.fromString("x = z + if(w<0, -10, 10)");
    inputDb = struct( );
    inputDb.x = Series(0, 0);
    inputDb.z = Series(1:10, @rand);
    inputDb.w = -1;
    simDb1 = simulate(q, inputDb, 1:10);
    assertEqual(testCase, simDb1.x(1:10), inputDb.z(1:10)-10);
    inputDb = struct( );
    inputDb.x = Series(yy(0), 0);
    inputDb.z = Series(yy(1:10), @rand);
    inputDb.w = 1;
    [simDb2, info2] = simulate(q, inputDb, yy(1:10));
    assertEqual(testCase, simDb2.x(yy(1:10)), inputDb.z(yy(1:10))+10);


%% Test Compare Dynamic Static If
    q = Explanatory.fromString([
        "x = x{-1} + if(w<0, dummy1, dummy0)"
        "y = 1 + if(w, dummy1, dummy0)"
    ]);
    inputDb = struct( );
    inputDb.x = Series(yy(0:9), 1);
    inputDb.w = -1;
    inputDb.dummy1 = Series(yy(1:10), @rand);
    inputDb.dummy0 = -Series(yy(1:10), @rand);
    simDb = simulate(q, inputDb, yy(1:10), "Blazer=", {"Dynamic=", false});
    temp = 1 + inputDb.dummy1;
    assertEqual(testCase, simDb.x(yy(1:10)), temp(yy(1:10)), "AbsTol", 1e-14);
    assertEqual(testCase, simDb.y(yy(1:10)), temp(yy(1:10)), "AbsTol", 1e-14);
    inputDb.w = Series();
    inputDb.w(yy(1:10)) = -1;
    inputDb.w(yy(6:10)) = 1;
    simDb = simulate(q, inputDb, yy(1:10));
    assertEqual(testCase, simDb.y(yy(1:10)), temp(yy(1:10)), "AbsTol", 1e-14);
    temp = inputDb.x{yy(0)};
    for t = yy(1:10)
        if inputDb.w(t)<0 
            temp(t) = temp(t-1) + inputDb.dummy1(t);
        else
            temp(t) = temp(t-1) + inputDb.dummy0(t);
        end
    end
    assertEqual(testCase, simDb.x(yy(1:10)), temp(yy(1:10)), "AbsTol", 1e-14);


%% Test Switch Variable
    q = Explanatory.fromString([
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


%% Test Residual Name
    q = Explanatory.fromString([
        "x = x{-1}"
        "y = y{-1}"
    ], 'ResidualNamePattern=', ["", "_ma"]);
    assertEqual(testCase, [q.LhsName], ["x", "y"]);
    assertEqual(testCase, [q.ResidualName], ["x_ma", "y_ma"]);
    q = Explanatory.fromString([
        "x = x{-1}"
        "y = y{-1}"
    ], 'ResidualNamePattern=', ["", "_ma"], 'EnforceCase=', @upper);
    assertEqual(testCase, [q.LhsName], ["X", "Y"]);
    assertEqual(testCase, [q.ResidualName], ["X_MA", "Y_MA"]);


%% Test Fitted name
    q = Explanatory.fromString([
        "x = x{-1}"
        "y = y{-1}"
    ], 'FittedNamePattern=', ["", "_fitted"]);
    assertEqual(testCase, [q.LhsName], ["x", "y"]);
    assertEqual(testCase, [q.FittedName], ["x_fitted", "y_fitted"]);
    q = Explanatory.fromString([
        "x = x{-1}"
        "y = y{-1}"
    ], 'FittedNamePattern=', ["", "_fitted"], 'EnforceCase=', @upper);
    assertEqual(testCase, [q.LhsName], ["X", "Y"]);
    assertEqual(testCase, [q.FittedName], ["X_FITTED", "Y_FITTED"]);

##### SOURCE END #####
%}
