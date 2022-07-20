classdef Equation < parser.theparser.Generic
    properties
        Type = double.empty(1, 0)
        ApplyEquationSwitch = true
    end


    properties (Constant)
        SEPARATE = '!!'
        READ_STEADY_ONLY = '!!:'
        READ_DYNAMIC_ONLY = ':!!'
    end


    methods
    end


    methods (Static)
        function eqtn = splitCodeIntoEquations(code)
            EQUATION_PATTERN = '[^;]+;';
                        % Replace mulitple labels with the last one.
            MULTIPLE_LABEL_PATTERN = '(("[^"]*"|''[^'']*'')\s*)+("[^"]*"|''[^'']*'')';
            % Split the entire block into individual equations.
            whBlk = parser.White.whiteOutLabels(code);
            [from, to] = regexp(whBlk, EQUATION_PATTERN, 'start', 'end');
            numEquations = length(from);
            eqtn = cell(1, numEquations);
            if numEquations==0
                return
            end
            for iEqtn = 1 : numEquations
                eqtn{iEqtn} = code( from(iEqtn):to(iEqtn) );
            end            
            % Replace multiple labels with the last one.
            eqtn = regexprep(eqtn, MULTIPLE_LABEL_PATTERN, '$2');
            % Trim the equations, otherwise labels at the beginning would not be
            % matched.
            eqtn = strtrim(eqtn);
        end%




        function [lhs, sign, rhs, ixMissing] = splitLhsSignRhs(eqn)
            numEquations = length(eqn);
            lhs = cell(1, numEquations);
            rhs = cell(1, numEquations);
            sign = cell(1, numEquations);
            [from, to] = regexp(eqn, ':=|=#|\+=|=', 'once', 'start', 'end');
            ixSign = ~cellfun(@isempty, from);
            for i = 1 : numEquations
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
                isintscalar = @(x) isnumeric(x) && isscalar(x) && round(x)==x;
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




        function [dynamic, steady, steadyFilled] = extractDynamicAndSteady(input)
            separator = parser.theparser.Equation.SEPARATE; 
            lenSeparator = length(separator);

            numEquations = numel(input);
            dynamic = cell(1, numEquations);
            steady = cell(1, numEquations);

            posSeparate = strfind(input, separator);
            inxEmpty = cellfun(@isempty, posSeparate);

            dynamic(inxEmpty) = input(inxEmpty);
            steady(inxEmpty) = {''};

            dynamic(~inxEmpty) = cellfun( @(eqn, pos) eqn(1:pos-1), ...
                                            input(~inxEmpty), ...
                                            posSeparate(~inxEmpty), ...
                                            'UniformOutput', false );
            steady(~inxEmpty) = cellfun( @(eqn, pos) eqn(pos+lenSeparator:end), ...
                                           input(~inxEmpty), ...
                                           posSeparate(~inxEmpty), ...
                                           'UniformOutput', false );
            if nargout>=3
                steadyFilled = steady;
                steadyFilled(inxEmpty) = dynamic(inxEmpty);
            end
        end%
    end
end
