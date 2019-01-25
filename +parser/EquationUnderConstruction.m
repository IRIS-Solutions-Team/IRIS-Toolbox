classdef EquationUnderConstruction < handle
    properties
        LhsDynamic = cell.empty(1, 0)
        RhsDynamic = cell.empty(1, 0)
        SignDynamic = cell.empty(1, 0)
        LhsSteady = cell.empty(1, 0)
        RhsSteady = cell.empty(1, 0)
        SignSteady = cell.empty(1, 0)
        
        MaxShDynamic = double.empty(1, 0);
        MinShDynamic = double.empty(1, 0);
        MaxShSteady = double.empty(1, 0);
        MinShSteady = double.empty(1, 0);        
    end
    
    
    methods
        function this = move(this, fromPos, toPos)
            listProperties = properties(this);
            numProperties = numel(listProperties);
            reorder = 1 : numel(this.(listProperties{1}));
            reorder(fromPos) = [ ];
            reorder = [ reorder(1:toPos-1), fromPos, reorder(toPos:end) ];
            for i = 1 : numProperties
                ithProperty = listProperties{i};
                this.(ithProperty) = this.(ithProperty)(reorder);
            end
        end%
        

        function this = insert(this, add, ixPre, ixPost)
            x = metaclass(this);
            ix = ~[ x.PropertyList.Dependent ] & ~[ x.PropertyList.Constant ];
            lsProp = { x.PropertyList(ix).Name };
            pivot = lsProp{1};
            numOfOld = length(this.(pivot));
            numToAdd = length(add.(pivot));
            numOfNew = numOfOld + numToAdd;
            for i = 1 : length(lsProp)
                prop = lsProp{i};
                this.(prop) = [ this.(prop)(:, ixPre), ...
                                add.(prop), ...
                                this.(prop)(:, ixPost) ];
                if size(this.(prop), 2)~=numOfNew
                    throw( exception.Base('General:Internal', 'error') );
                end
            end
        end%
    end
end

