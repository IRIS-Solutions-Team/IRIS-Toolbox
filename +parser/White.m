classdef White
    % White  Auxiliary class for whiting out quoted or bracketed text in source code.
    
    
    
    
    properties (Constant)
        LABEL_PATTERN = '"[^"\n]*"|''[^''\n]*''' % Regexp pattern to match labels in IRIS source files.
        WHITEOUT_CHAR = ' ' % Default white-out character.
    end
    
    
    
    
    methods (Static)
        function code = whiteOutLabel(code)
            import parser.White;
            [from, to] = regexp(code,White.LABEL_PATTERN, 'start', 'end');
            code = White.whiteOut(code, from+1, to-1, White.WHITEOUT_CHAR);
        end
        
        
        function code = whiteOutParenth(code, level)
            import parser.White;
            code = [code, White.WHITEOUT_CHAR];
            x = zeros(1, length(code), 'int8');
            x( code=='(' ) = 1;
            x( find(code==')')+1 ) = -1;
            code( cumsum(x)>=level ) = White.WHITEOUT_CHAR;
            x = zeros(1, length(code), 'int8');
            x( code=='[' ) = 1;
            x( find(code==']')+1 ) = -1;
            code( cumsum(x)>=level ) = White.WHITEOUT_CHAR;
            code(end) = '';
        end
        
            
        function c = whiteOut(c, from, to, white)
            for i = 1 : length(from)
                c( from(i):to(i) ) = white;
            end
        end
    end
end
