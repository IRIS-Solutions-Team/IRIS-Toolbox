classdef Control < handle
    methods (Abstract)
        varargout = writeFinal(varargin)
    end

    
    methods (Static)
        function parse(p)
            import parser.control.CodeSegments

            this = CodeSegments(p.Code, p.White);
            c = writeFinal(this, p);
            p.Code = c;
            p.White = [ ];
        end%
    end
end
