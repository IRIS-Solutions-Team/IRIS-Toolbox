classdef Insertable
    methods
        function [this, indexPre, indexPost] = insert(this, add, type, where)
            listProperties = getInsertableProp(this);
            pivot = listProperties{1};
            numOld = length(this.(pivot));
            
            posType = find(type==this.TYPE_ORDER);
            if strcmp(where, 'first')
                while true
                    posFirst = find(this.Type==this.TYPE_ORDER(posType), 1);
                    if ~isempty(posFirst)
                        break
                    end
                    posType = posType + 1;
                    if posType>length(this.TYPE_ORDER)
                        posFirst = numOld+1;
                        break
                    end
                end
                indexPre = false(1, numOld);
                indexPost = false(1, numOld);
                indexPre(1:posFirst-1) = true;
                indexPost(posFirst:end) = true;
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
                indexPre = false(1, numOld);
                indexPost = false(1, numOld);
                indexPre(1:posLast) = true;
                indexPost(posLast+1:end) = true;
            end
            
            numToAdd = length(add.(pivot));
            numNew = numOld + numToAdd;
            add.Type = repmat(type, 1, numToAdd);
            for i = 1 : length(listProperties)
                ithProperty = listProperties{i};
                this.(ithProperty) = [ ...
                    this.(ithProperty)(:, indexPre), ...
                    add.(ithProperty), ...
                    this.(ithProperty)(:, indexPost), ...
                    ];
                if size(this.(ithProperty), 2)~=numNew
                    throw( exception.Base('General:Internal', 'error') );
                end
            end
        end
        
        
        
        
        function this = delete(this, ixDelete)
            listProperties = getInsertableProp(this);
            numProperties = numel(listProperties);
            checkSize = nan(1, numProperties);
            for i = 1 : numProperties
                ithProperty = listProperties{i};
                this.(ithProperty)(:, ixDelete) = [ ];
                checkSize(i) = size(this.(ithProperty), 2);
            end
            if any( checkSize~=checkSize(1) )
                throw( exception.Base('General:Internal', 'error') );
            end
        end
        
        
        
        
        function listProperties = getInsertableProp(this)
            x = metaclass(this);
            x = x.PropertyList;
            ix = ~[ x.Dependent ] & ~[ x.Constant ] & ~[ x.Hidden ];
            listProperties = { x(ix).Name };
        end
    end
end
