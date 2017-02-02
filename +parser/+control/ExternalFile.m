classdef ExternalFile < parser.control.Control
    properties
        FileName = '' % Name of external file.
    end
    
    
    
        
    properties (Constant)
        BRACKET_PATTERN = '(?<=^\s*)\(.*?\)' % Pattern for matching a pair of round brackets with input arguments.
    end
    
    
    
    
    methods (Static)
        function [arg, c, sh] = getBracketArg(key, c, sh)
            import parser.control.*;
            c = c(len(key)+1:end);
            sh = sh(len(key)+1:end);
            [arg, to] = regexp(c, ExternalFile.BRACKET_PATTERN, 'once', 'match', 'end');
            arg = strtrim(arg(2:end-1));
            c = c(to+1:end);
            sh = sh(to+1:end);
        end
    end
end