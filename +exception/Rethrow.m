classdef Rethrow < exception.ParseTime
    properties
        Cause
    end
    
    
    
    
    methods
        function this = Rethrow(cause)
            this.Identifier = cause.identifier;
            this.ThrowAs = 'error';
            this.Message = '%s';
            this.NeedsHighlight = false;
            this.Cause = cause;
        end
        
        
        
        
        
        function throw(this)
            msg = this.Cause.message;
            msg = regexprep(msg, '^[^\n]*\n', '', 'once');
            throw@exception.ParseTime(this, msg);
        end        
    end
end