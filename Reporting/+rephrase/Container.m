classdef Container ...
    < matlab.mixin.Copyable

    properties (Abstract, Constant)
        CanBeParentOf 
    end


    methods
        function add(this, child)
            if ~any(child.Type==this.CanBeParentOf)
                thisError = [
                    "Rephrase:InvalidChild"
                    "Rephrase element of type %s cannot be added to %s."
                ];
                throw(exception.Base(thisError, 'error'), string(child.Type), string(this.Type));
            end
            child.Parent = this;
            this.Content{end+1} = child;
        end%
    end
end
