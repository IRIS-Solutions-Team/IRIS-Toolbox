classdef Quantity < parser.theparser.Generic
    properties
        Type
        IsLog = false
        IsLagrange = false
        IsReservedPrefix = true
    end
    
    
    
    
    properties (Constant)
        STD_PREFIX = 'std_';
        CORR_PREFIX = 'corr_';
        LOG_PREFIX = 'log_';
    end
    
    
    
    
    methods
        function [quantity, equation] = parse(this, the, code, quantity, equation, ~, ~, opt)
            import parser.White;
            BR = sprintf('\n');
            
            % Parse names with labels and assignments.
            % @@@@@ MOSW.
            % Extra pair of brackets needed in Octave.
            NAME_PATTERN = [ ...
                '(("[ ]*"|''[ ]*'')?)\s*', ... % Label.
                '([a-zA-Z]\w*)', ... % Name.
                '((\[[^\]]*\]){0,2})', ... % Bounds [LoLevel,HiLevel] or [LoLevel,HiLevel][LoGrowth,HiGrowth]
                '\s*((=[^;,\n]+[;,\n])?)', ... % =Value.
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
                    if size(tknExt{i},1)==2
                        tknExt{i} = [ {[1,0]}; tknExt{i} ];
                    end
                end
            end
            
            nQuan = length(tknExt);
            label = cell(1, nQuan);
            name = cell(1, nQuan);
            strBounds = cell(1, nQuan);
            strAssigned = cell(1, nQuan);
            for i = 1 : nQuan
                label{i} = code( tknExt{i}(1,1)+1 : tknExt{i}(1,2)-1 );
                name{i}  = code( tknExt{i}(2,1) : tknExt{i}(2,2)   );
                strBounds{i} = code( tknExt{i}(3,1) : tknExt{i}(3,2) );
                strAssigned{i} = code( tknExt{i}(4,1)+1 : tknExt{i}(4,2) );
            end
            
            name = strtrim(name);
            label = strtrim(label);
            strAssigned = strtrim(strAssigned);
            for i = 1 : nQuan
                if ~isempty(strAssigned{i}) && any(strAssigned{i}(end)==[',;',BR])
                    strAssigned{i}(end) = '';
                end
            end
            
            [~, posUnique] = unique(name, 'last');
            if length(posUnique)<length(name)
                if opt.multiple
                    % If multiple declaration of the same name is allowed, remove redundant
                    % declarations, and use the last one found.
                    posUnique = sort(posUnique);
                    posUnique = posUnique(:).';
                    name = name(posUnique);
                    label = label(posUnique);
                    strAssigned = strAssigned(posUnique);
                    strBounds = strBounds(posUnique);
                else
                    % Otherwise, throw an error.
                    lsMultiple = parser.getMultiple(name);
                    throw( ...
                        exception.ParseTime('TheParser:MUTLIPLE_NAMES', 'error'), ...
                        lsMultiple{:} ...
                        );
                end
            end
            
            if this.IsReservedPrefix
                % Report all names starting with STD_PREFIX, CORR_PREFIX,
                % LOG_PREFIX.
                ixStd = strncmp(name, this.STD_PREFIX, length(this.STD_PREFIX));
                ixCorr = strncmp(name, this.CORR_PREFIX, length(this.CORR_PREFIX));
                ixLog = strncmp(name, this.LOG_PREFIX, length(this.LOG_PREFIX));
                ixPrefix = ixStd | ixCorr | ixLog;
                if any(ixPrefix)
                    throw( ...
                        exception.ParseTime('TheParser:ReservedPrefixDeclared', 'error'), ...
                        name{ixPrefix} ...
                        );
                end
            end
            
            nQuan = length(name);
            bounds = this.evalBounds(strBounds);
            [label, alias] = this.splitLabelAlias(label);
            
            quantity.Name(end+(1:nQuan)) = name;
            quantity.Type(end+(1:nQuan)) = repmat(this.Type, 1, nQuan);
            quantity.Label(end+(1:nQuan)) = label;
            quantity.Alias(end+(1:nQuan)) = alias;
            quantity.Bounds(:, end+(1:nQuan)) = bounds;
            
            quantity.IxLog(end+(1:nQuan)) = repmat(this.IsLog, 1, nQuan);
            quantity.IxLagrange(end+(1:nQuan)) = repmat(this.IsLagrange, 1, nQuan);
            
            the.StrAssigned = [the.StrAssigned, strAssigned];
        end
    end
    
    
    
    
    methods (Static)
        function numBounds = evalBounds(strBounds)
            nName = length(strBounds);
            numBounds = repmat(model.Quantity.DEFAULT_BOUNDS, 1, nName);
            ixValid = true(1,nName);
            strBounds = strrep(strBounds, ' ', '');
            strBounds = strrep(strBounds, ',]', ',Inf]');
            strBounds = strrep(strBounds, '[,', '[Inf,');
            strBounds = strrep(strBounds, '[', '[');
            strBounds = strrep(strBounds, ']', ']');
            strBounds = strrep(strBounds, '][', '],[');
            ixEmptyBounds = cellfun(@isempty, strBounds);
            
            for i = find(~ixEmptyBounds)
                try
                    b = eval(['{', strBounds{i}, '}']);
                    if isempty(b) || all(cellfun(@isempty, b))
                        continue
                    end
                    if ~isempty(b{1})
                        numBounds(1:2,i) = b{1};
                    end
                    if length(b)>1 && ~isempty(b{2})
                        numBounds(3:4,i) = b{2};
                    end
                catch
                    ixValid(i) = false;
                end
            end
            if any(~ixValid)
                throw( exception.ParseTime('TheParser:INVALID_BOUNDS', 'error'), ...
                    strBounds{~ixValid} );
            end
        end
    end
end
