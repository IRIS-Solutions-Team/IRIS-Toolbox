classdef Equation < parser.theparser.Generic
    properties
        Type
        IsAppliedSteadyOnlyOpt = true
    end
    
    
    properties (Constant)
        SEPARATE = '!!'
        READ_STEADY_ONLY = '!!:'
        READ_DYNAMIC_ONLY = ':!!'
    end
    
    
    methods
        function [qty, eqn] = parse(this, ~, code, qty, eqn, euc, ~, opt)
            % 'Label' x=0.8*x{-1}+ex !! x=0;
            LABEL_PATTERN =       '\s*(?<LABEL>"[^\n"]*"|''[^\n'']*'')?';
            EQUATION_PATTERN =    '(?<EQUATION>[^;]+);';
                        
            %--------------------------------------------------------------------------
                        
            % Split the code block into individual equations
            listOfEquations = this.splitCodeIntoEquations(code);
            if isempty(listOfEquations)
                return
            end
                        
            % Separate labels and equations
            ptn = [LABEL_PATTERN, EQUATION_PATTERN];
            tkn = regexp(listOfEquations, ptn, 'names', 'once');
            tkn( cellfun(@isempty, tkn) ) = [ ];
            tkn = [ tkn{:} ];
            
            listOfLabels = { tkn.LABEL };
            listOfEquations = { tkn.EQUATION };
            listOfEquations = regexprep(listOfEquations, '\s+', '');
            numOfEquations = numel(listOfEquations);
            
            % Separate dynamic and steady equations
            listOfEquations = readSteadyOnly(listOfEquations);
            listOfEquations = readDynamicOnly(listOfEquations);
            [listOfDynamic, listOfSteady] = extractDynamicAndSteady(listOfEquations);
                                    
            % Remove equations that are completely empty, no warning
            inxOfEmptyCanBeRemoved = cellfun(@isempty, listOfLabels) ...
                                   & cellfun(@isempty, listOfDynamic) ...
                                   & cellfun(@isempty, listOfSteady);
            if any(inxOfEmptyCanBeRemoved)
                listOfEquations(inxOfEmptyCanBeRemoved) = [ ] ;
                listOfLabels(inxOfEmptyCanBeRemoved) = [ ];
                listOfDynamic(inxOfEmptyCanBeRemoved) = [ ];
                listOfSteady(inxOfEmptyCanBeRemoved) = [ ];
            end
            
            % Throw a warning for equations that consist of labels only
            inxOfEmptyWarn = cellfun(@isempty, listOfDynamic) ...
                           & cellfun(@isempty, listOfSteady);
            if any(inxOfEmptyWarn)
                throw( exception.ParseTime('TheParser:EMPTY_EQUATION', 'warning'), ...
                       listOfEquations{inxOfEmptyWarn} );
                listOfEquations(inxOfEmptyWarn) = [ ] ; %#ok<UNRCH>
                listOfLabels(inxOfEmptyWarn) = [ ];
                listOfDynamic(inxOfEmptyWarn) = [ ];
                listOfSteady(inxOfEmptyWarn) = [ ];                
            end
            if isempty(listOfEquations)
                return
            end

            % Use steady equations for dynamic equations if requested by user
            if this.IsAppliedSteadyOnlyOpt && opt.SteadyOnly
                inxOfEmptyDynamic = cellfun(@isempty, listOfDynamic);
                inxOfEmptySteady = cellfun(@isempty, listOfSteady);
                inxToApply = ~inxOfEmptyDynamic & ~inxOfEmptySteady;
                listOfDynamic(inxToApply) = listOfSteady(inxToApply);
                listOfEquations(inxToApply) = listOfSteady(inxToApply);
                listOfSteady(inxToApply) = { char.empty(1, 0) };
            end
            
            % Remove quotation marks from labels
            for i = 1 : numel(listOfLabels)
                % Make sure empty labels are '' and not [1x0 char]
                if numel(listOfLabels{i})>2
                    listOfLabels{i} = listOfLabels{i}(2:end-1);
                end
            end
            
            % Validate and evaluate time subscripts, and get max and min shifts (these
            % only need to be determined from dynamic equations).
            [listOfDynamic, maxShDynamic, minShDynamic] = ...
                parser.theparser.Equation.evalTimeSubs(listOfDynamic);
            [listOfSteady, maxShSteady, minShSteady] = ...
                parser.theparser.Equation.evalTimeSubs(listOfSteady);
            
            % Split equations into LHS, sign, and RHS.
            [lhsDynamic, signDynamic, rhsDynamic, ixMissingDynamic] = this.splitLhsSignRhs(listOfDynamic);
            [lhsSteady, signSteady, rhsSteady, ixMissingSteady] = this.splitLhsSignRhs(listOfSteady);

            if any(ixMissingDynamic)
                throw( exception.Base('TheParser:EmptyLhsOrRhs', 'error'), ...
                       listOfEquations{ixMissingDynamic} );
            end
            if any(ixMissingSteady)
                throw( exception.Base('TheParser:EmptyLhsOrRhs', 'error'), ...
                       listOfEquations{ixMissingSteady} );
            end
            
            % Split labels into labels and aliases.
            [listOfLabels, alias] = this.splitLabelAlias(listOfLabels);
            
            if isempty(eqn)
                return
            end
            
            numOfEquations = length(listOfEquations);

            eqn.Input(end+(1:numOfEquations)) = listOfEquations;
            eqn.Label(end+(1:numOfEquations)) = listOfLabels;
            eqn.Alias(end+(1:numOfEquations)) = alias;
            eqn.Type(end+(1:numOfEquations)) = repmat(this.Type, 1, numOfEquations);
            eqn.Dynamic(end+(1:numOfEquations)) = repmat({char.empty(1, 0)}, 1, numOfEquations);
            eqn.Steady(end+(1:numOfEquations)) = repmat({char.empty(1, 0)}, 1, numOfEquations);
            eqn.IxHash(end+(1:numOfEquations)) = false(1, numOfEquations);

            if ~isequal(euc, [ ])
                euc.LhsDynamic(end+(1:numOfEquations)) = lhsDynamic;
                euc.SignDynamic(end+(1:numOfEquations)) = signDynamic;
                euc.RhsDynamic(end+(1:numOfEquations)) = rhsDynamic;
                euc.LhsSteady(end+(1:numOfEquations)) = lhsSteady;
                euc.SignSteady(end+(1:numOfEquations)) = signSteady;
                euc.RhsSteady(end+(1:numOfEquations)) = rhsSteady;
                euc.MaxShDynamic(end+(1:numOfEquations)) = maxShDynamic;
                euc.MinShDynamic(end+(1:numOfEquations)) = minShDynamic;
                euc.MaxShSteady(end+(1:numOfEquations)) = maxShSteady;
                euc.MinShSteady(end+(1:numOfEquations)) = minShSteady;
            end
        end
    end
    
    
    
    
    methods (Static)
        function eqtn = splitCodeIntoEquations(code)
            EQUATION_PATTERN = '[^;]+;';
                        % Replace mulitple labels with the last one.
            MULTIPLE_LABEL_PATTERN = '(("[^"]*"|''[^'']*'')\s*)+("[^"]*"|''[^'']*'')';
            % Split the entire block into individual equations.
            whBlk = parser.White.whiteOutLabel(code);
            [from, to] = regexp(whBlk, EQUATION_PATTERN, 'start', 'end');
            numOfEquations = length(from);
            eqtn = cell(1, numOfEquations);
            if numOfEquations==0
                return
            end
            for iEqtn = 1 : numOfEquations
                eqtn{iEqtn} = code( from(iEqtn):to(iEqtn) );
            end            
            % Replace multiple labels with the last one.
            eqtn = regexprep(eqtn, MULTIPLE_LABEL_PATTERN, '$2');
            % Trim the equations, otherwise labels at the beginning would not be
            % matched.
            eqtn = strtrim(eqtn);
        end%
        
        
        
        
        function [lhs, sign, rhs, ixMissing] = splitLhsSignRhs(eqn)
            numOfEquations = length(eqn);
            lhs = cell(1, numOfEquations);
            rhs = cell(1, numOfEquations);
            sign = cell(1, numOfEquations);
            [from, to] = regexp(eqn, ':=|=#|\+=|=', 'once', 'start', 'end');
            ixSign = ~cellfun(@isempty, from);
            for i = 1 : numOfEquations
                if ixSign(i)
                    lhs{i}  = eqn{i}( 1:from{i}-1 );
                    sign{i} = eqn{i}( from{i}:to{i} );
                    rhs{i}  = eqn{i}( to{i}+1:end );
                else
                    lhs{i}  = char.empty(1, 0);
                    sign{i} = char.empty(1, 0);
                    rhs{i}  = eqn{i};
                end
            end
            ixMissing = ixSign & (cellfun(@isempty, lhs) | cellfun(@isempty, rhs));
        end%
        
        
        
        
        function [eqtn, maxSh, minSh] = evalTimeSubs(eqtn)
            maxSh = 0;
            minSh = 0;
            lsInvalid = cell(1, 0);
            
            eqtn = strrep(eqtn, '{t+', '{+');
            eqtn = strrep(eqtn, '{t-', '{-');
            eqtn = strrep(eqtn, '{0}', '');
            eqtn = strrep(eqtn, '{-0}', '');
            eqtn = strrep(eqtn, '{+0}', '');
            
            % Replace standard time subscripts {k} with {@+k}.
            eqtn = regexprep(eqtn, '\{(\d+)\}', '{@+$1}');
            % Replace standard time subscripts {+k} or {-k} with {@+k} or {@-k}.
            eqtn = regexprep(eqtn, '\{([\+\-]\d+)\}', '{@$1}');
            
            % Find nonstandard time subscripts, try to evaluate them and replace with
            % a standard string.
            ptn = '\{[^@].*?\}';
            [from, to] = regexp(eqtn, ptn, 'start', 'end');
            for iEqtn = 1 : length(from)
                for j = length( from{iEqtn} ) : -1 : 1
                    c = eqtn{iEqtn}( from{iEqtn}(j):to{iEqtn}(j) );
                    evalNonstandardTimeSubs( );
                    eqtn{iEqtn} = [ ...
                        eqtn{iEqtn}( 1:from{iEqtn}(j)-1 ), ...
                        c, ...
                        eqtn{iEqtn}( to{iEqtn}(j)+1:end ), ...
                        ];
                end
            end
            
            if ~isempty(lsInvalid)
                throw( exception.ParseTime('TheParser:INVALID_TIME_SUBSCRIPT', 'error'), ...
                    lsInvalid{:} );
            end
            
            % Find max and min time shifts.
            c = regexp(eqtn, '\{@[+\-]\d+\}', 'match');
            c = [ c{:} ]; % Expand individual equations.
            c = [ c{:} ]; % Expand matches into one string.
            if ~isempty(c)
                x = sscanf(c, '{@%g}');
                x = [0;x(:)].';
                maxSh = max(x);
                minSh = min(x);
            end
            
            return
            
            
            
            
            function evalNonstandardTimeSubs( )
                try
                    % Use protected eval to avoid conflict with workspace.
                    xx = parser.theparser.Equation.protectedEval( c(2:end-1) );
                    if isintscalar(xx)
                        xx = round(xx);
                        if xx==0
                            c = '';
                            return
                        else
                            c = sprintf('{@%+g}', xx);
                            return
                        end
                    end
                catch
                    lsInvalid{end+1} = c;
                    c = '';
                    return
                end
            end%
        end%
        
        
        
        
        function varargout = protectedEval(varargin)
            varargout{1} = eval(varargin{1});
        end%
    end
end


%
% Local Functions
%


function [dynamic, steady] = extractDynamicAndSteady(input)
    separator = parser.theparser.Equation.SEPARATE; 
    lenOfSeparator = length(separator);

    numOfEquations = numel(input);
    dynamic = cell(1, numOfEquations);
    steady = cell(1, numOfEquations);

    posOfSeparate = strfind(input, separator);
    inxOfEmpty = cellfun(@isempty, posOfSeparate);

    dynamic(inxOfEmpty) = input(inxOfEmpty);
    steady(inxOfEmpty) = {''};
    
    dynamic(~inxOfEmpty) = cellfun( @(eqn, pos) eqn(1:pos-1), ...
                                    input(~inxOfEmpty), ...
                                    posOfSeparate(~inxOfEmpty), ...
                                    'UniformOutput', false );
    steady(~inxOfEmpty) = cellfun( @(eqn, pos) eqn(pos+lenOfSeparator:end), ...
                                   input(~inxOfEmpty), ...
                                   posOfSeparate(~inxOfEmpty), ...
                                   'UniformOutput', false );
end%




function input = readSteadyOnly(input)
    separator = parser.theparser.Equation.READ_STEADY_ONLY;
    lenOfSeparator = length(separator);
    posOfSeparator = strfind(input, separator);
    inxOfFound = ~cellfun(@isempty, posOfSeparator);
    if ~any(inxOfFound)
        return
    end
    input(inxOfFound) = cellfun( @(eqn, pos) eqn(pos+lenOfSeparator:end), ...
                                 input(inxOfFound), ...
                                 posOfSeparator(inxOfFound), ...
                                 'UniformOutput', false );
end%




function input = readDynamicOnly(input)
    separator = parser.theparser.Equation.READ_DYNAMIC_ONLY;
    lenOfSeparator = length(separator);
    posOfSeparator = strfind(input, separator);
    inxOfFound = ~cellfun(@isempty, posOfSeparator);
    if ~any(inxOfFound)
        return
    end
    input(inxOfFound) = cellfun( @(eqn, pos) eqn(1:pos-1), ...
                                 input(inxOfFound), ...
                                 posOfSeparator(inxOfFound), ...
                                 'UniformOutput', false );
end%

