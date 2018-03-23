classdef Quantity < parser.theparser.Generic
    properties
        Type
        IsLog = false
        IsLagrange = false
        IsReservedPrefix = true
    end
    
    
    methods
        function [qty, eqn] = parse(this, the, code, qty, eqn, ~, ~, opt)
            import parser.White;
            BR = sprintf('\n');
            
            % Parse names with labels and assignments.
            % @@@@@ MOSW.
            % Extra pair of brackets needed in Octave.
            NAME_PATTERN = [ ...
                '(("[ ]*"|''[ ]*'')?)\s*', ...  % Label
                '([a-zA-Z]\w*)', ...            % Name
                '(@?)', ...                     % Include in bwl vector.
                '((\{[^\}]*\}){0,2})', ...      % Bounds <LoLevel, HiLevel> or <LoLevel, HiLevel><LoGrowth, HiGrowth>
                '\s*((=[^;,\n]+[;,\n])?)', ...  % =Value.
            ];
            
            %--------------------------------------------------------------------------
            
            if isempty(code)
                return
            end
            
            code = [code, sprintf('\n')];
            whCode = code;
            
            % White out the inside of labels (single or double qouted text), keeping
            % the quotation marks.
            whCode = White.whiteOutLabel(whCode);
            
            % White out first-level round and square brackets. This is to handle
            % assignments containing function calls with multiple arguments separated
            % with commas (commas are valid separator of parameters).
            whCode = White.whiteOutParenth(whCode, 1);
            
            tknExt = regexp(whCode, NAME_PATTERN, 'tokenExtents');
            
            if true % ##### MOSW
                % Do nothing.
            else
                for i = 1 : length(tknExt) %#ok<UNRCH>
                    if size(tknExt{i}, 1)==2
                        tknExt{i} = [ {[1, 0]}; tknExt{i} ];
                    end
                end
            end
            
            numQuantities = length(tknExt);
            label = cell(1, numQuantities);
            name = cell(1, numQuantities);
            indexOfObserved = false(1, numQuantities);
            boundsString = cell(1, numQuantities);
            assignedString = cell(1, numQuantities);
            for i = 1 : numQuantities
                label{i} = code( tknExt{i}(1, 1)+1 : tknExt{i}(1, 2)-1 );
                name{i}  = code( tknExt{i}(2, 1) : tknExt{i}(2, 2)   );
                indexOfObserved(i) = tknExt{i}(3, 1)<=tknExt{i}(3, 2);
                boundsString{i} = code( tknExt{i}(4, 1) : tknExt{i}(4, 2) );
                assignedString{i} = code( tknExt{i}(5, 1)+1 : tknExt{i}(5, 2) );
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
                    indexOfObserved = indexOfObserved(posUnique);
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
                ixStd = strncmp(name, model.STD_PREFIX, length(model.STD_PREFIX));
                ixCorr = strncmp(name, model.CORR_PREFIX, length(model.CORR_PREFIX));
                ixLog = strncmp(name, model.LOG_PREFIX, length(model.LOG_PREFIX));
                ixPrefix = ixStd | ixCorr | ixLog;
                if any(ixPrefix)
                    throw( ...
                        exception.ParseTime('TheParser:ReservedPrefixDeclared', 'error'), ...
                        name{ixPrefix} ...
                    );
                end
            end
            
            numQuantities = length(name);
            bounds = evalBounds(this, boundsString);
            [label, alias] = this.splitLabelAlias(label);
            
            qty.Name(end+(1:numQuantities)) = name;
            qty.IxObserved(end+(1:numQuantities)) = indexOfObserved;
            qty.Type(end+(1:numQuantities)) = repmat(this.Type, 1, numQuantities);
            qty.Label(end+(1:numQuantities)) = label;
            qty.Alias(end+(1:numQuantities)) = alias;
            qty.Bounds(:, end+(1:numQuantities)) = bounds;
            
            qty.IxLog(end+(1:numQuantities)) = repmat(this.IsLog, 1, numQuantities);
            qty.IxLagrange(end+(1:numQuantities)) = repmat(this.IsLagrange, 1, numQuantities);
            
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
