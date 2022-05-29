classdef Pseudofunc
    enumeration
        DIFF        ( 'diff', '-', -1, '0', '',    '*' , ''   , '')
        DOT         ( 'diff', '/', -1, '1', '',    '^' , ''   , '')
        ROC         ( 'diff', '/', -1, '1', '',    '^' , ''   , '')
        PCT         ( 'diff', '/', -1, '1', '',    ''  , '-1' , '100*')
        DIFFLOG     ( 'diff', '-', -1, '0', 'log', '*' , ''   , '')
        MOVSUM      ( 'mov',  '+', -4, '0', '',    ''  , ''   , '')
        MOVPROD     ( 'mov',  '*', -4, '1', '',    ''  , ''   , '')
        MOVAVG      ( 'avg',  '+', -4, '0', '',    ''  , ''   , '')
        MOVGEOM     ( 'avg',  '*', -4, '1', '',    ''  , ''   , '')
    end




    properties (SetAccess=immutable)
        Type
        Operator
        DefaultK

        % EmptyReturn  Value to return if second (optional) input is zero
        EmptyReturn

        Transform
        BetaOperator

        ExtraTerm
        ExtraWrap
    end




    properties (Constant)
        TIME_SUBS_FORMAT_STRING = '%+.0f'
        NAME_WITH_SHIFT_PATTERN = '(\<[a-zA-Z][`\w]*\>\{[\d\+-]+)\}'
        NAME_WITH_NO_SHIFT_PATTERN = '(\<[a-zA-Z][`\w]*\>)(?![\(\{\.])'
        ARITHMETIC_AVG_FORMAT = '/%g';
        GEOMETRIC_AVG_FORMAT = '^(1/%g)';
    end




    methods
        function this = Pseudofunc(type, op, defaultK, emptyReturn, transform, betaOp, extraTerm, extraWrap)
            this.Type = type;
            this.Operator = op;
            this.DefaultK = defaultK;
            this.EmptyReturn = emptyReturn;
            this.Transform = transform;
            this.BetaOperator = betaOp;
            this.ExtraTerm = extraTerm;
            this.ExtraWrap = extraWrap;
        end%




        function c = parseKeyword(this, c)
            ptnKey = getPattern(this);
            wh = parser.White.whiteOutLabels(c);
            % Track down opening and closing brackets.
            sh = this.createShadowCode(wh);
            while true
                [startKey, openBracket] = regexp(wh, ptnKey, 'start', 'end', 'once');
                if isempty(startKey)
                    % No further pseudofunction found, terminate
                    break
                end
                roundLevel = cumsum(real(sh(openBracket:end)));
                squareLevel = cumsum(imag(sh(openBracket:end)));
                level = roundLevel + squareLevel;
                closeBracket = find(level==0, 1);
                if isempty(closeBracket)
                    throwCode( ...
                        exception.ParseTime('Preparser:PSEUDOFUNC_UNFINISHED', 'error'), ...
                        c(startKey:end) ...
                    );
                end
                level = level(1:closeBracket);
                closeBracket = openBracket + closeBracket - 1;
                % Last comma at level 1 separates second (optional) input argument
                temp = wh(openBracket:closeBracket);
                posDelim = [1, find(temp==',' & level==1), length(temp)];
                numArgs = numel(posDelim) - 1;
                args = cell(1, numArgs);
                for i = 1 : numArgs
                    args{i} = strip(temp(posDelim(i)+1:posDelim(i+1)-1));
                end
                args = resolveDefaultArg(this, args);
                if isnan(args{2})
                    throwCode( ...
                        exception.ParseTime('Preparser:PSEUDOFUNC_SECOND_INPUT_FAILED', 'error'), ...
                        c(startKey:end) ...
                    );
                end
                repl = expand(this, args{:});
                shRepl = this.createShadowCode(repl);
                c = [ c(1:startKey-1), repl, c(closeBracket+1:end) ];
                wh = [ wh(1:startKey-1), repl, wh(closeBracket+1:end) ];
                sh = [ sh(1:startKey-1), shRepl, sh(closeBracket+1:end) ];
            end
        end%




        function args = resolveDefaultArg(this, args)
            if numel(args)<2 || strlength(args{2})==0
                args{2} = this.DefaultK;
            else
                try
                    args{2} = eval(args{2});
                catch
                    args{2} = NaN;
                end
                if isnumeric(args{2})
                    args{2} = reshape(args{2}, 1, [ ]);
                else
                    args{2} = NaN;
                end
            end
        end%%




        function body = expand(this, varargin)
            [body, diffops] = varargin{1:2};
            body = char(body);
            diffops = reshape(double(diffops), 1, [ ]);
            if ~isnumeric(diffops) || any(diffops==0)
                repl = this.EmptyReturn;
                return
            end
            numDiffops = numel(diffops);
            for i = 1 : numDiffops
                transform = i==1; % [^1]
                enclose = i==numDiffops; % [^2]
                % [^1]: Apply transformation, such as log( ), only when
                % expanding the pseudofunction the first time
                % [^2]: Wrap the expansion in an extra pair of parentheses
                % only when expending the pseudofunction the last time

                [list, beta] = createAllTerms(this, body, diffops(i), varargin{3:end});
                body = concatenateTerms(this, list, beta, transform, enclose);
            end
        end%




        function [list, beta] = createAllTerms(this, body, shift, varargin)
            beta = '';
            body(isstrprop(body, 'wspace')) = '';
            switch this.Type
                case 'diff'
                    if isempty(shift)
                        shift = -1;
                    end
                    if ~isempty(varargin)
                        beta = varargin{1};
                        if ~isempty(beta) && isempty(regexp(beta, '^[\w\.]+$', 'once'))
                            beta = ['(', beta, ')'];
                        end
                    end
                    temp = this.shiftTimeSubs(body, shift);
                    list = { body, temp };
                case {'mov', 'avg'}
                    if isempty(shift)
                        shift = -4;
                    end
                    time = 0 : sign(shift) : shift;
                    time(end) = [ ];
                    numTimes = length(time);
                    list = cell(1, numTimes);
                    list{1} = body;
                    for i = 2 : numTimes
                        list{i} = this.shiftTimeSubs(body, time(i));
                    end
            end
        end%




        function c = concatenateTerms(this, list, beta, transform, enclose)
            list = strcat('(', list, ')');
            if transform
                list = strcat(this.Transform, list);
            end
            if length(list)==1
                c = list{1};
                return
            end
            lenList = numel(list);
            c = list{1};
            for i = 2 : lenList
                if ~isempty(beta) && ~isempty(this.BetaOperator)
                    list{i} = ['(', list{i}, this.BetaOperator, beta, ')'];
                end
                c = [c, this.Operator, list{i}]; %#ok<AGROW>
            end
            c = [c, this.ExtraTerm];
            if ~isempty(this.ExtraWrap)
                c = [this.ExtraWrap, '(', c, ')'];
            end
            if all(strcmpi(this.Type, 'avg'))
                switch this.Operator
                    case '+'
                        format = this.ARITHMETIC_AVG_FORMAT;
                    case '*'
                        format = this.GEOMETRIC_AVG_FORMAT;
                end
                c = ['(', c, ')', sprintf(format, lenList)];
            end
            if enclose
                c = ['(', c, ')'];
            end
        end%




        function ptn = getPattern(this)
            ptn = ['\<', lower(char(this)), '\>\s*\('];
        end%




        function n = len(this)
            n = length(char(this));
        end%
    end




    methods (Static)
        function sh = createShadowCode(c)
            c = char(c);
            sh = zeros(1, strlength(c));
            sh(c=='(') = 1;
            sh(c==')') = -1;
            sh(c=='[') = 1i;
            sh(c==']') = -1i;
        end%



        function c = shiftTimeSubs(c, k)
            if isstring(k) || ischar(k)
                s = char(k);
            else
                s = sprintf(parser.Pseudofunc.TIME_SUBS_FORMAT_STRING, k);
            end
            % Shift existing time subs, name{-1} -> name{-1+4}
            c = regexprep(c, parser.Pseudofunc.NAME_WITH_SHIFT_PATTERN, ['$1' , s, '}'] );
            % Add time subs to names with no time subs, name -> name{+4}
            c = regexprep(c, parser.Pseudofunc.NAME_WITH_NO_SHIFT_PATTERN, ['$1{', s, '}']);
        end%


        function c = parse(p, keywords)
            inputClass = class(p);
            switch inputClass
                case 'char'
                    c = p;
                case 'string'
                    c = char(p);
                otherwise
                    c = p.Code;
            end
            if nargin<2
                keywords = enumeration('parser.Pseudofunc');
            end
            for key = reshape(keywords, 1, [ ])
                if ~contains(c, lower(char(key)))
                    continue
                end
                c = parseKeyword(key, c);
            end
            switch inputClass
                case 'char'
                    % Do nothing
                case 'string'
                    c = string(c);
                otherwise
                    p.Code = c;
            end
        end%
    end
end
