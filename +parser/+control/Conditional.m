classdef Conditional < parser.control.Control
    methods (Static)
        function [cond, remC, remSh, remLe] = separateCondition(key, c, sh, le)
            import parser.control.Keyword;
            BR = newline( );
            ix = ( c==';' | c==BR ) & le==1;
            pos = find(ix,1);
            % Input string c contains the initial keyword, key.
            if isempty(pos) || any(sh(len(key)+1:pos-1)~=Keyword.NONE)
                % Throw error if end of control condition is not found or control condition
                % includes another control keyword.
                throwCode( ...
                    exception.ParseTime('Preparser:CTRL_UNFINISHED_CONDITION', 'error'), ...
                    c ...
                );
            end
            cond = c(len(key)+1:pos-1);
            % Include the line break but not the semicolon in the remainder.
            if c(pos)==';'
                posRem = pos+1;
            else
                posRem = pos;
            end
            remC = c(posRem:end);
            remSh = sh(posRem:end);
            remLe = le(posRem:end);
        end
    end
end