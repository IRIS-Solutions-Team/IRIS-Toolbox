classdef Quantity < parser.theparser.Generic
    properties
        Type
        IsLog = false
        IsLagrange = false
        IsReservedPrefix = true
    end
    
    
    methods
        function [qty, eqn] = parse(this, the, code, qty, eqn, ~, ~, opt)
            %(
            import parser.White
            BR = sprintf('\n');
            TYPE = @int8;
            
            % Parse names with labels and assignments
            NAME_PATTERN = [ '("[ ]*"|''[ ]*'')?\s*', ...  % Label
                             '([a-zA-Z]\w*)', ...          % Name
                             '(@?)', ...                   % Observed transition variable
                             '(\{[^\}]*\}){0,2}', ...      % Bounds {LoLevel, HiLevel} or {LoLevel, HiLevel}{LoGrowth, HiGrowth}
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
            
            numQuantities = length(tokenExtents);
            label = cell(1, numQuantities);
            name = cell(1, numQuantities);
            inxObserved = false(1, numQuantities);
            boundsString = cell(1, numQuantities);
            assignedString = cell(1, numQuantities);
            for i = 1 : numQuantities
                label{i} = code( tokenExtents{i}(1, 1)+1 : tokenExtents{i}(1, 2)-1 );
                name{i}  = code( tokenExtents{i}(2, 1) : tokenExtents{i}(2, 2)   );
                inxObserved(i) = tokenExtents{i}(3, 1)<=tokenExtents{i}(3, 2);
                boundsString{i} = code( tokenExtents{i}(4, 1) : tokenExtents{i}(4, 2) );
                assignedString{i} = code( tokenExtents{i}(5, 1)+1 : tokenExtents{i}(5, 2) );
            end
            name = strtrim(name);
            label = strtrim(label);
            assignedString = strtrim(assignedString);
            for i = 1 : numQuantities
                if ~isempty(assignedString{i}) && any(assignedString{i}(end)==[',;', BR])
                    assignedString{i}(end) = '';
                end
            end
            
            [~, posUnique] = unique(name, 'last');
            if length(posUnique)<length(name)
                if opt.AllowMultiple
                    % If multiple declaration of the same name is allowed, remove redundant
                    % declarations, and use the last one found.
                    posUnique = sort(posUnique);
                    posUnique = posUnique(:).';
                    name = name(posUnique);
                    inxObserved = inxObserved(posUnique);
                    label = label(posUnique);
                    assignedString = assignedString(posUnique);
                    boundsString = boundsString(posUnique);
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
                reservedPrefixes = [ 
                    string(model.component.Quantity.STD_PREFIX)
                    string(model.component.Quantity.CORR_PREFIX) 
                    string(model.component.Quantity.LOG_PREFIX)
                    string(model.component.Quantity.FLOOR_PREFIX)
                ];
                inxReservedPrefix = startsWith(name, reservedPrefixes);
                if any(inxReservedPrefix)
                    throw( ...
                        exception.ParseTime('TheParser:ReservedPrefixDeclared', 'error'), ...
                        name{inxReservedPrefix} ...
                    );
                end
            end
            
            numQuantities = length(name);
            bounds = evalBounds(this, boundsString);
            [label, alias] = this.splitLabelAlias(label);
            
            qty.Name(end+(1:numQuantities)) = name;
            qty.IxObserved(end+(1:numQuantities)) = inxObserved;
            qty.Type(end+(1:numQuantities)) = repmat(this.Type, 1, numQuantities);
            qty.Label(end+(1:numQuantities)) = label;
            qty.Alias(end+(1:numQuantities)) = alias;
            qty.Bounds(:, end+(1:numQuantities)) = bounds;
            
            qty.IxLog(end+(1:numQuantities)) = repmat(this.IsLog, 1, numQuantities);
            qty.IxLagrange(end+(1:numQuantities)) = repmat(this.IsLagrange, 1, numQuantities);
            
            the.AssignedString = [the.AssignedString, assignedString];
            %)
        end%
    
    
        function bounds = evalBounds(this, boundsString)
            %(
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
            inxEmptyBounds = cellfun(@isempty, boundsString);
            for i = find(~inxEmptyBounds)
                try
                    b = eval(['[', boundsString{i}, ']']);
                    b = b(:);
                    numBounds = numel(b);
                    ixValid(i) = ...
                        numBounds<=size(bounds, 1) ...
                        && (levelBoundsAllowed || numBounds==0) ...
                        && (growthBoundsAllowed || numBounds<=2) ...
                    ;
                    if ~ixValid(i)
                        continue
                    end
                    bounds(1:numBounds, i) = b(1:numBounds);
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
            %)
        end%
    end
end

