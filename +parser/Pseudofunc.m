classdef Pseudofunc
    enumeration
        DIFF        ( 'diff', '-', -1, '0', '',    '*' )
        DOT         ( 'diff', '/', -1, '1', '',    '^' )
        ROC         ( 'diff', '/', -1, '1', '',    '^' )
        DIFFLOG     ( 'diff', '-', -1, '0', 'log', '*' )
        MOVSUM      ( 'mov',  '+', -4, '0', '',    ''  )
        MOVPROD     ( 'mov',  '*', -4, '1', '',    ''  )
        MOVAVG      ( 'avg',  '+', -4, '0', '',    ''  )
        MOVGEOM     ( 'avg',  '*', -4, '1', '',    ''  )
    end
    
    
    
    
    properties (SetAccess=immutable)
        Type
        Operator
        DefaultK

        % EmptyReturn  Value to return if second (optional) input is zero  
        EmptyReturn 

        Transform
        BetaOperator
    end
    
    
    
    
    properties (Constant)
        TIME_SUBS_FORMAT_STRING = '%+.0f'
        NAME_WITH_SHIFT_PATTERN = '(\<[a-zA-Z][`\w]*\>\{[\d\+-]+)\}'
        NAME_WITH_NO_SHIFT_PATTERN = '(\<[a-zA-Z][`\w]*\>)(?![\(\{\.])'
        ARITHMETIC_AVG_FORMAT = '/%g';
        GEOMETRIC_AVG_FORMAT = '^(1/%g)';
    end
    
    
    
    
    methods
        function this = Pseudofunc(type, op, defaultK, emptyReturn, transform, betaOp)
            this.Type = type;
            this.Operator = op;
            this.DefaultK = defaultK;
            this.EmptyReturn = emptyReturn;
            this.Transform = transform;
            this.BetaOperator = betaOp;
        end%
        
        
        
        
        function c = parseKeyword(this, c)
            import parser.Pseudofunc
            import parser.White
            ptnKey = getPattern(this);
            wh = White.whiteOutLabel(c);
            % Track down opening and closing brackets.
            sh = this.createShadowCode(wh);
            while true
                [startKey, openBracket] = regexp(wh, ptnKey, 'start', 'end', 'once');
                if isempty(startKey)
                    % No further pseudofunction found, terminate.
                    break
                end
                level = cumsum(sh(openBracket:end));
                closeBracket = find(level==0, 1);
                if isempty(closeBracket)
                    throwCode( exception.ParseTime('Preparser:PSEUDOFUNC_UNFINISHED', 'error'), ...
                               c(startKey:end) );
                end
                level = level(1:closeBracket);
                closeBracket = openBracket + closeBracket - 1;
                % Last comma at level 1 separates second (optional) input argument.
                temp = wh(openBracket:closeBracket);
                posDelim = [1, find(temp==',' & level==1), length(temp)];
                nArg = length(posDelim) - 1;
                arg = cell(1, nArg);
                for i = 1 : nArg
                    arg{i} = strtrim( temp(posDelim(i)+1:posDelim(i+1)-1) );
                end
                arg = resolveDefaultArg(this, arg);
                if isnan(arg{2})
                    throwCode( exception.ParseTime('Preparser:PSEUDOFUNC_SECOND_INPUT_FAILED', 'error'), ...
                               c(startKey:end) );
                end
                repl = replaceCode(this, arg{:});
                shRepl = this.createShadowCode(repl);
                c = [ c(1:startKey-1), repl, c(closeBracket+1:end) ];
                wh = [ wh(1:startKey-1), repl, wh(closeBracket+1:end) ];
                sh = [ sh(1:startKey-1), shRepl, sh(closeBracket+1:end) ];
            end
        end%
        
        
        
        
        function arg = resolveDefaultArg(this, arg)
            if length(arg)==1
                arg{2} = '';
            end
            k = arg{2};
            if isempty(k)
                k = this.DefaultK;
            else
                k = sscanf(k, '%g');
                if ~isnumericscalar(k)
                    k = NaN;
                end
            end
            arg{2} = k;
        end%%
        
        
        
        
        function repl = replaceCode(this, varargin)
            body = varargin{1};
            k = varargin{2};
            varargin(1:2) = [ ];
            if k==0
                repl = this.EmptyReturn;
                return
            end
            [list, beta] = createAllTerms(this, body, k, varargin{:});
            repl = concatenateTerms(this, list, beta);
        end%
        
        
        
        
        function [list, beta] = createAllTerms(this, body, k, varargin)
            import parser.Pseudofunc
            beta = '';
            body(isstrprop(body, 'wspace')) = '';
            switch this.Type
                case 'diff'
                    if isempty(k)
                        k = -1;
                    end
                    if ~isempty(varargin)
                        beta = varargin{1};
                        if ~isempty(beta) && isempty(regexp(beta, '^[\w\.]+$', 'once'))
                            beta = ['(', beta, ')'];
                        end
                    end                    
                    temp = this.shiftTimeSubs(body, k);
                    list = { body, temp };
                case {'mov', 'avg'}
                    if isempty(k)
                        k = -4;
                    end
                    time = 0 : sign(k) : k;
                    time(end) = [ ];
                    nTime = length(time);
                    list = cell(1, nTime);
                    list{1} = body;
                    for i = 2 : nTime
                        list{i} = this.shiftTimeSubs(body, time(i));
                    end
            end
        end%
        
        
        
        
        function c = concatenateTerms(this, list, beta)
            import parser.Pseudofunc
            list = strcat(this.Transform, '(', list, ')' );
            if length(list)==1
                c = list{1};
                return
            end
            nList = length(list);
            c = list{1};
            for i = 2 : nList
                if ~isempty(beta)
                    list{i} = ['(', list{i}, this.BetaOperator, beta, ')'];
                end
                c = [c, this.Operator, list{i}]; %#ok<AGROW>
            end
            c = ['(', c, ')'];
            if isequal(this.Type, 'avg')
                switch this.Operator
                    case '+'
                        format = this.ARITHMETIC_AVG_FORMAT;
                    case '*'
                        format = this.GEOMETRIC_AVG_FORMAT;
                end
                c = ['(', c, sprintf(format, nList), ')'];
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
            sh = zeros(1, length(c), 'int8');
            sh(c=='(') = 1;
            sh(c==')') = -1;
        end%
        
        
        
        function c = shiftTimeSubs(c, k)
            import parser.Pseudofunc
            s = sprintf(Pseudofunc.TIME_SUBS_FORMAT_STRING, k);
            % Shift existing time subs, name{-1} -> name{-1+4}.
            c = regexprep(c, Pseudofunc.NAME_WITH_SHIFT_PATTERN, ['$1' , s, '}'] );
            % Add time subs to names with no time subs, name -> name{+4}.
            c = regexprep(c, Pseudofunc.NAME_WITH_NO_SHIFT_PATTERN, ['$1{', s, '}']);
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
            for key = transpose(keywords)
                if isempty( strfind(c, lower(char(key))) )
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
