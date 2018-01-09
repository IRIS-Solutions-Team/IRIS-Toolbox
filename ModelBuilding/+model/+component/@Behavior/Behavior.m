classdef Behavior
    properties
        InvalidDotAssign = 'Error'
        DotReferenceFunc = [ ]
        LogStyleInSolutionVectors = model.LOG_PREFIX
    end
    
    
    methods
        varargout = implementGet(varargin)
        varargout = implementSet(varargin)
        varargout = saveobj(varargin)
    end


    methods
        function this = set.InvalidDotAssign(this, newValue)
            if strcmpi(newValue, 'Error')
                this.InvalidDotAssign = 'Error';
                return
            elseif strcmpi(newValue, 'Warning')
                this.InvalidDotAssign = 'Warning';
                return
            else
                throw( ...
                    exception.Base('Behavior:InvalidDotAssign', 'error'), ...
                    newValue ...
                );
            end
        end


        function this = set.DotReferenceFunc(this, newValue)
            if isempty(newValue)
                this.DotReferenceFunc = [ ];
                return
            elseif isa(newValue, 'function_handle')
                this.DotReferenceFunc = newValue;
                return
            else
                throw( ...
                    exception.Base('Behavior:DotReferenceFunc', 'error') ...
                );
            end
        end


        function this = set.LogStyleInSolutionVectors(this, newValue)
            newValue = char(newValue);
            assert( ...
                isequal(newValue, 'log()') || isequal(newValue, model.LOG_PREFIX), ...
                exception.Base('Behavior:LogStyleInSolutionVectors', 'error'), ...
                char(newValue) ...
            );
            this.LogStyleInSolutionVectors = newValue;
        end
    end
end
