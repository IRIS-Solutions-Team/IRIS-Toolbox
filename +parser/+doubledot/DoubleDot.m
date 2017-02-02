classdef DoubleDot < handle
    methods (Static)
        function c = parse(p)
            import parser.doubledot.*;
            isCharInp = ischar(p);
            if isCharInp
                c = p;
            else
                c = p.Code;
            end
            allKeywords = enumeration('parser.doubledot.Keyword');
            for key = allKeywords.'
                if isempty( strfind(c, key.Pattern) )
                    continue
                end
                c = parse(key, c);
            end
            if ~isCharInp
                p.Code = c;
            end
        end
    end
end
