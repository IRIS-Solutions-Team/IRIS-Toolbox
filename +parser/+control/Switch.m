classdef Switch < parser.control.Conditional
    properties
        SwitchExpn
        CaseMatch
        CaseBody
        OtherwiseBody
    end
    
    
    
    
    methods
        function this = Switch(varargin)
            if isempty(varargin)
                return
            end
            c = varargin{1};
            sh = varargin{2};
            construct(this, c, sh);
        end
        
        
        
        
        function construct(this, c, sh)
            import parser.control.*;
            keySwitch = Keyword.SWITCH;
            keyCase = Keyword.CASE;
            keyOther = Keyword.OTHERWISE;
            % posNextKeyFunc - Anonymous function to return position of next !case or
            % !otherwise, or end of string.
            posNextKeyFunc = @(sh,le) ...
                min([ ...
                length(sh), ...
                find(((sh==keyCase | sh==keyOther) & le==1),1), ...
                ]);
            % le - Level of nested control commands.
            le = cumsum(imag(sh));           
            this.SwitchExpn = [ ];
            this.CaseMatch = { };
            this.CaseBody = { };
            this.OtherwiseBody = [ ];
            [cond,c,sh,le] = Switch.separateCondition(keySwitch,c,sh,le);
            this.SwitchExpn = cond;
            posSwitchEnd = posNextKeyFunc(sh,le);
            % leftover - Leftover code between !switch expression and the next keyword.
            leftover = c(1:posSwitchEnd-1);
            leftover(isstrprop(leftover,'wspace')) = '';
            if ~isempty(leftover)
                throwCode(exception.ParseTime('Preparser:CTRL_LEFTOVER', 'error'), c);
            end
            % Cycle over all !case keywords.
            while true
                % Beginning of the next !case at level 1, if any.
                posCase = find(sh==keyCase & le==1,1);
                if isempty(posCase)
                    break
                end
                % Separate the keyword, !case, and its expression from the rest of the
                % string. The input string c contains the current keyword, !switch or
                % !case.
                c = c(posCase:end);
                sh = sh(posCase:end);
                le = le(posCase:end);
                [cond, c, sh, le] = Switch.separateCondition(keyCase, c, sh, le);
                this.CaseMatch{end+1} = cond;
                % End of this !case body.
                posCaseEnd = posNextKeyFunc(sh, le);
                parseC = c(1:posCaseEnd-1);
                parseSh = sh(1:posCaseEnd-1);
                this.CaseBody{end+1} = CodeSegments(parseC, [ ], parseSh);
                % Keep the next keyword in.
                c = c(posCaseEnd:end);
                sh = sh(posCaseEnd:end);
                le = le(posCaseEnd:end);
            end
            % Position of the final !otherwise at level 1, if any.
            posOther = find(sh==keyOther & le==1, 1);
            if ~isempty(posOther)
                c = c(posOther+len(keyOther):end);
                sh = sh(posOther+len(keyOther):end);
                this.OtherwiseBody = CodeSegments(c, [ ], sh);
            end
        end        
        
        
        
        
        function c = writeFinal(this, p, varargin)
            import parser.Preparser;
            import parser.control.For;
            c = '';
            try
                switchExp = this.SwitchExpn;
                if ~isempty(p.StoreForCtrl) && ~isempty(strfind(switchExp, '?'))
                    switchExp = For.substitute(switchExp, p);
                end
                switchExp = Preparser.eval(switchExp, p.Assigned, p);
            catch
                addEvalWarning('Switch', p, this.SwitchExpn);
                this.CaseMatch = { };
                this.CaseBody = { };
            end
            for i = 1 : length(this.CaseMatch)
                try
                    caseMatch = this.CaseMatch{i};
                    if ~isempty(p.StoreForCtrl) && ~isempty(strfind(caseMatch, '?'))
                        caseMatch = For.substitute(caseMatch, p);
                    end
                    caseMatch = Preparser.eval(caseMatch, p.Assigned, p);
                catch
                    addEvalWarning('Case', p, this.CaseMatch{i});
                    continue
                end
                if isequal(switchExp,caseMatch)
                    c = writeFinal(this.CaseBody{i}, p, varargin{:});
                    return
                end
            end
            if ~isempty(this.OtherwiseBody)
                c = writeFinal(this.OtherwiseBody, p, varargin{:});
            end 
        end        
    end
end
