function this = parseInputSpecs(this, expy, inputSpecs, type)
% parseInputSpecs  Parse input specification of DependentTerm or
% ExplanatoryTerms
%{
% Backend [IrisToolbox] method
% No help provided
%}

% -[IrisToolbox] for Macroeconomic Modeling
% -Copyright (c) 2007-2022 [IrisToolbox] Solutions Team

LIST_TRANSFORMS = ["log", "exp", "roc", "pct", "diff", "difflog"];

%--------------------------------------------------------------------------

if ~isa(inputSpecs, 'string')
    hereThrowInvalidSpecification( );
end
% Remove white spaces and leading plus signs
inputSpecs = erase(string(inputSpecs), [" ", "\t"]);
while startsWith(inputSpecs, "+")
    inputSpecs = eraseBetween(inputSpecs, 1, 1);
end
isLhs = lower(type)=="lhs";


%
% Plain variable name or variables name and shift
%
if hereTryNameShift( )==0
    return
end


%
% Registered transform
%
if isLhs && hereTryRegisteredTransform( )==0
    return
end


%
% Expression as anonymous function
%
if ~isLhs 
    hereTryExpression( );
    return
end

hereThrowInvalidSpecification( );

return

    function status = hereTryNameShift( )
        %(
        status = 1;
        tokens = strip(split(string(inputSpecs), ["{", "}"]));

        if numel(tokens)==1
            name = tokens(1);
            shift = 0;
        elseif numel(tokens)==3 && strlength(tokens(3))==0
            name = tokens{1};
            shift = eval(tokens{2});
            if ~validate.roundScalar(shift) || (isLhs && shift~=0)
                return
            end
        else
            return
        end
        inx = name==expy.VariableNames;
        if ~any(inx)
            return
        end

        %
        % Success
        %
        status = 0;
        pos = find(inx);
        this.InputString = inputSpecs;
        this.Position = pos;
        this.Shift = shift;
        this.Incidence = complex(pos, shift);
        if shift==0
            timeString = "t";
        elseif shift<0
            timeString = "t-" + string(abs(shift));
        else
            timeString = "t+" + string(shift);
        end
        this.Expression = "x(" + this.Position + "," + timeString + ",v)";
        this.InverseTransform = [ ];
        %)
    end%


    function status = hereTryRegisteredTransform( )
        % (
        status = 1;
        if ~startsWith(inputSpecs, LIST_TRANSFORMS+"(") || ~endsWith(inputSpecs, ")")
            return
        end

        transform = extractBefore(inputSpecs, "(");
        args = extractBetween( ...
            inputSpecs, strlength(transform)+1, strlength(inputSpecs) ...
            , "boundaries", "exclusive" ...
        );
        args = parser.splitout(args);
        if isempty(args) || args(1)==""
            return
        end
        name = args(1);
        inxName = name==expy.VariableNames;
        if ~any(inxName)
            return
        end


        switch transform
            case {"log", "exp"}
                diffops = double.empty(1, 0);
                resolvedSpecs = inputSpecs;
            case {"diff", "difflog"}
                if numel(args)<2
                    diffops = -1;
                else
                    diffops = reshape(str2num(args(2)), 1, [ ]);
                    if ~isnumeric(diffops) || isempty(diffops)
                        diffops = -1;
                    end
                end
                pseudofuncObj = parser.Pseudofunc.(upper(transform));
                resolvedSpecs = expand(pseudofuncObj, name, diffops);
            case {"roc", "pct"}
                pseudofuncObj = parser.Pseudofunc.(upper(transform));
                if numel(args)<2
                    diffops = -1;
                else
                    diffops = diffops(1);
                end
                pseudofuncObj = parser.Pseudofunc.(upper(transform));
                resolvedSpecs = expand(pseudofuncObj, name, diffops);
        end

        if any(diffops>=0)
            exception.error([
                "Explanatory:InvalidTimeShift"
                "The dependent term of the Explanatory object contains a lead of the LHS variable, "
                "which is not allowed: %s "
            ], inputSpecs);
        end

        [resolvedSpecs, incidence] = locallyParseExpression(expy, resolvedSpecs);
        pos = find(inxName);
        this.InputString = inputSpecs;
        this.Position = find(inxName);
        this.Shift = 0;
        this.Incidence = incidence;
        this.Expression = resolvedSpecs;
        this.InverseTransform = locallyCreateInverseTransform(transform, diffops, this.Position);
        status = 0;
        %)
    end%


    function status = hereTryExpression( )
        % (
        resolvedSpecs = locallyPreparseSpecials(expy, inputSpecs);
        resolvedSpecs = parser.Pseudofunc.parse(resolvedSpecs);
        [resolvedSpecs, incidence] = locallyParseExpression(expy, resolvedSpecs);
        resolvedSpecs = locallyPostparseSpecials(expy, resolvedSpecs);
        this.Expression = resolvedSpecs;
        this.InputString = inputSpecs;
        this.Incidence = incidence;
        %)
    end%


    function hereThrowInvalidSpecification( )
        exception.error([
            "Regression:InvalidTermSpecification"
            "Cannot parse this regression.Term specification: %s " 
        ], inputSpecs);
    end%
end%

%
% Local Functions
%

function incidence = locallyCreateIncidence(pos, shifts, transform)
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


function [resolvedSpecs, incidence] = locallyParseExpression(expy, resolvedSpecs)
    %
    % Unique names of all control parameters
    %
    controlNames = collectControlNames(expy);
    %
    % Replace name{k} with x(pos, t+k, v)
    % Replace name with x(pos, t, v)
    %
    incidence = double.empty(1, 0);
    invalidNames = string.empty(1, 0);
    invalidShifts = string.empty(1, 0);
    replaceFunc = @replaceNameShift;
    resolvedSpecs = regexprep(resolvedSpecs, Explanatory.VARIABLE_WITH_SHIFT, "${replaceFunc($1, $2)}");
    resolvedSpecs = regexprep(resolvedSpecs, Explanatory.VARIABLE_NO_SHIFT, "${replaceFunc($1)}");
    resolvedSpecs = replace(resolvedSpecs, ",$$", ",t");
    resolvedSpecs = replace(resolvedSpecs, ",::)", ",v)");
    if ~isempty(invalidNames)
        hereThrowInvalidNames( );
    end
    %
    % Vectorize operators
    %
    resolvedSpecs = vectorize(resolvedSpecs);
    incidence = unique(incidence, "stable");

    return

        function c = replaceNameShift(c1, c2)
            c = '';
            c1 = string(c1);
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
                c = sprintf('x(%g,$$,::)', pos);
            else
                c = sprintf('x(%g,$$%+g,::)', pos, sh);
            end
            incidence = [incidence, complex(pos, sh)];
        end%


        function hereThrowInvalidNames( )
            exception.error([
                "RegressionTerm:InvalidName"
                "This name occurs in a regression.Term definition "
                "but is not on the list of Explanatory.VariableNames: %s " 
            ], string(invalidNames));
        end%
end%


function specs = locallyPreparseSpecials(expy, specs)
    %
    % Substitute for AR terms
    % diff, difflog, dot, movsum, movavg, movprod, movgeom
    %
    %(
    if contains(specs, expy.LhsReference)
        lhs = expy.DependentTerm.InputString;
        % LHS reference with time shift
        specs = regexprep( ...
            specs ...
            , "\<" + expy.LhsReference + "\>\{([^\}]*)\}" ...
            , "${parser.Pseudofunc.shiftTimeSubs(""" + lhs + """, $1)}" ...
        );
        % LHS reference with no time shift
        specs = regexprep( ...
            specs, "\<" + expy.LhsReference + "\>", lhs ...
        );
    end
    %)
end%


function specs = locallyPostparseSpecials(expy, specs)
    % Replace `ifnan(` with `simulate.ifnan(`
    specs = regexprep(specs, "(?<!\.)\<ifnan\(", "simulate.ifnan(");
    % Replace `if(` with `simulate.if(`
    specs = regexprep(specs, "(?<!\.)\<if\(", "simulate.if(");
    % Replace @(k) with p(k)
    specs = regexprep(specs, "@\((\d+)\)", "p($1)");
end%


function build = locallyCreateInverseTransform(transform, diffops, posLhs)
    if isempty(diffops)
        poly = 1;
    else
        poly = [1, zeros(1, -diffops(1)-1), -1];
        for i = reshape(diffops(2:end), 1, [ ])
            poly = conv(poly, [1, zeros(1, -i-1), -1]);
        end
    end

    dataRow = "x(" + string(posLhs);
    switch transform
        case "log"
            build = "exp(__lhs)";
        case "exp"
            build = "log(__lhs)";
        case "roc"
            build = "__lhs.*" + dataRow + ", t-" + string(-diffops) + ",v)";
        case "pct"
            build = "(1+__lhs/100).*" + dataRow + ",t-" + string(-diffops) + ",v)";
        case {"diff", "difflog"}
            build = "__lhs";
            poly1 = -poly(2:end);
            for lag = find(poly1~=0)
                coeff = poly1(lag);
                if coeff==1
                    coeff = "+";
                elseif coeff==-1
                    coeff = "-";
                else
                    coeff = sprintf("%+g*", coeff);
                end
                p = dataRow + ",t-" + lag + ",v)";
                if transform=="difflog"
                    p = "log(" + p + ")";
                end
                build = build + coeff + p;
            end
            if transform=="difflog"
                build = "exp(" + build + ")";
            end
    end
end%

