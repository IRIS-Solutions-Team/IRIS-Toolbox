%Interp  Interpolate Matlab expressions within model code

classdef Interp
    properties (Constant)
        OPEN = char(171) % «
        CLOSE = char(187) % »
    end


    methods (Static)
        function [resolvedCode, clearCode, tokens] = parse(prep, code)
            if nargin<2 || isempty(code)
                code = prep.Code;
            end
            
            % Default output arguments for early return
            resolvedCode = string(code);
            clearCode = resolvedCode;
            tokens = string.empty(1, 0);
            
            if strlength(code)==0
                return
            end 

            whiteCode = parser.White.whiteOutLabels(code);
            [code, whiteCode] = parser.Interp.replaceSquareBrackets(code, whiteCode);
            if prep.AngleBrackets
                [code, ~] = parser.Interp.replaceAngleBrackets(code, whiteCode);
            end

            sh = parser.Interp.createShadowCode(code, parser.Interp.OPEN, parser.Interp.CLOSE);


            % If no Matlab expression brackets, return immediately
            if nnz(sh)==0
                return
            end


            % Verify that all Matlab expression brackets are matched
            level = cumsum(sh);
            if any(level>1) || any(level<0) || level(end)~=0
%                posNested = find(level>1, 1);
%                 report = eraseAfter(string(code), posNested-1)
%                 if strlen(report)>30
%                     report = extractBefore(report, 30) + string(char(8230))
%                 end
                exception.error([
                    "Parser:InvalidBackets"
                    "Unmatched, invalid or missing brackets around this place: %s"
                ], code);
            end


            % By now, the code is guaranteed to have pairs of properly
            % opened/closed brackets enclosing matlab expressions to be
            % evaluated. Splitting the code means that the output vector of
            % strings alternate expressions outside and inside the
            % brackets, starting always outside

            splitCode = split(string(code), [string(parser.Interp.OPEN), string(parser.Interp.CLOSE)]);


            resolvedCode = splitCode;
            clearCode = splitCode;
            tokens = string.empty(1, 0);

            for i = 2 : 2 : numel(splitCode)
                if contains(splitCode(i), "?")
                    throwCode(exception.ParseTime([
                        "Preparser:UnresolvedForControl"
                        "This Matlab expression contains an unresolved or unknown reference "
                        "to a !for control variable(s): %s "
                    ], "error"), splitCode(i));
                end
                expression = strip(splitCode(i));
                try
                    evaluated = prep.Assigned.(expression);
                catch
                    try
                        evaluated = parser.Preparser.eval(expression, prep.Assigned);
                    catch Err
                        exception.error([
                            "Preparser:MatlabExpressionFailed"
                            "Error evaluating this Matlab expression: %s"
                            "Matlab says %s"
                        ], expression, Err.message);
                    end
                end
                try
                    addTokens = parser.Interp.anyToString(evaluated);
                catch
                    exception.error([
                        "Preparser:MatlabExpressionFailed"
                        "Error evaluating this Matlab expression: %s"
                    ], expression);
                end
                resolvedCode(i) = join(addTokens, ", ");
                clearCode(i) = " ";
                tokens = [tokens, addTokens];
            end
            resolvedCode = join(resolvedCode, "");
            clearCode = join(clearCode, "");
        end%


        function sh = createShadowCode(whiteCode, strOpen, strClose)
            sh = zeros(1, numel(whiteCode), 'int8');
            posOpen = strfind(whiteCode, strOpen);
            if ~isempty(posOpen)
                sh(posOpen) = 1;
            end
            posClose = strfind(whiteCode, strClose);
            if ~isempty(posClose)
                sh(posClose) = -1;
            end
        end%


        function value = anyToString(value)
            if isstring(value) || iscellstr(value)
                value = reshape(string(value), 1, []);
                return
            end

            % Split char vectors into individual characters
            if ischar(value)
                value = split(string(value), "");
                value(strlength(value)==0) = [];
                value = reshape(value, 1, []);
                return
            end

            if isnumeric(value) || islogical(value)
                value = reshape(string(value), 1, []);
                return
            end

            if iscell(value)
                value = arrayfun(@(x) string(x{:}), value);
                return
            end

            exception.error([
                "Parser:CannotInterpretAsString"
                "Unable to interpret the input value as a vector of strings."
            ]);
        end%


        function [code, whiteCode] = replaceSquareBrackets(code, whiteCode)
            whiteCode = char(whiteCode);
            code = char(code);
            posOpen = strfind(whiteCode, "$["); 
            replace = [parser.Interp.OPEN, ' '];
            for pos = [posOpen; posOpen+1]
                whiteCode(pos) = replace;
                code(pos) = replace;
            end
            posClose = strfind(whiteCode, "]$");
            replace = [' ', parser.Interp.CLOSE];
            for pos = [posClose; posClose+1]
                whiteCode(pos) = replace;
                code(pos) = replace;
            end
        end%


        function [code, whiteCode] = replaceAngleBrackets(code, whiteCode)
            whiteCode = char(whiteCode);
            code = char(code);
            posOpen = strfind(whiteCode, "<"); 
            for i = 1 : numel(posOpen)
                whiteCode(posOpen) = parser.Interp.OPEN;
                code(posOpen) = parser.Interp.OPEN;
            end
            posClose = strfind(whiteCode, ">");
            for i = 1 : numel(posClose)
                whiteCode(posClose) = parser.Interp.CLOSE;
                code(posClose) = parser.Interp.CLOSE;
            end
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

if ~verLessThan('matlab', '9.9')
    open = string(parser.Interp.OPEN);
    open = string(parser.Interp.OPEN);
    close = string(parser.Interp.CLOSE);
    p = parser.Preparser( );
    p.Assigned = struct('A', 1, 'B', [3, 4]);
    p.Code = " aaaa " + open + " A+1 " + close + " " + open + " B+2 " + close + " ";
    [act, actClear, actTokens] = parser.Interp.parse(p);
    exp = " aaaa 2 5, 6 ";
    expTokens = string([2, 5, 6]);
    assertEqual(testCase, act, exp);
    act = parser.Interp.parse(p, p.Code);
    assertEqual(testCase, act, exp);
    assertEqual(testCase, actClear, join([" aaaa ", " ", " ", " ", " "], ""));
    assertEqual(testCase, actTokens, string([2, 5, 6]));
end


%% Test Square Brackets 

    p = parser.Preparser( );
    p.Assigned = struct('A', 1, 'B', [3, 4]);
    p.Code = " aaaa $[ A+1 ]$ $[ B+2 ]$ ";
    act = parser.Interp.parse(p);
    exp = " aaaa 2 5, 6 ";
    assertEqual(testCase, act, exp);
    act = parser.Interp.parse(p, p.Code);
    assertEqual(testCase, act, exp);


%% Test Angle Brackets 

    p = parser.Preparser( );
    p.Assigned = struct('A', 1, 'B', [3, 4]);
    p.Code = " aaaa < A+1 > < B + 2 > ";
    act = parser.Interp.parse(p);
    exp = " aaaa 2 5, 6 ";
    assertEqual(testCase, act, exp);
    act = parser.Interp.parse(p, p.Code);
    assertEqual(testCase, act, exp);


%% Test Angle Brackets when AngleBrackets=false

    p = parser.Preparser( );
    p.Assigned = struct('A', 1);
    p.AngleBrackets = false;
    p.Code = " aaaa < A+1 > < B + 2 > ";
    act = parser.Interp.parse(p);
    exp = string(p.Code);
    assertEqual(testCase, act, exp);

##### SOURCE END #####
%}

