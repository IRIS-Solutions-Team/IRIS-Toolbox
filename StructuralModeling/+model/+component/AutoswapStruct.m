% Autoswap  Helper class to support legacy behavior

classdef (CaseInsensitiveProperties=true) ...
         AutoswapStruct

    properties
        Simulate 
        Steady
    end


    properties (Dependent, Hidden)
        Dynamic
    end


    methods
        function flag = isstruct(this)
            flag = true;
        end%


        function flag = isfield(this, field)
            flag = any(strcmpi(field, {'Simulate', 'Steady', 'Dynamic'}));
        end%


        function value = get.Dynamic(this)
            value = this.Simulate;
        end%


        function this = set.Dynamic(this, value)
            this.Simulate = value;
        end%
    end
end

