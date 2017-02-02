classdef Pseudofunc < handle
    methods (Static)
        function c = parse(p)
            import parser.pseudofunc.*;
            isCharInp = ischar(p);
            if isCharInp
                c = p;
            else
                c = p.Code;
            end
            allKeywords = enumeration('parser.pseudofunc.Keyword');
            for key = allKeywords.'
                if isempty( strfind(c, key.Type) )
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
