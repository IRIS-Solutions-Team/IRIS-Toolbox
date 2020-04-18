function output = parseInputSpecs(xq, inputSpecs, inputTransform, inputShift, types)
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

inputSpecs = replace(string(inputSpecs), " ", "");

%
% Plain variable name
%
if isequal(types, @all) || any(types=="Name")
    hereParseName( );
    if output.Type=="Name"
        return
    end
end

%
% Registered transform, possibly expanded
%
if isequal(types, @all) || any(types=="Transform")
    hereParseDiffTransform( );
    if output.Type=="Transform"
        return
    end
    hereParseTransform( );
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
        if ~validate.roundScalarInRange(inputSpecs, 1, numel(xq.VariableNames));
            hereThrowInvalidPointer( );
        end
        if isequal(inputTransform, @auto)
            inputTransform = "";
        end
        if isequal(inputShift, @auto)
            inputShift = 0;
        end
        output.Type = "Pointer";
        output.Transform = inputTransform;
        output.Incidence = complex(inputSpecs, inputShift);
        if startsWith(output.Transform, "diff")
            output.Incidence = [output.Incidence, complex(inputSpecs, inputShift-1)];
        end
        output.Position = inputSpecs;
        output.Shift = inputShift;
    end%




    function hereParseName( )
        inx = inputSpecs==xq.VariableNames;
        if ~any(inx)
            return
        end
        pos = find(inx);
        if isequal(inputTransform, @auto)
            inputTransform = "";
        end
        if isequal(inputShift, @auto)
            inputShift = 0;
        end
        output.Type = "Name";
        output.Transform = inputTransform;
        output.Incidence = complex(pos, inputShift);
        if startsWith(output.Transform, "diff")
            output.Incidence = [output.Incidence, complex(pos, inputShift-1)];
        end
        output.Position = pos;
        output.Shift = inputShift;
    end%




    function hereParseDiffTransform( )
        %
        % Parse input string with one of the following:
        %
        % * diff(name) 
        % * difflog(name) 
        % * expanded diff(name) 
        % * expanded difflog(name)
        %
        if ~contains(inputSpecs, "diff") && ~contains(inputSpecs, "log") && ~contains(inputSpecs, "(") && ~contains(inputSpecs, ")")
            return
        end
        name = string.empty(1, 0);
        transform = string.empty(1, 0);
        if startsWith(inputSpecs, "diff(")
            % ^diff(name)$
            name = regexp(inputSpecs, "^diff\(([A-Za-z]\w*)\)$", "tokens", "once");
            transform = "diff";
        end
        if isempty(name) && startsWith(inputSpecs, "difflog(")
            % ^difflog(name)$
            name = regexp(inputSpecs, "^difflog\(([A-Za-z]\w*)\)$", "tokens", "once");
            transform = "difflog";
        end
        if isempty(name) && startsWith(inputSpecs, "(")
            % ^((name)-(name{-1}))$
            name = regexp(inputSpecs, "^\(\(([A-Za-z]\w*)\)-\(\1{-1}\)\)$", "tokens", "once");
            transform = "diff";
        end
        if isempty(name) && startsWith(inputSpecs, "(")
            % ^(log(name)-log(name{-1}))$
            name = regexp(inputSpecs, "\(log\(([A-Za-z]\w*)\)-log\(\1{-1}\)\)", "tokens", "once");
            transform = "difflog";
        end

        if isempty(name)
            return
        end

        inx = name==xq.VariableNames;
        if ~any(inx)
            return
        end

        if isequal(inputShift, @auto)
            inputShift = 0;
        end

        pos = find(inx);
        output.Type = "Transform";
        output.Transform = transform;
        output.Incidence = [complex(pos, inputShift), complex(pos, inputShift-1)];
        output.Position = pos;
        output.Shift = inputShift;
    end%




    function hereParseTransform( )
        x__ = inputSpecs;
        if ~endsWith(x__, ")")
            x__ = "(" + x__ + ")";
        end
        pattern = "^(|" + join(regression.Term.REGISTERED_TRANSFORMS, "|") + ")\((\<\w+\>)(\{[^\}]+\})?\)$";
        tokens = regexp(x__, pattern, "tokens", "once");
        if numel(tokens)~=3
            return
        end
        inx = tokens(2)==xq.VariableNames;
        sh = 0;
        if strlength(tokens(3))>0
            sh = sscanf(tokens(3), "{%g}"); 
        end
        if ~any(inx) || ~validate.roundScalar(sh)
            return
        end
        transform = string(tokens(1));
        pos = find(inx);
        output.Type = "Transform";
        output.Transform = transform;
        output.Incidence = complex(pos, sh);
        if startsWith(transform, "diff")
            output.Incidence = [output.Incidence, complex(pos, sh-1)];
        end
        output.Position = pos;
        output.Shift = sh;
    end%




    function hereParseExpression( )
        %
        % Expand pseudofunctions
        % diff, difflog, dot, movsum, movavg, movprod, movgeom
        %
        parsedSpecs = parser.Pseudofunc.parse(inputSpecs);

        %
        % Unique names of all control parameters
        %
        controlNames = collectControlNames(xq);

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
        try
            hereParseSpecials( );
            func = str2func("@(x,t,date__,controls__)" + parsedSpecs);
            output.Type = "Expression";
            output.Expression = func;
            output.Incidence = incidence;
        end

        return


            function c = replaceNameShift(c1, c2)
                c = '';
                if string(c1)==string(xq.DateReference)
                    c = 'date__';
                    return
                end
                if any(c1==controlNames)
                    c = "controls__." + c1;
                    return
                end
                pos = getPosName(xq, c1);
                sh = 0;
                if isnan(pos)
                    invalidNames = [invalidNames, string(c1)];
                    return
                end
                if nargin>=2 && ~isempty(c2) && ~strcmp(c2, '{}') && ~strcmp(c2, '{0}')
                    sh = str2num(c2(2:end-1));
                    if ~validate.numericScalar(sh) || ~isfinite(sh)
                        invalidShifts = [invalidShifts, string(c2)];
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


            function hereParseSpecials( )
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

