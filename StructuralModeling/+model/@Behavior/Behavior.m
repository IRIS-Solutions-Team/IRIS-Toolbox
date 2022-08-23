classdef Behavior
    properties
        InvalidDotAssign = 'Error'
        InvalidDotReference = 'Error'
        DotReferenceFunc = [ ]
        LogStyleInSolutionVectors (1, 1) string = string(model.Quantity.LOG_PREFIX)
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
            elseif strcmpi(newValue, 'Silent')
                this.InvalidDotAssign = 'Silent';
                return
            else
                specs = { 'Behavior:InvalidDotAssign'
                          'Invalid value assigned to Behavior.InvalidDotAssign: %s'
                          '\HValue assigned to Behavior.InvalidDotAssign '
                          'must be one of {''Error'', ''Warning'', ''Silent''} ' };
                throw(exception.Base(specs, 'error'), newValue);
            end
        end%


        function this = set.InvalidDotReference(this, newValue)
            if strcmpi(newValue, 'Error')
                this.InvalidDotReference = 'Error';
                return
            elseif strcmpi(newValue, 'Warning')
                this.InvalidDotReference = 'Warning';
                return
            elseif strcmpi(newValue, 'Silent')
                this.InvalidDotReference = 'Silent';
                return
            else
                specs = { 'Behavior:InvalidDotReference'
                          'Invalid value assigned to Behavior.InvalidDotReference: %s'
                          '\HValue assigned to Behavior.InvalidDotReference '
                          'must be one of {''Error'', ''Warning'', ''Silent''} ' };
                throw(exception.Base(specs, 'error'), newValue);
            end
        end%


        function this = set.DotReferenceFunc(this, newValue)
            if isempty(newValue)
                this.DotReferenceFunc = [ ];
                return
            elseif isa(newValue, 'function_handle')
                this.DotReferenceFunc = newValue;
                return
            else
                throw( exception.Base('Behavior:DotReferenceFunc', 'error') );
            end
        end%


        function this = set.LogStyleInSolutionVectors(this, newValue)
            newValue = string(newValue);
            if newValue=="log()" || newValue==string(model.Quantity.LOG_PREFIX)
                this.LogStyleInSolutionVectors = newValue;
                return
            end
            exception.error([
                "Behavior:InvalidLogStyle"
                "LogStyleInSolutionVectors is allowed to be assigned"
                "one of {""log()"", ""%s""} only."
            ], string(model.Quantity.LOG_PREFIX));
        end%
    end
end

