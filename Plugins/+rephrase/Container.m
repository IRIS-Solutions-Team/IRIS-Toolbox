classdef (Abstract) Container ...
    < matlab.mixin.Copyable

    properties (Abstract, Hidden, Constant)
        PossibleChildren
    end


    methods
        function this = add(this, child)
            if ~any(child.Type==this.PossibleChildren)
                thisError = [
                    "Rephrase:InvalidChild"
                    "Rephrase element of type %s cannot be added as a child to %s"
                ];
                throw(exception.Base(thisError, 'error'), string(child.Type), string(this.Type));
            end
            child.Parent = this;
            this.Content{end+1} = child;
        end%


        function this = lt(this, child)
            this = add(this, child);
        end%


        function this = gt(child, this)
            this = add(this, child);
        end%


        function build(this, varargin)
            for i = 1 : numel(this.Content)
                build(this.Content{i}, varargin{:});
                this.DataRequests = [this.DataRequests, this.Content{i}.DataRequests];
            end
            this.DataRequests = unique(this.DataRequests);
        end%
    end
end
