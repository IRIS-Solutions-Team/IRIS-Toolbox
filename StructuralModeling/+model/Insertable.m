classdef Insertable
    methods
        function [this, inxPre, inxPost, newPos] = insert(this, add, type, where)
            listProperties = getInsertableProp(this);
            pivot = listProperties{1};
            numOld = length(this.(pivot));
            numToAdd = numel(add.(pivot));
            numNew = numOld + numToAdd;

            if strcmp(where, 'first')
                posType = find(type==this.TYPE_ORDER);
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
                add.Type = repmat(type, 1, numToAdd);
                newPos = posFirst-1 + (1:numToAdd);
            elseif strcmp(where, 'last')
                posLast = locallyFindLast(this, type);
                inxPre = false(1, numOld);
                inxPost = false(1, numOld);
                inxPre(1:posLast) = true;
                inxPost(posLast+1:end) = true;
                add.Type = repmat(type, 1, numToAdd);
                newPos = posLast + (1:numToAdd);
            else
                inxPre = false(1, numOld);
                inxPost = false(1, numOld);
                inxPre(1:where-1) = true;
                inxPost(where:end) = true;
                newPos = where-1 + (1 : numToAdd);
            end

            for i = 1 : numel(listProperties)
                ithProperty = listProperties{i};
                this.(ithProperty) = [ ...
                    this.(ithProperty)(:, inxPre), ...
                    add.(ithProperty), ...
                    this.(ithProperty)(:, inxPost) ...
                ];
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
            reorder = [reorder(1:toPos-1), fromPos, reorder(toPos:end)];
            for i = 1 : numProperties
                ithProperty = listProperties{i};
                this.(ithProperty) = this.(ithProperty)(:, reorder);
            end
        end%


        function listProperties = getInsertableProp(this)
            x = metaclass(this);
            x = x.PropertyList;
            inx = ~[x.Dependent] & ~[x.Constant] & ~[x.Hidden] & ~[x.Transient];
            listProperties = {x(inx).Name};
        end%


        function inx = byAttributes(this, varargin)
            %(
            num = numel(this);
            inx = true(1, num);
            for i = 1 : numel(varargin)
                attributesToMatch = strip(textual.stringify(varargin{i}));
                for j = 1 : num
                    inx(j) = inx(j) && any(matches(this.Attributes{j}, attributesToMatch));
                end
            end
            %)
        end%


        function this = retype(this, name, newType)
            stringify = @(x) reshape(string(x), 1, []);
            pos = find(string(name)==stringify(this.Name));
            if isempty(pos)
                return
            end
            if this.Type(pos)==newType
                return
            end
            posLast = locallyFindLast(this, newType);
            this = move(this, pos, posLast+1);
            this.Type(posLast+1) = newType;
        end%
    end
end

%
% Local functions
%

function posLast = locallyFindLast(this, type)
    %(
    posType = find(type==this.TYPE_ORDER);
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
    %)
end%

