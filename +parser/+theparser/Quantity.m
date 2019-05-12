classdef Quantity < parser.theparser.Generic
    properties
        Type
        IsLog = false
        IsLagrange = false
        IsReservedPrefix = true
    end
    
    
    methods
        function [qty, eqn] = parse(this, the, code, qty, eqn, ~, ~, opt)
            import parser.White
            BR = sprintf('\n');
            TYPE = @int8;
            
            % Parse names with labels and assignments
            NAME_PATTERN = [ '("[ ]*"|''[ ]*'')?\s*', ...  % Label
                             '([a-zA-Z]\w*)', ...          % Name
                             '(@?)', ...                   % Include in bwl vector
                             '(\{[^\}]*\}){0,2}', ...      % Bounds <LoLevel, HiLevel> or <LoLevel, HiLevel><LoGrowth, HiGrowth>
                             '\s*(=[^;,\n]+[;,\n])?'   ];  % =Value
            
            %--------------------------------------------------------------------------
            
            if isempty(code)
                return
            end

            if this.Type==TYPE(4) && opt.AutodeclareParameters
                return
            end
            
            code = [code, sprintf('\n')];
            whiteCode = code;
            
            % White out the inside of labels (single or double qouted text), keeping
            % the quotation marks.
            whiteCode = White.whiteOutLabel(whiteCode);
            
            % White out first-level round and square brackets. This is to handle
            % assignments containing function calls with multiple arguments separated
            % with commas (commas are valid separator of parameters).
            whiteCode = White.whiteOutParenth(whiteCode, 1);
            
            tokenExtents = regexp(whiteCode, NAME_PATTERN, 'tokenExtents');
            for i = 1 : length(tokenExtents) %#ok<UNRCH>
                if size(tokenExtents{i}, 1)==2
                    tokenExtents{i} = [ {[1, 0]}; tokenExtents{i} ];
                end
            end
            
            numOfQuantities = length(tokenExtents);
            label = cell(1, numOfQuantities);
            name = cell(1, numOfQuantities);
            indexOfObserved = false(1, numOfQuantities);
            boundsString = cell(1, numOfQuantities);
            assignedString = cell(1, numOfQuantities);
            for i = 1 : numOfQuantities
                label{i} = code( tokenExtents{i}(1, 1)+1 : tokenExtents{i}(1, 2)-1 );
                name{i}  = code( tokenExtents{i}(2, 1) : tokenExtents{i}(2, 2)   );
                indexOfObserved(i) = tokenExtents{i}(3, 1)<=tokenExtents{i}(3, 2);
                boundsString{i} = code( tokenExtents{i}(4, 1) : tokenExtents{i}(4, 2) );
                assignedString{i} = code( tokenExtents{i}(5, 1)+1 : tokenExtents{i}(5, 2) );
            end
            name = strtrim(name);
            label = strtrim(label);
            assignedString = strtrim(assignedString);
            for i = 1 : numOfQuantities
                if ~isempty(assignedString{i}) && any(assignedString{i}(end)==[',;', BR])
                    assignedString{i}(end) = '';
                end
            end
            
            [~, posOfUnique] = unique(name, 'last');
            if length(posOfUnique)<length(name)
                if opt.AllowMultiple
                    % If multiple declaration of the same name is allowed, remove redundant
                    % declarations, and use the last one found.
                    posOfUnique = sort(posOfUnique);
                    posOfUnique = posOfUnique(:).';
                    name = name(posOfUnique);
                    indexOfObserved = indexOfObserved(posOfUnique);
                    label = label(posOfUnique);
                    assignedString = assignedString(posOfUnique);
                    boundsString = boundsString(posOfUnique);
                else
                    % Otherwise, throw an error.
                    listDuplicate = parser.getMultiple(name);
                    throw( ...
                        exception.ParseTime('TheParser:MUTLIPLE_NAMES', 'error'), ...
                        listDuplicate{:} ...
                    );
                end
            end
            
            if this.IsReservedPrefix
                % Report all names starting with STD_PREFIX, CORR_PREFIX, 
                % LOG_PREFIX.
                indexOfStd = strncmp(name, model.STD_PREFIX, length(model.STD_PREFIX));
                indexOfCorr = strncmp(name, model.CORR_PREFIX, length(model.CORR_PREFIX));
                indexOfLog = strncmp(name, model.LOG_PREFIX, length(model.LOG_PREFIX));
                indexOfFloor = strncmp(name, model.FLOOR_PREFIX, length(model.FLOOR_PREFIX));
                indexOfReservedPrefix = indexOfStd | indexOfCorr | indexOfLog | indexOfFloor;
                if any(indexOfReservedPrefix)
                    throw( ...
                        exception.ParseTime('TheParser:ReservedPrefixDeclared', 'error'), ...
                        name{indexOfReservedPrefix} ...
                    );
                end
            end
            
            numOfQuantities = length(name);
            bounds = evalBounds(this, boundsString);
            [label, alias] = this.splitLabelAlias(label);
            
            qty.Name(end+(1:numOfQuantities)) = name;
            qty.IxObserved(end+(1:numOfQuantities)) = indexOfObserved;
            qty.Type(end+(1:numOfQuantities)) = repmat(this.Type, 1, numOfQuantities);
            qty.Label(end+(1:numOfQuantities)) = label;
            qty.Alias(end+(1:numOfQuantities)) = alias;
            qty.Bounds(:, end+(1:numOfQuantities)) = bounds;
            
            qty.IxLog(end+(1:numOfQuantities)) = repmat(this.IsLog, 1, numOfQuantities);
            qty.IxLagrange(end+(1:numOfQuantities)) = repmat(this.IsLagrange, 1, numOfQuantities);
            
            the.AssignedString = [the.AssignedString, assignedString];
        end
    
    
        function bounds = evalBounds(this, boundsString)
            levelBoundsAllowed = ismember(this.Type, model.LEVEL_BOUNDS_ALLOWED);
            growthBoundsAllowed = ismember(this.Type, model.GROWTH_BOUNDS_ALLOWED);
            nName = length(boundsString);
            bounds = repmat(model.component.Quantity.DEFAULT_BOUNDS, 1, nName);
            ixValid = true(1, nName);
            boundsString = strrep(boundsString, ' ', '');
            boundsString = strrep(boundsString, ',}', ',Inf}');
            boundsString = strrep(boundsString, '{,', '{Inf,');
            boundsString = strrep(boundsString, '}{', '},{');
            boundsString = strrep(boundsString, '{', '[');
            boundsString = strrep(boundsString, '}', ']');
            indexOfEmptyBounds = cellfun(@isempty, boundsString);
            for i = find(~indexOfEmptyBounds)
                try
                    b = eval(['[', boundsString{i}, ']']);
                    b = b(:);
                    numOfBounds = numel(b);
                    ixValid(i) = ...
                        numOfBounds<=size(bounds, 1) ...
                        && (levelBoundsAllowed || numOfBounds==0) ...
                        && (growthBoundsAllowed || numOfBounds<=2) ...
                    ;
                    if ~ixValid(i)
                        continue
                    end
                    bounds(1:numOfBounds, i) = b(1:numOfBounds);
                catch
                    ixValid(i) = false;
                end
            end
            if any(~ixValid)
                throw( ...
                    exception.ParseTime('TheParser:InvalidBounds', 'error'), ...
                    boundsString{~ixValid} ...
                );
            end
        end
    end
end
