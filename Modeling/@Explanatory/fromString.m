function this = fromString(inputString, varargin)
% fromString  Create Explanatory object from string
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
% Explanatory object or array.
%
%
% ## Output Arguments ##
%
%
% __`this`__ [ Explanatory ]
% >
% New Explanatory object or array created from the `inputString`.
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
% -Copyright (c) 2007-2019 IRIS Solutions Team

%--------------------------------------------------------------------------

% -[IrisToolbox] for Macroeconomic Modeling
% -Copyright (c) 2007-2020 [IrisToolbox] Solutions Team

% Parse input arguments
%(
persistent pp
if isempty(pp)
    pp = extend.InputParser('Explanatory.fromString');

    addRequired(pp, 'inputString', @validate.list);

    addParameter(pp, 'ControlNames', string.empty(1, 0), @(x) isempty(x) || isa(x, 'string') || iscellstr(x));
    addParameter(pp, 'EnforceCase', [ ], @(x) isempty(x) || isequal(x, @upper) || isequal(x, @lower));
    addParameter(pp, 'ResidualNamePattern', @default, @(x) isequal(x, @default) || ((isstring(x) || iscellstr(x)) && numel(x)==2));
    addParameter(pp, 'FittedNamePattern', @default, @(x) isequal(x, @default) || ((isstring(x) || iscellstr(x)) && numel(x)==2));
    addParameter(pp, 'DateReference', @default, @(x) isequal(x, @default) || validate.stringScalar(x));
    addParameter(pp, 'InitObject', Explanatory( ), @(x) isa(x, 'Explanatory'));
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
        obj = opt.InitObject;
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
        % Remove DateReference from the list of variables
        %
        variableNames(variableNames==this__.DateReference) = [ ];

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
        if ~isempty(posStart) && this__.IsIdentity
            hereReportRegressionCoefficientsInIdentity( );
        end

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
            this__ = addExplanatoryTerm(this__, termStrings(ii), 'Fixed=', fixed(ii));
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

