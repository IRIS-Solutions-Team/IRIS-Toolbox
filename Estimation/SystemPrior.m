classdef SystemPrior < handle
    properties
        Expression = char.empty(1, 0)
        ParsedExpression = char.empty(1, 0)
        Function
        Distribution
        LowerBound
        UpperBound
    end


    methods
        function this = SystemPrior(varargin)
            persistent INPUT_PARSER
            if isempty(INPUT_PARSER)
                INPUT_PARSER = extend.InputParser('SystemPriorWrapper.addSystemPrior');
                INPUT_PARSER.addRequired('Expression', @(x) ischar(x) || isa(x, 'string'));
                INPUT_PARSER.addRequired('Distribution', @(x) isa(x, 'distribution.Abstract'));
                INPUT_PARSER.addParameter('LowerBound', -Inf, @(x) isnumeric(x) && isscalar(x));
                INPUT_PARSER.addParameter('UpperBound', Inf, @(x) isnumeric(x) && isscalar(x));
            end
            if nargin==0
                return
            end
            if nargin==1 && isa(varargin{1}, 'SystemPrior')
                this = varargin{1};
                return
            end
            INPUT_PARSER.parse(varargin{:});
            opt = INPUT_PARSER.Options;
            this.Expression = INPUT_PARSER.Results.Expression;
            this.Distribution = INPUT_PARSER.Results.Distribution;
            this.LowerBound = opt.LowerBound;
            this.UpperBound = opt.UpperBound;
        end
        
            
        function seal(this, systemPriorWrapper)
            functionHeader = systemPriorWrapper.FunctionHeader;
            for i = 1 : numel(this)
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
                [startName, endName, match] = regexp( ...
                    white, '\<[a-zA-Z]\w*\>', ...
                    'start', 'end', 'match', 'once' ...
                );
                if isempty(startName)
                    break
                end
                replace = match;
                ell = lookup(systemPriorWrapper.Quantity, {match});
                if ~isnan(ell.PosName)
                    replace = sprintf('Value(%g)', ell.PosName);
                elseif ~isnan(ell.PosStdCorr)
                    replace = sprintf('StdCorr(%g)', ell.PosStdCorr);
                elseif existsOutputName(systemPriorWrapper, match) ...
                        && expression(endName+1)=='('
                    posOpenBananas = endName + 1;
                    posCloseBananas = textual.matchBrackets(expression, posOpenBananas);
                    bananaReferences = expression(posOpenBananas:posCloseBananas);
                    replace = replaceSystemPropertyReferences( ...
                        systemPriorWrapper, match, bananaReferences ...
                    );
                    replace = [match, replace];
                    match = expression(startName:posCloseBananas);
                end
                if strcmp(match, replace)
                    position = startName + length(match);
                else
                    expression = [ ...
                        expression(1:startName-1), ...
                        replace, ...
                        expression(startName+length(match):end) ...
                    ];
                    position = startName + length(replace);
                end
            end
            this.ParsedExpression = strtrim(expression);
        end
    end
end
