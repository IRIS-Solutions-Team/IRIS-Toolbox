classdef Insertable
    methods
        function [this, inxOfPre, inxOfPost] = insert(this, add, type, where)
            listOfProperties = getInsertableProp(this);
            pivot = listOfProperties{1};
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
                inxOfPre = false(1, numOfOld);
                inxOfPost = false(1, numOfOld);
                inxOfPre(1:posOfFirst-1) = true;
                inxOfPost(posOfFirst:end) = true;
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
                inxOfPre = false(1, numOfOld);
                inxOfPost = false(1, numOfOld);
                inxOfPre(1:posLast) = true;
                inxOfPost(posLast+1:end) = true;
            end
            
            numToAdd = length(add.(pivot));
            numOfNew = numOfOld + numToAdd;
            add.Type = repmat(type, 1, numToAdd);
            for i = 1 : length(listOfProperties)
                ithProperty = listOfProperties{i};
                this.(ithProperty) = [ this.(ithProperty)(:, inxOfPre), ...
                                       add.(ithProperty), ...
                                       this.(ithProperty)(:, inxOfPost) ];
                if size(this.(ithProperty), 2)~=numOfNew
                    throw( exception.Base('General:Internal', 'error') );
                end
            end
        end%
        
        
        function this = delete(this, inxToDelete)
            listOfProperties = getInsertableProp(this);
            numOfProperties = numel(listOfProperties);
            checkSize = nan(1, numOfProperties);
            for i = 1 : numOfProperties
                ithProperty = listOfProperties{i};
                this.(ithProperty)(:, inxToDelete) = [ ];
                checkSize(i) = size(this.(ithProperty), 2);
            end
            if any( checkSize~=checkSize(1) )
                throw( exception.Base('General:Internal', 'error') );
            end
        end%
        
        
        function this = move(this, fromPos, toPos)
            listOfProperties = getInsertableProp(this);
            numOfProperties = numel(listOfProperties);
            reorder = 1 : numel(this.(listOfProperties{1}));
            reorder(fromPos) = [ ];
            reorder = [ reorder(1:toPos-1), fromPos, reorder(toPos:end) ];
            for i = 1 : numOfProperties
                ithProperty = listOfProperties{i};
                this.(ithProperty) = this.(ithProperty)(reorder);
            end
        end%
        
        
        function listOfProperties = getInsertableProp(this)
            x = metaclass(this);
            x = x.PropertyList;
            ix = ~[ x.Dependent ] & ~[ x.Constant ] & ~[ x.Hidden ];
            listOfProperties = { x(ix).Name };
        end%
    end
end
