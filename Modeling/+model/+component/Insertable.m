classdef Insertable
    methods
        function [this, indexOfPre, indexOfPost] = insert(this, add, type, where)
            listProperties = getInsertableProp(this);
            pivot = listProperties{1};
            numOfOld = length(this.(pivot));
            
            posType = find(type==this.TYPE_ORDER);
            if strcmp(where, 'first')
                while true
                    posOfFirst = find(this.Type==this.TYPE_ORDER(posType), 1);
                    if ~isempty(posOfFirst)
                        break
                    end
                    posType = posType + 1;
                    if posType>length(this.TYPE_ORDER)
                        posOfFirst = numOfOld+1;
                        break
                    end
                end
                indexOfPre = false(1, numOfOld);
                indexOfPost = false(1, numOfOld);
                indexOfPre(1:posOfFirst-1) = true;
                indexOfPost(posOfFirst:end) = true;
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
                indexOfPre = false(1, numOfOld);
                indexOfPost = false(1, numOfOld);
                indexOfPre(1:posLast) = true;
                indexOfPost(posLast+1:end) = true;
            end
            
            numToAdd = length(add.(pivot));
            numOfNew = numOfOld + numToAdd;
            add.Type = repmat(type, 1, numToAdd);
            for i = 1 : length(listProperties)
                ithProperty = listProperties{i};
                this.(ithProperty) = [ ...
                    this.(ithProperty)(:, indexOfPre), ...
                    add.(ithProperty), ...
                    this.(ithProperty)(:, indexOfPost), ...
                    ];
                if size(this.(ithProperty), 2)~=numOfNew
                    throw( exception.Base('General:Internal', 'error') );
                end
            end
        end%
        
        
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
        end%
        
        
        function this = move(this, fromPos, toPos)
            listProperties = getInsertableProp(this);
            numProperties = numel(listProperties);
            reorder = 1 : numel(this.(listProperties{1}));
            reorder(fromPos) = [ ];
            reorder = [ reorder(1:toPos-1), fromPos, reorder(toPos:end) ];
            for i = 1 : numProperties
                ithProperty = listProperties{i};
                this.(ithProperty) = this.(ithProperty)(reorder);
            end
        end%
        
        
        function listProperties = getInsertableProp(this)
            x = metaclass(this);
            x = x.PropertyList;
            ix = ~[ x.Dependent ] & ~[ x.Constant ] & ~[ x.Hidden ];
            listProperties = { x(ix).Name };
        end%
    end
end
