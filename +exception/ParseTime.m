classdef ParseTime < exception.Base
    properties (Constant)
        PARSETIME_HEADER_FORMAT = ' when parsing %s ';
        PARSETIME_HEADER_EMPTY_FORMAT = ' when parsing input string';
    end
    
    
    
    
    methods
        function this = ParseTime(varargin)
            this = this@exception.Base(varargin{:});
        end

        
        
        
        function header = createHeader(this)
            header = createHeader@exception.Base(this);
            fileName = exception.ParseTime.storeFileName( );
            if ~isempty(fileName)
                addHeader = sprintf( this.PARSETIME_HEADER_FORMAT, ...
                                     fileName );
            else
                addHeader = this.PARSETIME_HEADER_EMPTY_FORMAT;
            end
            header = [header, addHeader];
        end
    end
    
    
    
    
    methods (Static)
        function varargout = storeFileName(varargin)
            persistent FILE_NAME;
            if nargout==0
                if nargin==0
                    FILE_NAME = '';
                else
                    FILE_NAME = varargin{1};
                end
            else
                if isempty(FILE_NAME) || ~ischar(FILE_NAME)
                    FILE_NAME = '';
                end
                varargout{1} = FILE_NAME;
            end
        end
    end
end
