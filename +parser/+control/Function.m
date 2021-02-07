classdef Function < parser.control.Export
    properties
        FirstLine
    end
    
    
    
    
    properties (Constant)
        FUNCTION_NAME_PATTERN1 = '(?<=^\s*function\s*\w+\s*=\s*)\w+' % Pattern for matching file name of a function m-file.
        FUNCTION_NAME_PATTERN2 = '(?<=^\s*function\s*\[.*?\]\s*=\s*)\w+' % Pattern for matching file name of a function m-file.
    end


    
    
    methods
        function this = Function(varargin)
            if isempty(varargin)
                return
            end
            c = varargin{1};
            sh = varargin{2};
            construct(this, c, sh);
        end

        
        
        
        function construct(this, c, sh)
            import parser.control.*;
            c0 = c;
            key = Keyword.FUNCTION;
            [fileName, firstLine, c, sh] = Function.getFunctionName(key, c, sh);
            if isempty(fileName)
                error('IRIS:Preparser:Controls:MissingFunctionFileName', c0);
            end
            this.FileName = string(fileName) + ".m";
            this.FirstLine = firstLine;
            this.Body = CodeSegments(c, [ ], sh);
        end
        
        
        
        
        function c = completeFileContents(this, c)
            BR = sprintf('\n');
            indent = regexp(this.FirstLine, '^\s*', 'match', 'once');
            c = [ this.FirstLine, c, BR, indent, 'end' ];
        end
    end
    
    
    
    
    methods (Static)
        function [fileName, firstLine, c, sh] = getFunctionName(key, c, sh)
            import parser.control.*
            c0 = c;
            [firstLine, to] = regexp(c, '^[^\n]*\n', 'once', 'match', 'end');
            c = c(to+1:end);
            sh = sh(to+1:end);
            firstLine = strrep(firstLine, toChar(key), 'function');
            fileName = regexp(firstLine, Function.FUNCTION_NAME_PATTERN1, 'once', 'match');
            if isempty(fileName)
                fileName = regexp(firstLine, Function.FUNCTION_NAME_PATTERN2, 'once', 'match');
                if isempty(fileName)
                    throwCode ( exception.ParseTime('Preparser:CTRL_MISSING_FILE_NAME', 'error'), c0 );
                end
            end
            fileName = string(fileName);
        end%
    end
end
