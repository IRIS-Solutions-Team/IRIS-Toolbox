classdef Quantity < parser.theparser.Generic
    properties
        Type
        IsLog = false
        IsLagrange = false
        IsReservedPrefix = true
    end


    methods
        function [qty, eqn, euc, puc] = parse(this, the, code, attributes, qty, eqn, euc, puc, opt)
            %#ok<*SPRINTFN>

            code = char(code);
            if strlength(code)==0
                return
            end

            SEPARATORS = [",", ";", sprintf("\n")];

            NAME_PATTERN = ...
                "(""[ ]*""|'[ ]*')?\s*" ...    % "Label" or 'Label'
                + "([a-zA-Z]\w*)" ...          % Name
                + "(@?)" ...                   % @ Observed transition variable
                + "\s*(=[^;,\n]+[;,\n])?" ...  % =Value
            ;

            if this.Type==4 && opt.AutodeclareParameters
                return
            end

            code = [code, sprintf('\n')];
            whiteCode = code;

            % White out the inside of labels (single or double qouted text), keeping
            % the quotation marks.
            whiteCode = parser.White.whiteOutLabels(whiteCode);

            % White out first-level round and square brackets. This is to handle
            % assignments containing function calls with multiple arguments separated
            % with commas (commas are valid separator of parameters).
            whiteCode = parser.White.whiteOutParenth(whiteCode, 1);

            tokenExtents = regexp(whiteCode, NAME_PATTERN, 'tokenExtents');
            for i = 1 : numel(tokenExtents)
                if size(tokenExtents{i}, 1)==2
                    tokenExtents{i} = [ {[1, 0]}; tokenExtents{i} ];
                end
            end

            numQuantities = numel(tokenExtents);
            label = cell(1, numQuantities);
            name = cell(1, numQuantities);
            inxObserved = false(1, numQuantities);
            assignedString = cell(1, numQuantities);
            for i = 1 : numQuantities
                label{i} = code( tokenExtents{i}(1, 1)+1 : tokenExtents{i}(1, 2)-1 );
                name{i}  = code( tokenExtents{i}(2, 1) : tokenExtents{i}(2, 2)   );
                inxObserved(i) = tokenExtents{i}(3, 1)<=tokenExtents{i}(3, 2);
                assignedString{i} = code( tokenExtents{i}(4, 1)+1 : tokenExtents{i}(4, 2) );
            end

            name = strip(name);
            label = strip(label);
            assignedString = strip(assignedString);
            for i = 1 : numQuantities
                if endsWith(assignedString{i}, SEPARATORS)
                    assignedString{i}(end) = '';
                end
            end


            % Handle nonunique names: either shrink to the list of uniques
            % names and throw a warning if AllowMultiple=true, or throw and error

            [flag, nonuniqueNames, posUniques] = textual.nonunique(string(name));
            if flag
                if opt.AllowMultiple
                    % If multiple declaration of the same name is allowed, remove redundant
                    % declarations, and use the last one found
                    posUniques = sort(posUniques);
                    posUniques = reshape(posUniques, 1, []);
                    name = name(posUniques);
                    inxObserved = inxObserved(posUniques);
                    label = label(posUniques);
                    assignedString = assignedString(posUniques);
                    action = @exception.warning;
                else
                    % Otherwise, throw an error
                    [~, nonuniqueNames] = textual.nonunique(reshape(string(name), 1, []));
                    action = @exception.error;
                end
                action([
                    "Parser:NonuniqueNames"
                    "This name is declared more than once: %s "
                ], nonuniqueNames);
            end

            [label, alias] = this.splitLabelAlias(label);

            numQuantities = numel(name);
            qty.Name(end+(1:numQuantities)) = name;

            qty.IxObserved(end+(1:numQuantities)) = inxObserved;
            qty.Type(end+(1:numQuantities)) = repmat(this.Type, 1, numQuantities);
            qty.Label(end+(1:numQuantities)) = label;
            qty.Alias(end+(1:numQuantities)) = alias;
            qty.Attributes(end+(1:numQuantities)) = {attributes};
            qty.Bounds(:, end+(1:numQuantities)) = repmat(model.Quantity.DEFAULT_BOUNDS, 1, numQuantities);

            qty.IxLog(end+(1:numQuantities)) = repmat(this.IsLog, 1, numQuantities);
            qty.IxLagrange(end+(1:numQuantities)) = repmat(this.IsLagrange, 1, numQuantities);

            the.AssignedString = [the.AssignedString, assignedString];
        end%
    end
end

