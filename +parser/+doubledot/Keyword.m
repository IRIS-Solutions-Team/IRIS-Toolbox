classdef Keyword
    enumeration
        SUM ('+')
        TIMES ('*')
        COMMA (',')
    end
    
    
    
    
    properties (SetAccess=immutable)
        Pattern
        Operator
    end
    
    
    
    
    properties (Constant)
        PATTERN_NUMBERS = '(?<=[a-zA-Z])\d+';
    end
    
    
    
    
    methods
        function this = Keyword(op)
            this.Operator = op;
            this.Pattern = [op, '..', op];
        end
        
        
        
        
        function c = parse(this, c)
            import parser.doubledot.Keyword;
            import parser.White;
            [ptnKey1, ptnKey2] = getPatterns(this);
            wh = White.whiteOutLabel(c);
            while true
                [start, finish, match, tkn] = ...
                    regexp(wh, ptnKey2, 'start', 'end', 'match', 'tokens', 'once');
                if ~isempty(start)
                    rpl = getReplacement(this, match, tkn);
                else
                    [start, finish, match, tkn] = ...
                        regexp(wh, ptnKey1, 'start', 'end', 'match', 'tokens', 'once');
                    if ~isempty(start)
                        rpl = getReplacement(this, match, tkn);
                    else
                        % No further doubledot found, terminate.
                        break
                    end
                end
                c = [ c(1:start-1), rpl, c(finish+1:end) ];
                wh = [ wh(1:start-1), rpl, wh(finish+1:end) ];
            end
        end
        
        
        
        
        function [ptn1, ptn2] = getPatterns(this)
            p = regexptranslate('escape', this.Pattern);
            ptn1 = [ ...
                '(\w+(\{[^\}]+\})?)\s*', ...
                p, ...
                '\s*(\w+(\{[^\}]+\})?)' ...
                ];
            ptn2 = ['\[([^\]]+)\]\s*', p, '\s*\[([^\]]+)\]'];
        end
        
        
        
        
        function rpl = getReplacement(this, match, tkn)
            firstToken = tkn{1};
            lastToken = tkn{2};
            firstNumbers = regexp(firstToken, this.PATTERN_NUMBERS, 'match');
            lastNumbers = regexp(lastToken, this.PATTERN_NUMBERS, 'match');
            firstPattern = regexprep(firstToken, this.PATTERN_NUMBERS, '?');
            lastPattern = regexprep(lastToken, this.PATTERN_NUMBERS, '?');
            firstPattern = regexprep(firstPattern, '\s+', '');
            lastPattern = regexprep(lastPattern, '\s+', '');
            if ~strcmp(firstPattern, lastPattern) ...
                    || isempty(firstNumbers) ...
                    || any(~strcmp(firstNumbers{1}, firstNumbers)) ...
                    || isempty(lastNumbers) ...
                    || any(~strcmp(lastNumbers{1}, lastNumbers))
                throwCode( ...
                    exception.ParseTime('Preparser:INVALID_DOUBLEDOT_PATTERN', 'error'), ...
                    match ...
                    );
            end
            pattern = firstPattern;
            from = sscanf(firstNumbers{1}, '%i');
            to = sscanf(lastNumbers{1}, '%i');
            rpl = expand(this, pattern, from, to);
        end
        
        
        
        
        function rpl = expand(this, pattern, from, to)
            step = 1;
            if from>to
                step = -1;
            end
            rpl = '';
            for i = from : step : to
                rpl = [rpl, strrep(pattern, '?', sprintf('%g', i))]; %#ok<AGROW>
                if i<to
                    rpl = [rpl, this.Operator]; %#ok<AGROW>
                end
            end
        end
    end
end
