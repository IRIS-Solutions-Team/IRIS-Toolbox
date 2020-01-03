% irisinp.generic  Base class for input argument objects.
%
% Backend IRIS class.
% No help provided.

% -IRIS Macroeconomic Modeling Toolbox.
% -Copyright (c) 2007-2020 IRIS Solutions Team.

classdef generic < handle
    properties (Abstract)
        ReportName
        Value
        Omitted
        ValidFn
    end
    
    
    methods
        function isValid = validate(this, x, state)
            isValid = false;
            switch nargin(this.ValidFn)
                case 1
                    try
                        isValid = this.ValidFn(x);
                    catch
                        isValid = false;
                    end
                case 2
                    try
                        isValid = this.ValidFn(x, state);
                    catch
                        isValid = false;
                    end
            end
        end
        
        
        function assign(this, x)
            if ~isequal(x, @invalid)
                this.Value = x;
            else
                if isequal(this.Omitted, @error)
                    throw( exception.Base('General:INVALID_INPUT', 'error'), ...
                        this.ReportName );
                else
                    this.Value = this.Omitted;
                end
            end
        end
        
        
        function preprocess(this,varargin) %#ok<INUSD>
        end
    end
end
