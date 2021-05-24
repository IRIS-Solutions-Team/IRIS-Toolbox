% White  Auxiliary class for whiting out quoted or bracketed text in source code

classdef White
    properties (Constant)
        % LABEL_PATTERN  Regexp pattern to match labels in IRIS source files
        LABEL_PATTERN = '"[^"\n]*"|''[^''\n]*''' 

        % WHITEOUT_CHAR  Default white-out character
        WHITEOUT_CHAR = ' '
    end


    methods (Static)
        function whiteCode = whiteOutLabels(code)
            whiteCode = char(code);
            [from, to] = regexp(whiteCode, parser.White.LABEL_PATTERN, "start", "end");
            whiteCode = parser.White.whiteOut(whiteCode, from+1, to-1, parser.White.WHITEOUT_CHAR);
        end%


        function code = whiteOutParenth(code, level)
            code = char(code);
            code = [code, parser.White.WHITEOUT_CHAR];
            x = zeros(1, numel(code), 'int8');
            x(code=='(') = 1;
            x(find(code==')')+1) = -1;
            code(cumsum(x)>=level) = parser.White.WHITEOUT_CHAR;
            x = zeros(1, numel(code), 'int8');
            x(code=='[') = 1;
            x(find(code==']')+1) = -1;
            code(cumsum(x)>=level) = parser.White.WHITEOUT_CHAR;
            code(end) = '';
        end%


        function whiteCode = whiteOut(whiteCode, from, to, white)
            for i = 1 : numel(from)
                whiteCode(from(i):to(i)) = white;
            end
        end%
    end
end
