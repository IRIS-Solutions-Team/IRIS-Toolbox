classdef EquationUnderConstruction < handle
    properties
        LhsDynamic = cell(1, 0)
        RhsDynamic = cell(1, 0)
        SignDynamic = cell(1, 0)
        LhsSteady = cell(1, 0)
        RhsSteady = cell(1, 0)
        SignSteady = cell(1, 0)
        
        MaxShDynamic = zeros(1, 0);
        MinShDynamic = zeros(1, 0);
        MaxShSteady = zeros(1, 0);
        MinShSteady = zeros(1, 0);        
    end
    
    
    
    
    properties (Constant)
        SEPARATOR = '!!';
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
            nOld = length(this.(pivot));
            nAdd = length(add.(pivot));
            nNew = nOld + nAdd;
            for i = 1 : length(lsProp)
                prop = lsProp{i};
                this.(prop) = [ ...
                    this.(prop)(:, ixPre), ...
                    add.(prop), ...
                    this.(prop)(:, ixPost), ...
                    ];
                if size(this.(prop), 2)~=nNew
                    throw( exception.Base('General:INTERNAL', 'error') );
                end
            end
        end
    end
end
