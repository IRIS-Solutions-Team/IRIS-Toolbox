function output = parseInputSpecs(expy, inputSpecs, inputTransform, inputShift, types)
% parseInputSpecs  Parse input specification of DependentTerm or
% ExplanatoryTerms
%{
% Backend [IrisToolbox] method
% No help provided
%}

% -[IrisToolbox] for Macroeconomic Modeling
% -Copyright (c) 2007-2020 [IrisToolbox] Solutions Team

%--------------------------------------------------------------------------

output = struct( );
output.Type = "";
output.Transform = "";
output.Incidence = double.empty(1, 0);
output.Position = NaN;
output.Shift = 0;
output.Expression = [ ];
output.InputString = "";

%
% Pointer to VariableNames
%
if isequal(types, @all) || any(types=="Pointer")
    hereParsePointer( );
    if output.Type=="Pointer"
        return
    end
end

if ~isa(inputSpecs, 'string')
    hereThrowInvalidSpecification( );
end

inputSpecs = erase(string(inputSpecs), [" ", "\t"]);


%
% Plain variable name or variables name and shift
%
if isequal(types, @all) || any(types=="Name")
    hereParseName( );
    if output.Type=="Name"
        return
    end
    hereParseNameShift( );
    if output.Type=="Name"
        return
    end
end


%
% Registered transform
%
if isequal(types, @all) || any(types=="Transform")
    hereParseRegisteredTransforms( );
    if output.Type=="Transform"
        return
    end
end


%
% Expression as anonymous function
%
if isequal(types, @all) || any(types=="Expression")
    hereParseExpression( );
    if output.Type=="Expression"
        return
    end
end

hereThrowInvalidSpecification( );

return


    function hereParsePointer( )
        if ~isnumeric(inputSpecs)
            return
        end
        pos = inputSpecs;
        if ~validate.roundScalar(pos, 1, numel(expy.VariableNames));
            hereThrowInvalidPointer( );
        end
        transform = inputTransform;
        if isequal(transform, @auto)
            transform = "";
        end
        shift = inputShift;
        if isequal(shift, @auto)
            shift = 0;
        end
        output.Type = "Pointer";
        output.Transform = transform;
        output.Position = pos;
        output.Shift = shift;
        output.Incidence = locallyCreateIncidence(pos, shift, transform);
        output.InputString = locallyCreateInputString(expy, pos, shift, transform);
    end%


    function hereParseName( )
        inx = inputSpecs==expy.VariableNames;
        if ~any(inx)
            return
        end
        pos = find(inx);
        transform = inputTransform;
        if isequal(transform, @auto)
            transform = "";
        end
        shift = inputShift;
        if isequal(shift, @auto)
            shift = 0;
        end
        output.Type = "Name";
        output.Transform = transform;
        output.Position = pos;
        output.Shift = shift;
        output.Incidence = locallyCreateIncidence(pos, shift, transform);
        output.InputString = locallyCreateInputString(expy, pos, shift, transform);
    end%


    function hereParseNameShift( )
        if ~contains(inputSpecs, "{") || ~endsWith(inputSpecs, "}")
            return
        end
        tokens = split(inputSpecs, ["{", "}"]);
        if numel(tokens)~=3
            return
        end
        inx = tokens(1)==expy.VariableNames;
        if ~any(inx)
            return
        end
        shift = double(tokens(2));
        if ~validate.roundScalar(shift)
            return
        end
        pos = find(inx);
        transform = inputTransform;
        if isequal(transform, @auto)
            transform = "";
        end
        if ~isequal(inputShift, @auto)
            shift = shift + inputShift;
        end
        output.Type = "Name";
        output.Transform = transform;
        output.Position = pos;
        output.Shift = shift;
        output.Incidence = locallyCreateIncidence(pos, shift, transform);
        output.InputString = locallyCreateInputString(expy, pos, shift, transform);
    end%


    function hereParseRegisteredTransforms( )
        %(
        inputSpecs__ = replace(strip(inputSpecs), " ", "");

        keysTransforms = keys(regression.Term.TRANSFORMS);
        if ~startsWith(inputSpecs__, keysTransforms+"(") || ~endsWith(inputSpecs__, ")")
            return
        end
        transform = extractBefore(inputSpecs__, "(");

        name = extractBetween( ...
            inputSpecs__, strlength(transform)+1, strlength(inputSpecs__) ...
            , "Boundaries", "Exclusive" ...
        );
        inxName = name==expy.VariableNames;
        if strlength(name)==0 || ~any(inxName)
            return
        end

        shift = inputShift;
        if isequal(shift, @auto)
            shift = 0;
        end

        pos = find(inxName);
        output.Type = "Transform";
        output.Transform = transform;
        output.Position = pos;
        output.Shift = shift;
        output.Incidence = locallyCreateIncidence(pos, shift, transform);
        output.InputString = locallyCreateInputString(expy, pos, shift, transform);
        %)
    end%


    function hereParseExpression( )
        %
        % Substitute for AR terms
        % Expand pseudofunctions
        % diff, difflog, dot, movsum, movavg, movprod, movgeom
        %
        output.InputString = inputSpecs;
        parsedSpecs = inputSpecs;
        herePreparseSpecials( );
        parsedSpecs = parser.Pseudofunc.parse(parsedSpecs);

        %
        % Unique names of all control parameters
        %
        controlNames = collectControlNames(expy);

        %
        % Replace name{k} with x(pos, t+k, :)
        % Replace name with x(pos, t, :)
        %
        incidence = double.empty(1, 0);
        invalidNames = string.empty(1, 0);
        invalidShifts = string.empty(1, 0);
        replaceFunc = @replaceNameShift;
        parsedSpecs = regexprep(parsedSpecs, Explanatory.VARIABLE_WITH_SHIFT, "${replaceFunc($1, $2)}");
        parsedSpecs = regexprep(parsedSpecs, Explanatory.VARIABLE_NO_SHIFT, "${replaceFunc($1)}");
        parsedSpecs = replace(parsedSpecs, "$", "t");

        if ~isempty(invalidNames)
            hereThrowInvalidNames( );
        end

        %
        % Vectorize operators
        %
        parsedSpecs = vectorize(parsedSpecs);

        %
        % Create anonymous function
        %
        try %#ok<TRYNC>
            herePostparseSpecials( );
            func = str2func("@(x,t,date__,controls__)" + parsedSpecs);
            output.Type = "Expression";
            output.Expression = func;
            output.Incidence = incidence;
        end

        return


            function c = replaceNameShift(c1, c2)
                c = '';
                c1 = string(c1);
                if c1=="date__"
                    c = c1;
                    return
                end
                if any(c1==controlNames)
                    c = "controls__." + c1;
                    return
                end
                pos = getPosName(expy, c1);
                sh = 0;
                if isnan(pos)
                    invalidNames = [invalidNames, c1];
                    return
                end
                if nargin>=2 && strlength(c2)>0 && ~strcmp(c2, '{}') && ~strcmp(c2, '{0}')
                    c2 = string(c2);
                    sh = str2num(replace(c2, ["{", "}"], ["", ""]));
                    if ~validate.numericScalar(sh) || ~isfinite(sh)
                        invalidShifts = [invalidShifts, c2];
                        return
                    end
                end
                if sh==0
                    c = sprintf('x(%g, $, :)', pos);
                else
                    c = sprintf('x(%g, $%+g, :)', pos, sh);
                end
                incidence = [incidence, complex(pos, sh)];
            end%


            function herePreparseSpecials( )
                %(
                if contains(parsedSpecs, expy.DateReference)
                    parsedSpecs = regexprep(parsedSpecs, "\<" + expy.DateReference + "\>", "date__");
                end
                if contains(parsedSpecs, expy.ArReference)
                    lhs = expy.DependentTerm.InputString;
                    parsedSpecs = regexprep( ...
                        parsedSpecs ...
                        , "\<" + expy.ArReference + "\>\{([^\}]*)\}" ...
                        , "${parser.Pseudofunc.shiftTimeSubs(""" + lhs + """, $1)}" ...
                    );
                end
                %)
            end%


            function herePostparseSpecials( )
                % Replace `ifnan(` with `simulate.ifnan(`
                parsedSpecs = regexprep(parsedSpecs, "(?<!\.)\<ifnan\(", "simulate.ifnan(");
                % Replace `if(` with `simulate.if(`
                parsedSpecs = regexprep(parsedSpecs, "(?<!\.)\<if\(", "simulate.if(");
            end%


            function hereThrowInvalidNames( )
                invalidNames = cellstr(invalidNames);
                thisError = [ 
                    "RegressionTerm:InvalidName"
                    "This name occurs in a regression.Term definition "
                    "but is not on the list of Explanatory.VariableNames: %s " 
                ];
                throw(exception.Base(thisError, "error"), invalidNames{:});
            end%
        end%


    function hereThrowInvalidPointer( )
        thisError = [ 
            "RegressionTerm:InvalidPointerToVariableNames"
            "Regression term specification points to a non-existing position "
            "in the Explanatory.VariableNames list: %g " 
        ];
        throw(exception.Base(thisError, 'error'), inputSpecs);
    end%


    function hereThrowInvalidSpecification( )
        thisError = [ 
            "Regression:InvalidTermSpecification"
            "Cannot parse this regression.Term specification: %s " 
        ];
        throw(exception.ParseTime(thisError, 'error'), inputSpecs);
    end%
end%

%
% Local Functions
%

function incidence = locallyCreateIncidence(pos, shift, transform)
    incidence = complex(pos, shift);
    if strlength(transform)>0
        addShifts = regression.Term.TRANSFORMS_SHIFTS.(transform);
        if ~isempty(addShifts)
            incidence = [incidence, complex(pos, shift+addShifts)];
        end
    end
end%


function inputString = locallyCreateInputString(expy, pos, shift, transform)
    inputString = expy.VariableNames(pos);
    if shift~=0
        inputString = inputString + "{" + double(shift) + "}";
    end
    if transform~=""
        inputString = transform + "(" + inputString + ")";
    end
end%

