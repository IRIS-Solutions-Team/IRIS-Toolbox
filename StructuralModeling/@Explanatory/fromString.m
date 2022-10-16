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

    addParameter(pp, 'ControlNames', string.empty(1, 0), @(x) isempty(x) || isstring(x) || iscellstr(x));
    addParameter(pp, 'EnforceCase', [ ], @(x) isempty(x) || isequal(x, @upper) || isequal(x, @lower));
    addParameter(pp, 'ResidualNamePattern', @auto, @(x) isequal(x, @auto) || ((isstring(x) || iscellstr(x)) && numel(x)==2));
    addParameter(pp, 'FittedNamePattern', @auto, @(x) isequal(x, @auto) || ((isstring(x) || iscellstr(x)) && numel(x)==2));
    addParameter(pp, 'LhsReference', @auto, @(x) isequal(x, @auto) || validate.stringScalar(x));

    INIT_EXPLANATORY = Explanatory();
end
parse(pp, inputString, varargin{:});
opt = pp.Options;
%)



    inputString = string(inputString);
    numEquations = numel(inputString);
    array = cell(1, numEquations);

    numEmpty = 0;
    inputString = strtrim(inputString);

    for j = 1 : numel(inputString)
        inputString__ = inputString(j);
        [inputString__, attributes__] = Explanatory.extractAttributes(inputString__);
        [inputString__, label__] = Explanatory.extractLabel(inputString__);
        [label__, userDataString__] = Explanatory.extractUserDataString(label__);

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
        % Legacy syntax =# -> ===
        %
        inputString__ = replace(inputString__, "=#", "===");


        this__.InputString = inputString__;


        %
        % Extract ResidualModel if present; this will remain in the InputString
        % of the Explanatory object
        %

        if contains(inputString__, "#")
            residualModelString__ = "#" + extractAfter(inputString__, "#");
            inputString__ = extractBefore(inputString__, "#");
            residualModel = ParamArmani.fromEviewsString(residualModelString__);
            this__.ResidualModel = residualModel;
        end


        %
        % Collect all variables names from the input string, enforcing lower or
        % upper case if requested
        %

        this__.VariableNames = hereCollectAllVariableNames( );


        %
        % * Split the input equation string into LHS and RHS using the first
        % equal sign found
        %
        % * Permit := as these are allowed in !substitutions in Model source
        % files
        %
        % * There may be more than one equal sign such as == in if( )
        %

        [split__, sign__] = split(inputString__, ["=#", "===", "=", ":="]);
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
        this__ = parseRightHandSide(this__, rhsString);
        this__ = seal(this__);
        this__.Attributes = attributes__;
        this__.Label = label__;
        this__ = updateUserDataFromString(this__, userDataString__);
        array{j} = this__;
    end

    if numEmpty>0
        hereWarnEmptyEquations( );
    end

    this = reshape([array{:}], [ ], 1);

return


    function obj = hereCreateObject( )
        obj = INIT_EXPLANATORY;
        if ~isequal(opt.ResidualNamePattern, @auto)
            obj.ResidualNamePattern = string(opt.ResidualNamePattern);
        end
        if ~isequal(opt.FittedNamePattern, @auto)
            obj.FittedNamePattern = string(opt.FittedNamePattern);
        end
        if ~isequal(opt.LhsReference, @auto)
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


