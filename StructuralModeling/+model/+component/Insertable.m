classdef Insertable
    methods
        function [this, inxPre, inxPost] = insert(this, add, type, where)
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
                inxPre = false(1, numOld);
                inxPost = false(1, numOld);
                inxPre(1:posFirst-1) = true;
                inxPost(posFirst:end) = true;
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
                inxPre = false(1, numOld);
                inxPost = false(1, numOld);
                inxPre(1:posLast) = true;
                inxPost(posLast+1:end) = true;
            end

            numToAdd = length(add.(pivot));
            numNew = numOld + numToAdd;
            add.Type = repmat(type, 1, numToAdd);
            for i = 1 : length(listProperties)
                ithProperty = listProperties{i};
                this.(ithProperty) = [ this.(ithProperty)(:, inxPre), ...
                                       add.(ithProperty), ...
                                       this.(ithProperty)(:, inxPost) ];
                if size(this.(ithProperty), 2)~=numNew
                    throw( exception.Base('General:Internal', 'error') );
                end
            end
        end%


        function this = delete(this, inxToDelete)
            listProperties = getInsertableProp(this);
            numProperties = numel(listProperties);
            checkSize = nan(1, numProperties);
            for i = 1 : numProperties
                ithProperty = listProperties{i};
                this.(ithProperty)(:, inxToDelete) = [ ];
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
            inx = ~[x.Dependent] & ~[x.Constant] & ~[x.Hidden] & ~[x.Transient];
            listProperties = {x(inx).Name};
        end%
    end
end
