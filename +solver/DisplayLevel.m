classdef DisplayLevel
    properties
        Any = false
        Iter = false
        Final = false
        Every = NaN
    end


    methods
        function this = DisplayLevel(displayOption)
            this.Any = ...
                ~isequal(displayOption, false) ...
                && ~strcmpi(displayOption, 'none') ...
                && ~strcmpi(displayOption, 'off');
            this.Final = this.Any;
            this.Iter = ...
                isequal(displayOption, true) ...
                || strcmpi(displayOption, 'iter') ...
                || strcmpi(displayOption, 'iter*') ...
                || (isnumeric(displayOption) && displayOption~=0);
            if isnumeric(displayOption)
                this.Every = displayOption;
            elseif isequal(this.Iter, true)
                this.Every = 1;
            end
        end%
    end
end




