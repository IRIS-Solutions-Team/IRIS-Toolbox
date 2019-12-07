function output = parseInputSpecs(xq, inputSpecs, types)

% Invoke unit tests
%(
if nargin==1 && isequal(xq, '--test')
    output = functiontests({ @setupOnce 
                             @pointerTest
                             @nameTest
                             @nameShiftTest
                             @transformTest
                             @expressionTest });
    return
end
%)


if nargin<3
    types = @all;
end

%--------------------------------------------------------------------------

output = struct( );
output.Type = "";

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


inputSpecs = string(inputSpecs);
inputSpecs = replace(inputSpecs, " ", "");

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
% Registered transform
%
if isequal(types, @all) || any(types=="Transform")
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
        output.Type = "Pointer";
        output.Position = inputSpecs;
    end%




    function hereParseName( )
        inx = inputSpecs==xq.VariableNames;
        if ~any(inx)
            return
        end
        output.Type = "Name";
        output.Position = find(inx);
    end%




    function hereParseTransform( )
        x_ = inputSpecs;
        if ~endsWith(x_, ")")
            x_ = "(" + x_ + ")";
        end
        pattern = "^(|" + join(regression.Term.REGISTERED_TRANSFORMS, "|") + ")\((\<\w+\>)(\{[^\}]+\})?\)$";
        tokens = regexp(x_, pattern, "tokens", "once");
        if numel(tokens)~=3
            return
        end
        inx = tokens(2)==xq.VariableNames;
        shift = 0;
        if strlength(tokens(3))>0
            shift = sscanf(tokens(3), "{%g}"); 
        end
        if any(inx) && validate.roundScalar(shift)
            output.Type = "Transform";
            output.Position = find(inx);
            output.Shift = shift;
            output.Transform = tokens(1);
        end
    end%




    function hereParseExpression( )
        %
        % Expand pseudofunctions
        % diff, difflog, dot, movsum, movavg, movprod, movgeom
        %
        parsedSpecs = parser.Pseudofunc.parse(inputSpecs);

        %
        % Replace name{k} with x(pos, t+k, :)
        % Replace name with x(pos, t, :)
        %
        positions = double.empty(1, 0);
        shifts = 0;
        invalidNames = string.empty(1, 0);
        invalidShifts = string.empty(1, 0);
        replaceFunc = @replaceNameShift;
        parsedSpecs = regexprep(parsedSpecs, "(\<[A-Za-z]\w*\>)(\{[^\}]*\})", "${replaceFunc($1, $2)}");
        parsedSpecs = regexprep(parsedSpecs, "(\<[A-Za-z]\w*\>)(?!\()", "${replaceFunc($1)}");
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
            func = str2func("@(x, t) " + parsedSpecs);
            output.Type = "Expression";
            output.Expression = func;
            output.Positions = sort(unique(positions, 'stable'));
            output.Shifts = sort(shifts);
        end
        return

            function c = replaceNameShift(c1, c2)
                c = '';
                pos = getPositionOfName(xq, c1);
                if isnan(pos)
                    invalidNames = [invalidNames, string(c1)];
                    return
                end
                positions = [positions, pos];
                if nargin<2 || isempty(c2) || strcmp(c2, '{}')
                    c = sprintf('x(%g, $, :)', pos);
                    return
                end
                sh = str2num(c2(2:end-1));
                if ~validate.numericScalar(sh) || ~isfinite(sh)
                    invalidShifts = [invalidShifts, string(c2)];
                end
                if sh ==0
                    c = sprintf('x(%g, t, :)', pos);
                    return
                else
                    shifts = [shifts, sh];
                    c = sprintf('x(%g, $%+g, :)', pos, sh);
                    return
                end
            end%


            function hereThrowInvalidNames( )
                invalidNames = cellstr(invalidNames);
                thisError = [ 
                    "RegressionTerm:InvalidName"
                    "This name occurs in a regression.Term definition "
                    "but is not on the list of ExplanatoryEquation.VariableNames: %s " 
                ];
                throw(exception.Base(thisError, "error"), invalidNames{:});
            end%
        end%


    function hereThrowInvalidPointer( )
        thisError = [ 
            "RegressionTerm:InvalidPointerToVariableNames"
            "Regression term specification points to a non-existing position "
            "in the ExplanatoryEquation.VariableNames list: %g " 
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
% Unit Tests
%
%(
function setupOnce(testCase)
    m = ExplanatoryEquation( );
    m.VariableNames = ["x", "y", "z"];
    testCase.TestData.Model = m;
end%


function pointerTest(testCase)
    m = testCase.TestData.Model;
    for ptr = 1 : numel(m.VariableNames);
        act = regression.Term.parseInputSpecs(m, ptr);
        exp = struct( );
        exp.Type = "Pointer";
        exp.Position = ptr;
        assertEqual(testCase, act, exp);
    end
end%


function nameTest(testCase)
    m = testCase.TestData.Model;
    for name = m.VariableNames
        act = regression.Term.parseInputSpecs(m, name);
        exp = struct( );
        exp.Type = "Name";
        exp.Position = find(name==m.VariableNames);
        assertEqual(testCase, act, exp);
    end
end%


function nameShiftTest(testCase)
    m = testCase.TestData.Model;
    for name = m.VariableNames
        act = regression.Term.parseInputSpecs(m, name + "{-1}");
        exp = struct( );
        exp.Type = "Transform";
        exp.Position = find(name==m.VariableNames);
        exp.Shift = -1;
        exp.Transform = "";
        assertEqual(testCase, act, exp);
    end
end%


function transformTest(testCase)
    m = testCase.TestData.Model;
    for name = m.VariableNames
        for transform = regression.Term.REGISTERED_TRANSFORMS
            shift = randi(5)-10;
            shiftSpecs = sprintf("{%g}", shift);
            act = regression.Term.parseInputSpecs(m, transform + "(" + name + shiftSpecs + ")");
            exp = struct( );
            exp.Type = "Transform";
            exp.Position = find(name==m.VariableNames);
            exp.Shift = shift;
            exp.Transform = transform;
            assertEqual(testCase, act, exp);
        end
    end
end%


function expressionTest(testCase)
    m = testCase.TestData.Model;
    act = regression.Term.parseInputSpecs(m, "x + movavg(y, -2) - z{+3}");
    exp = struct( );
    exp.Type = "Expression";
    exp.Expression = @(x,t)x(1,t,:)+(((x(2,t,:))+(x(2,t-1,:)))./2)-x(3,t+3,:);
    exp.Positions = [1, 2, 3];
    exp.Shifts = [-1, 0, 3];
    act.Expression = func2str(act.Expression);
    exp.Expression = func2str(exp.Expression);
    assertEqual(testCase, act, exp);
end%
%)

