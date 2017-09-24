classdef Insertable
    properties (Constant, Hidden)
        TYPE = @int8
    end
    
    
    methods
        function [this, ixPre, ixPost] = insert(this, add, type, where)
            lsProp = getInsertableProp(this);
            pivot = lsProp{1};
            nOld = length(this.(pivot));
            
            
            posType = find(type==this.TYPE_ORDER);
            if strcmp(where, 'first')
                while true
                    posFirst = find(this.Type==this.TYPE_ORDER(posType), 1);
                    if ~isempty(posFirst)
                        break
                    end
                    posType = posType + 1;
                    if posType>length(this.TYPE_ORDER)
                        posFirst = nOld+1;
                        break
                    end
                end
                ixPre = false(1, nOld);
                ixPost = false(1, nOld);
                ixPre(1:posFirst-1) = true;
                ixPost(posFirst:end) = true;
            else
                while true
                    posLast = find(this.Type==this.TYPE_ORDER(posType), 1, 'last');
                    if ~isempty(posLast)
                        break
                    end
                    posType = posType - 1;
                    if posType<1
                        posLast = 0;
                        break
                    end
                end
                ixPre = false(1, nOld);
                ixPost = false(1, nOld);
                ixPre(1:posLast) = true;
                ixPost(posLast+1:end) = true;
            end
            
            nAdd = length(add.(pivot));
            nNew = nOld + nAdd;
            add.Type = repmat(type, 1, nAdd);
            for i = 1 : length(lsProp)
                prop = lsProp{i};
                this.(prop) = [ ...
                    this.(prop)(:, ixPre), ...
                    add.(prop), ...
                    this.(prop)(:, ixPost), ...
                    ];
                if size(this.(prop), 2)~=nNew
                    throw( exception.Base('General:Internal', 'error') );
                end
            end
        end
        
        
        
        
        function this = delete(this, ixDelete)
            lsProp = getInsertableProp(this);
            nProp = numel(lsProp);
            chkSize = nan(1, nProp);
            for i = 1 : nProp
                prop = lsProp{i};
                this.(prop)(:, ixDelete) = [ ];
                chkSize(i) = size(this.(prop), 2);
            end
            if any( chkSize~=chkSize(1) )
                throw( exception.Base('General:Internal', 'error') );
            end
        end
        
        
        
        
        function lsProp = getInsertableProp(this)
            x = metaclass(this);
            x = x.PropertyList;
            ix = ~[ x.Dependent ] & ~[ x.Constant ] & ~[ x.Hidden ];
            lsProp = { x(ix).Name };
        end
    end
end
