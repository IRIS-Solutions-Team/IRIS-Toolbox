classdef (Abstract) Container ...
    < rephrase.Element

    properties
        Id (1, 1) string = ""
    end


    properties (Abstract, Hidden, Constant)
        PossibleChildren
    end


    methods
        function this = add(this, children)
            for child = reshape(children, 1, [])
                if ~ismember(string(child.Type), string(this.PossibleChildren))
                    exception.error([
                        "Rephrase"
                        "Rephrase element of type %s cannot be added as a child to %s"
                    ], string(child.Type), string(this.Type));
                end
                child.Parent = this;
                assignParentSettings(child);
                this.Content{end+1} = child;
            end
        end%


        function this = plus(this, child)
            this = add(this, child);
        end%


        function this = lt(this, child)
            this = add(this, child);
        end%


        function this = gt(child, this)
            this = add(this, child);
        end%


        function flag = isempty(this)
            flag = isempty(this.Content);
        end%


        function finalize(this, counter)
            assignId(this, counter);
            assignParentSettings(this);
            populateSettingsStruct(this);
            for i = 1 : numel(this.Content)
                finalize(this.Content{i}, counter);
                this.DataRequests = union(this.DataRequests, this.Content{i}.DataRequests, 'stable');
            end
        end%


        function assignId(this, counter)
            this.Id = generateId(counter);
        end%
    end
end

