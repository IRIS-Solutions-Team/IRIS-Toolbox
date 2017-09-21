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
        function this = move(this, FromPos, ToPos)
            list = properties(this);
            pivot = list{1};
            n = length(this.(pivot));
            reord = 1 : n;
            reord(FromPos) = [ ];
            reord = [ reord(1:ToPos-1), FromPos, reord(ToPos:end) ];
            for i = 1 : length(list)
                this.(list{i}) = this.(list{i})(reord);
            end
        end
        

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
                this.(prop) = [ ...
                    this.(prop)(:, ixPre), ...
                    add.(prop), ...
                    this.(prop)(:, ixPost), ...
                    ];
                assert( ...
                    size(this.(prop), 2)==numOfNew, ...
                    exception.Base('General:INTERNAL', 'error') ...
                );
            end
        end
    end
end
