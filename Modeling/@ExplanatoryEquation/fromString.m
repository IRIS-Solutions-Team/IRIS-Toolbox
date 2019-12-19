function this = fromString(varargin)
% fromString  Create ExplanatoryEquation object from string
%{
%}

% -[IrisToolbox] for Macroeconomic Modeling
% -Copyright (c) 2007-2019 IRIS Solutions Team

% Invoke unit tests
%(
if nargin==1 && isequal(varargin{1}, '--test')
    this = functiontests({
        @fromStringTest
        @fromLegacyStringTest
        @sumTest
    });
    this = reshape(this, [ ], 1);
    return
end
%)


persistent pp
if isempty(pp)
    pp = extend.InputParser('ExplanatoryEquation.fromString');
    addRequired(pp, 'inputString', @(input) iscell(input) && all(cellfun(@(x) isa(x, 'string') || ischar(x) || iscellstr(x), input)));
end
parse(pp, varargin);

%--------------------------------------------------------------------------

numEquations = sum(cellfun(@(x) numel(string(x)), varargin));
array = cell(1, numEquations);

count = 0;
numEmpty = 0;
for i = 1 : numel(varargin)
    varargin__ = string(varargin{i});
    for j = 1 : numel(varargin__)
        inputString = strtrim(varargin__(j));
        [inputString, attributes__] = ExplanatoryEquation.extractAttributes(inputString);
        [inputString, label__] = ExplanatoryEquation.extractLabel(inputString);

        inputString = regexprep(inputString, "\s+", "");
        if inputString=="" || inputString==";"
            numEmpty = numEmpty + 1;
            continue
        end

        inputString0 = hereComposeInputString( );

        %
        % Split the input equation string into LHS and RHS using the first
        % equal sign found
        %
        posEqual = strfind(inputString, "=");
        if isempty(posEqual)
            hereThrowInvalidInputString( );
        elseif numel(posEqual)>1
            posEqual = posEqual(1);
        end
        inputString = [extractBefore(inputString, posEqual), extractAfter(inputString, posEqual)];
        if inputString(1)==""
            hereThrowEmptyLhs( );
        end
        if inputString(2)==""
            hereThrowEmptyRhs( );
        end

        this__ = ExplanatoryEquation( );
        this__.InputString = inputString0;

        hereGetVariableNames( );
        this__ = defineDependent(this__, inputString(1));
        hereParseExplanatory( );
        count = count + 1;
        this__.Label = label__;
        this__.Attributes = attributes__;
        array{count} = this__;
    end
end

if numEmpty>0
    hereWarnEmptyEquations( );
end

this = reshape([array{:}], [ ], 1);

return


    function inputString0 = hereComposeInputString( )
        inputString0 = inputString;
        if label__~=""
            inputString0 = """" + label__ + """ " + inputString0;
        end
        if ~isempty(attributes__)
            inputString0 = join(attributes__) + " " + inputString0;
        end
        if ~endsWith(inputString0, ";")
            inputString0 = inputString0 + ";";
        end
    end%




    function hereGetVariableNames( )
        variableNames = regexp(inputString, "\<[A-Za-z]\w*\>(?!\()", 'match');
        if iscell(variableNames)
            variableNames = [variableNames{:}];
        end
        variableNames = unique(string(variableNames), 'stable');
        %
        % Remove date__ from the list of variables
        %
        variableNames(variableNames=="date__") = [ ];
        this__.VariableNames = variableNames;
    end% 




    function hereParseExplanatory( )
        %
        % Legacy syntax for free parameters
        %
        rhs = replace(inputString(2), "?", "@");

        rhs = char(rhs);
        if rhs(end)==';'
            rhs(end) = '';
        end
        %
        % Add an implicit plus sign if RHS starts with an @ to make the
        % start of all regression terms of one of the following forms: +@
        % or -@ 
        %
        if rhs(1)=='@'
            rhs = ['+', rhs];
        end

        %
        % Find all characters outside any brackets (round, curly, square);
        % these characters will have level==0
        %
        [level, allClosed] = textual.bracketLevel(rhs, {'()', '{}', '[]'});

        %
        % Find the starts of all regression terms
        %
        posStart = sort([strfind(rhs, '+@'), strfind(rhs, '-@')]);

        %
        % Collect all regression terms first and see what's left afterwards
        %
        numTerms = numel(posStart);
        termStrings = repmat("", 1, numTerms);
        fixed = nan(1, numTerms);
        for ii = 1 : numTerms
            ithPosStart = posStart(ii);
            after = false(size(rhs));
            after(ithPosStart+1:end) = true;
            %
            % Find the end of the current regression term; the end is
            % either a plus or minus sign outside brackets, or the end of
            % the string
            %
            ithPosEnd = find((rhs=='+' | rhs=='-') & level==0 & after, 1);
            if ~isempty(ithPosEnd)
                ithPosEnd = ithPosEnd - 1;
            else
                ithPosEnd = numel(rhs);
            end
            temp = [rhs(ithPosStart), rhs(ithPosStart+3:ithPosEnd)];
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
            rhs(ithPosStart:ithPosEnd) = ' ';
        end

        %
        % Add a fixed term (lump sum) if there is anything left
        %
        rhs = regexprep(rhs, '\s+', '');
        if strncmp(rhs, '+', 1)
            rhs(1) = '';
        end
        if ~isempty(rhs)
            termStrings(end+1) = string(rhs);
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
        throw(exception.Base(thisError, 'error'), inputString0);
    end%




    function hereThrowEmptyLhs( )
        thisError = [ 
            "ExplanatoryEquation:EmptyLhs"
            "ExplanatoryEquation specification has an empty LHS: %s " 
        ];
        throw(exception.Base(thisError, 'error'), inputString0);
    end%




    function hereThrowEmptyRhs( )
        thisError = [ 
            "ExplanatoryEquation:EmptyRhs"
            "ExplanatoryEquation specification has an empty RHS: %s" 
        ];
        throw(exception.Base(thisError, 'error'), inputString0);
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
% Unit Tests
%
%(
function fromStringTest(this)
    input = "x = @*a + b*x{-1} + @*log(c);";
    act = ExplanatoryEquation.fromString(input);
    exp = ExplanatoryEquation( );
    exp.VariableNames = ["x", "a", "b", "c"];
    exp.InputString = regexprep(input, "\s+", "");
    exp = defineDependent(exp, 1);
    exp = addExplanatory(exp, 2);
    exp = addExplanatory(exp, 4, "Transform=", "log");
    exp = addExplanatory(exp, "b*x{-1}", "Fixed=", 1);
    assertEqual(this, act, exp);
end%


function fromLegacyStringTest(this)
    input = "x = @*a + b*x{-1} + @*log(c);";
    legacyInput = replace(input, "@", "?");
    act = ExplanatoryEquation.fromString(legacyInput);
    act.InputString = replace(act.InputString, "?", "@");
    exp = ExplanatoryEquation.fromString(input);
    assertEqual(this, act, exp);
end%


function sumTest(this)
    act = ExplanatoryEquation.fromString("x = y{-1} + x{-2};");
    exp_Explanatory = regression.Term( );
    exp_Explanatory.Position = [1, 2];
    exp_Explanatory.Shift = [-2, -1, 0];
    exp_Explanatory.Transform = "";
    exp_Explanatory.Expression = @(x,t,date__)x(2,t-1,:)+x(1,t-2,:);
    exp_Explanatory.Fixed = 1;
    exp_Explanatory.ContainsLhsName = true;
    exp_Explanatory.MinShift = -2;
    exp_Explanatory.MaxShift = 0;
    assertEqual(this, act.Explanatory, exp_Explanatory);
end%
%)
