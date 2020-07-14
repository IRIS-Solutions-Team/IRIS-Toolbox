classdef Interp
    properties (Constant)
        OPEN = char(171) % «
        CLOSE = char(187) % »
    end
    
    
    methods (Static)
        function [code, values] = parse(p, code, remove)
            import parser.Interp
            import parser.Preparser

            try, code;
                catch, code = @auto; end

            % If remove=true, do not interpolate in the code, remove the
            % <...> segment, and only return string representation of the
            % values
            try, remove;
                catch, remove = false; end

            codeFromObject = isequal(code, @auto);
            if codeFromObject
                code = p.Code;
            end

            code = parser.Interp.replaceSquareBrackets(code);
            if p.AngleBrackets
                code = parser.Interp.replaceAngleBrackets(code);
            end

            sh = Interp.createShadowCode(code, Interp.OPEN, Interp.CLOSE);
            level = cumsum(sh);
            if any(level>1)
                posNested = find(level>1, 1);
                throwCode( ...
                    exception.ParseTime('Preparser:INTERP_NESTED', 'error'), ...
                    code(posNested:end) ...
                );
            end

            values = cell.empty(1, 0);
            while true
                posOpen = find(level==1, 1);
                if isempty(posOpen)
                    break
                end
                posClose = posOpen + find(level(posOpen+1:end)==0, 1);
                if isempty(posClose)
                    thisError = [ 
                        "Preparser:InterpolationStringNotClosed"
                        "This interpolation string is not closed: %s "
                    ];
                    throwCode( ...
                        exception.ParseTime(thisError, 'error'), ...
                        code(posOpen+1:end) ...
                    );
                end
                expn = code(posOpen+1:posClose-1);
                try
                    addValues = Preparser.eval(expn, p.Assigned);
                    addValues = Interp.any2cellstr(addValues);
                    insertCode = "";
                    if ~remove && ~isempty(addValues)
                        insertCode = join(string(addValues), ",");
                    end
                    values = [values, addValues];
                catch
                    throwCode( ...
                        exception.ParseTime('Preparser:InterpEvalFailed', 'error'), ...
                        code(posOpen:posClose) ...
                    );
                end
                before = posOpen - 1;
                after = posClose + 1;
                code = [code(1:before), char(insertCode), code(after:end)];
                level = [level(1:before), zeros(1, strlength(insertCode), 'int8'), level(after:end)];
            end

            if codeFromObject
                % Update the input Preparser object; it is a handle object
                % and does not need to be returned
                p.Code = code;
            end
        end%
        
        
        
        
        function sh = createShadowCode(c, strOpen, strClose)
            import parser.Interp;
            sh = zeros(1, length(c), 'int8');
            posOpen = strfind(c, strOpen);
            if ~isempty(posOpen)
                sh(posOpen) = 1;
            end
            posClose = strfind(c, strClose);
            if ~isempty(posClose)
                sh(posClose) = -1;
            end
        end%
        
        
        
        
        function value = any2cellstr(value)
            if isnumeric(value) || islogical(value) || ischar(value)
                value = num2cell(value);
            elseif isstring(value)
                value = cellstr(value);
            elseif ~iscell(value)
                value = { value };
            end
            for i = 1 : numel(value)
                if isempty(value{i})
                    value{i} = char.empty(1, 0);
                elseif ischar(value{i})
                    % Do nothing
                elseif isstring(value{i})
                    value{i} = char(value{i});
                elseif isnumeric(value{i})
                    value{i} = sprintf('%g', value{i});
                elseif isequal(value{i}, true)
                    value{i} = 'true';
                elseif isequal(value{i}, false)
                    value{i} = 'false';
                else
                    error('IRIS:Intermediate', 'Intermediate Error');
                end
            end
        end%




        function code = replaceSquareBrackets(code)
            code = strrep(code, '$[', parser.Interp.OPEN); 
            code = strrep(code, ']$', parser.Interp.CLOSE); 
        end%




        function code = replaceAngleBrackets(code)
            code = strrep(code, '<', parser.Interp.OPEN); 
            code = strrep(code, '>', parser.Interp.CLOSE); 
        end%
    end
end




%
% Unit Tests
%
%{
##### SOURCE BEGIN #####
% saveAs=preparser/InterpUnitTest.m

testCase = matlab.unittest.FunctionTestCase.fromFunction(@(x)x);

%% Test Unicode Brackets

    p = parser.Preparser( );
    p.Assigned = struct('A', 1);
    p.Code = ' aaaa « A+1 » ';
    act = parser.Interp.parse(p);
    exp = ' aaaa 2 ';
    assertEqual(testCase, act, exp);
    act = parser.Interp.parse(p, @auto);
    exp = ' aaaa 2 ';
    assertEqual(testCase, act, exp);


%% Test Square Brackets

    p = parser.Preparser( );
    p.Assigned = struct('A', 1);
    p.Code = ' aaaa $[ A+1 ]$ ';
    act = parser.Interp.parse(p);
    exp = ' aaaa 2 ';
    assertEqual(testCase, act, exp);
    act = parser.Interp.parse(p, @auto);
    exp = ' aaaa 2 ';
    assertEqual(testCase, act, exp);


%% Test Angle Brackets

    p = parser.Preparser( );
    p.Assigned = struct('A', 1);
    p.Code = ' aaaa < A+1 > ';
    act = parser.Interp.parse(p);
    exp = ' aaaa 2 ';
    assertEqual(testCase, act, exp);
    act = parser.Interp.parse(p, @auto)
    exp = ' aaaa 2 ';
    assertEqual(testCase, act, exp);


%% Test Angle Brackets External Code

    p = parser.Preparser( );
    p.Assigned = struct('A', 1);
    code = ' aaaa < A+1 > ';
    act = parser.Interp.parse(p, code);
    exp = ' aaaa 2 ';
    assertEqual(testCase, act, exp);

##### SOURCE END #####
%}

