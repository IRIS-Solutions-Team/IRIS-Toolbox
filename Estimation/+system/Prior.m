classdef Prior < handle
    properties
        Expression = char.empty(1, 0)
        ParsedExpression = char.empty(1, 0)
        Function
        Distribution
        LowerBound
        UpperBound
    end


    methods
        function this = Prior(varargin)
            if nargin==0
                return
            end
            if nargin==1 && isa(varargin{1}, 'system.Prior')
                this = varargin{1};
            end
            this.Expression = varargin{1};
            this.Distribution = varargin{2};
            this.LowerBound = varargin{3};
            this.UpperBound = varargin{4};
        end
        
            
        function seal(this, systemPriorWrapper)
            lenThis = length(this);
            functionHeader = systemPriorWrapper.FunctionHeader;
            for i = 1 : lenThis
                parseExpression(this(i), systemPriorWrapper);
                this(i).Function = str2func( ...
                    [functionHeader, this(i).ParsedExpression] ...
                );
            end
        end


        function parseExpression(this, systemPriorWrapper)
            expression = this.Expression;
            expression = [expression, ' '];
            position = 1;
            while true
                white = expression;
                white(1:position-1) = ' ';
                [start, match] = regexp( ...
                    white, '\<[a-zA-Z]\w*\>', 'start', 'match', 'once' ...
                );
                if isempty(start)
                    break
                end
                replace = match;
                ell = lookup(systemPriorWrapper.Quantity, {match});
                if ~isnan(ell.PosName)
                    replace = sprintf('Value(%g)', ell.PosName);
                elseif ~isnan(ell.PosStdCorr)
                    replace = sprintf('StdCorr(%g)', ell.PosStdCorr);
                elseif any(strcmp(match, systemPriorWrapper.SystemPropertyNames)) ...
                        && expression(start + length(match))=='('
                    open = start + length(match);
                    close = textfun.matchbrk(expression, open);
                    reference = expression(open:close);
                    replace = system.Prior.replaceSystemPropertyReference( ...
                        systemPriorWrapper, match, reference ...
                    );
                    replace = [match, replace];
                    match = expression(start:close);
                end
                if strcmp(match, replace)
                    position = start + length(match);
                else
                    expression = [ ...
                        expression(1:start-1), ...
                        replace, ...
                        expression(start+length(match):end) ...
                    ];
                    position = start + length(replace);
                end
            end
            this.ParsedExpression = strtrim(expression);
        end
    end


    methods (Static)
        function replace = replaceSystemPropertyReference(systemPriorWrapper, match, reference)
            index = strcmp(match, systemPriorWrapper.SystemPropertyNames);
            specifics = systemPriorWrapper.SystemPropertySpecifics{index};
            parts = split(reference(2:end-1), ',');
            parts = strtrim(parts);
            for i = 1 : min(length(parts), length(specifics.Names))
                ithIndex = strcmp(parts{i}, specifics.Names{i});
                if any(ithIndex)
                    parts{i} = sprintf('%g', find(ithIndex));
                end
            end
            replace = sprintf('%s,', parts{:});
            replace = ['(', replace(1:end-1), ')'];
        end
    end
end
