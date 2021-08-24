classdef For < parser.control.Control
    properties
        ForBody
        DoBody
        ControlName
        Tokens (1, :) string
    end


    properties (Constant)
        CONTROL_NAME_PATTERN = "\?[^\s=!\.:;]*"
        FOR_PATTERN = "^(" + parser.control.For.CONTROL_NAME_PATTERN + ")\s*=(.*)"
        UPPER_CONTROL_PREFIX = "?:"
        LOWER_CONTROL_PREFIX = "?."
    end


    methods
        function this = For(c, sh)
            if nargin==0
                return
            end
            keyFor = parser.control.Keyword.FOR;
            keyDo = parser.control.Keyword.DO;
            keyReturn = parser.control.Keyword.RETURN;
            lenKeyFor = len(keyFor);
            lenKeyDo = len(keyDo);
            lenKeyReturn = len(keyReturn);
            this.ForBody = [ ];
            this.DoBody = [ ];
            le = cumsum(imag(sh));
            posDo = find(sh==keyDo & le==1);
            posReturn = find(sh==keyReturn & le==1);
            numDo = numel(posDo);
            numReturn = numel(posReturn);
            if (numDo+numReturn)==0
                return
            elseif (numDo+numReturn)>1
                throwCode(exception.ParseTime('Preparser:CTRL_FOR_MULTIPLE_DO', 'error'), c);
            end
            if numReturn==1
                posDo = posReturn;
                lenKeyDo = lenKeyReturn;
            end
            c1 = c(lenKeyFor+1:posDo-1);
            sh1 = sh(lenKeyFor+1:posDo-1);
            this.ForBody = parser.control.CodeSegments(c1, [ ], sh1);
            c2 = c(posDo+lenKeyDo:end);
            sh2 = sh(posDo+lenKeyDo:end);
            this.DoBody = parser.control.CodeSegments(c2, [ ], sh2);
        end%


        function c = writeFinal(this, preparserObj, varargin)
            c = '';
            if isempty(this.ForBody) || isempty(this.DoBody)
                return
            end

            forCode = writeFinal(this.ForBody, preparserObj, varargin{:});
            readForCode(this, forCode, preparserObj);
            c = expandDoCode(this, preparserObj, varargin{:});
        end%


        function readForCode(this, forCode, preparserObj)
            forCode = strip(forCode);
            tkn = regexp(forCode, parser.control.For.FOR_PATTERN, 'tokens', 'once');
            if ~isempty(tkn)
                controlName = tkn{1};
                forTokensCode = tkn{2};
            else
                controlName = '?';
                forTokensCode = forCode;
            end
            forTokensCode = string(forTokensCode);
            this.ControlName = controlName;

            % Matlab expressions may results in empty tokens
            [~, clearCode, tokens] = parser.Interp.parse(preparserObj, forTokensCode);

            % Remove hard typed !for tokens that are empty
            addTokens = regexp(string(clearCode), "[\s,;]+", "split");
            addTokens(addTokens=="") = [];

            tokens = [tokens, addTokens];
            this.Tokens = tokens;
        end%


        function c = expandDoCode(this, p, varargin)
            c = '';
            controlName = this.ControlName;

            for n = reshape(string(this.Tokens), 1, [])
                p.StoreForCtrl(end+1, :) = [string(controlName), n];
                c1 = writeFinal(this.DoBody, p, varargin{:});
                c = [c, c1]; %#ok<AGROW>
                p.StoreForCtrl(end, :) = [ ];
            end
        end%
    end


    methods (Static)
        function c = substitute(c, p)
            % Substitute for control variable in a code segment (called from within
            % other classes)
            if ~contains(c, "?")
                return
            end
            for i = 1 : size(p.StoreForCtrl, 1)
                ctrlName = p.StoreForCtrl(i, 1);
                tkn = p.StoreForCtrl(i, 2);
                if strlength(ctrlName)>1
                    % Substitute uppercase for ?:name
                    upperCtrlName = parser.control.For.UPPER_CONTROL_PREFIX + string(extractAfter(ctrlName, 1));
                    if contains(c, upperCtrlName)
                        c = replace(c, upperCtrlName, upper(tkn));
                    end
                    % Substitute lowercase for ?.name
                    lowerCtrlName = parser.control.For.LOWER_CONTROL_PREFIX + string(extractAfter(ctrlName, 1));
                    if contains(c, lowerCtrlName)
                        c = replace(c, lowerCtrlName, lower(tkn));
                    end
                end
                % Substitute for ?name
                c = replace(c, ctrlName, tkn);
            end
        end%
    end
end

