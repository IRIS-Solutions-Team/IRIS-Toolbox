classdef If < parser.control.Conditional
    properties
        IfCond
        IfBody
        ElseBody
    end
    
    
    
    
    methods
        function this = If(varargin)
            if isempty(varargin)
                return
            end
            c = varargin{1};
            sh = varargin{2};
            construct(this, c, sh);
        end
        
        
        
        
        function construct(this, c, sh)
            import parser.control.*
            keyIf = Keyword.IF;
            keyElseif = Keyword.ELSEIF;
            keyElse = Keyword.ELSE;
            % Level of nested control commands.
            le = cumsum(imag(sh));
            this.IfCond = { };
            this.IfBody = { };
            this.ElseBody = [ ];
            key = keyIf;
            while true
                % Separate the keyword and condition from the rest of the string. The input
                % string c contains the current keyword, !if or !elseif.
                [cond, c, sh, le] = If.separateCondition(key, c, sh, le);                
                this.IfCond{end+1} = cond;
                % Position of the next !elseif at level 1, if any.
                key = keyElseif;
                posElseif = find(sh==keyElseif & le==1, 1);
                if isempty(posElseif)
                    break
                end
                parseC = c(1:posElseif-1);
                parseSh = sh(1:posElseif-1);
                this.IfBody{end+1} = CodeSegments(parseC, [ ], parseSh);
                % Keep the following keyword, !elseif, in the string c.
                c = c(posElseif:end);
                sh = sh(posElseif:end);
                le = le(posElseif:end);
            end
            % Position of the final !else at level 1, if any.
            posElse = find(sh==keyElse & le==1, 1);
            if isempty(posElse)
                % Populate the last !if or !elseif body.
                this.IfBody{end+1} = CodeSegments(c, [ ], sh);
            else
                parseC = c(1:posElse-1);
                parseSh = sh(1:posElse-1);
                % Populate last if or elseif body.
                this.IfBody{end+1} = CodeSegments(parseC, [ ], parseSh);
                c = c(posElse+len(keyElse):end);
                sh = sh(posElse+len(keyElse):end);
                this.ElseBody = CodeSegments(c, [ ], sh);
            end
        end
        
        
        
        
        function c = writeFinal(this, p, varargin)
            import parser.Preparser;
            import parser.control.For;
            c = '';
            for i = 1 : length(this.IfCond)
                try
                    cond = this.IfCond{i};
                    if ~isempty(p.StoreForCtrl) && contains(cond, '?')
                        cond = For.substitute(cond, p);
                    end
                    value = Preparser.eval(cond, p.Assigned, p);
                catch
                    value = false;
                    addEvalWarning('If', p, this.IfCond{i});
                end
                if isequal(value, true)
                    c = writeFinal(this.IfBody{i}, p, varargin{:});
                    return
                end
            end
            if ~isempty(this.ElseBody)
                c = writeFinal(this.ElseBody, p, varargin{:});
            end 
        end        
    end
end
