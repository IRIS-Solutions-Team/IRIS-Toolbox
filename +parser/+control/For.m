classdef For < parser.control.Control
    properties
        ForBody
        DoBody
        ControlName
        Token
    end
    
    
    
    
    properties (Constant)
        CONTROL_NAME_PATTERN = '\?[^\s=!\.:;]*'
        
        FOR_PATTERN = [ '^(', parser.control.For.CONTROL_NAME_PATTERN, ')', ...
                        '\s*=(.*)' ]
    end
    
    
    
    
    methods
        function this = For(c, sh)
            import parser.control.*
            if nargin==0
                return
            end
            keyFor = Keyword.FOR;
            keyDo = Keyword.DO;
            keyReturn = Keyword.RETURN;
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
            this.ForBody = CodeSegments(c1, [ ], sh1);
            c2 = c(posDo+lenKeyDo:end);
            sh2 = sh(posDo+lenKeyDo:end);
            this.DoBody = CodeSegments(c2, [ ], sh2);
        end%
        
        
        
        
        function c = writeFinal(this, preparserObj, varargin)
            import parser.Preparser;
            c = '';
            if isempty(this.ForBody) || isempty(this.DoBody)
                return
            end
%             forCode = writeFinal(this.ForBody, preparserObj,, varargin{:});
%             doCode = writeFinal(this.DoBody, preparserObj, varargin{:});
%             readForCode(this, forCode, preparserObj);
%             c = replaceDoCode(this, doCode);
            
            forCode = writeFinal(this.ForBody, preparserObj, varargin{:});
            readForCode(this, forCode, preparserObj);
            c = expandDoCode(this, preparserObj, varargin{:});
        end%
        
        
        
        
        function readForCode(this, forCode, preparserObj)
            import parser.control.For

            forCode = strip(forCode);
            tkn = regexp(forCode, For.FOR_PATTERN, 'tokens', 'once');
            if ~isempty(tkn)
                controlName = tkn{1};
                listTokens = tkn{2};
            else
                controlName = '?';
                listTokens = forCode;
            end
            this.ControlName = controlName;
            [listTokens, listValues] = parser.Interp.parse(preparserObj, listTokens, true);
            this.Token = [listValues, regexp(listTokens, '[^\s,;]+', 'match')];
        end%
        
        
        
        
        function c = expandDoCode(this, p, varargin)
            import parser.control.For

            c = '';
            controlName = this.ControlName;
            
            for i = 1 : numel(this.Token)
                p.StoreForCtrl(end+1, :) = { controlName, this.Token{i} };
                c1 = writeFinal(this.DoBody, p, varargin{:});
                c = [c, c1]; %#ok<AGROW>
                p.StoreForCtrl(end, :) = [ ];
            end
        end%
    end
    
    
    
    
    methods (Static)
        function c = substitute(c, p)
            % Substitute for control variable in a code segment (called from within
            % other classes).
            import parser.control.For

            if ~contains(c, "?")
                return
            end
            for i = 1 : size(p.StoreForCtrl, 1)
                ctrlName = p.StoreForCtrl{i, 1};
                tkn = p.StoreForCtrl{i, 2};
                For.checkObsolete(c, ctrlName);
                if length(ctrlName)>1
                    upperCtrlName = ['?:', ctrlName(2:end)];
                    upperToken = upper(tkn);
                    lowerCtrlName = ['?.', ctrlName(2:end)];
                    lowerToken = lower(tkn);
                    % Substitute lower case for for ?.name.
                    c = replace(c, lowerCtrlName, lowerToken);
                    % Substitute upper case for for ?:name.
                    c = replace(c, upperCtrlName, upperToken);
                end
                % Substitute for ?name.
                c = replace(c, ctrlName, tkn);
            end
        end%
        
        
        
        
        function checkObsolete(c, controlName)
            obsoleteFunc = @(syntax) regexp(c, regexptranslate('escape', syntax), 'match');
            listDeprecated = [ obsoleteFunc([ '!lower',  controlName       ]), ...
                               obsoleteFunc([ '!upper',  controlName       ]), ...
                               obsoleteFunc([ '<lower(', controlName, ')>' ]), ...
                               obsoleteFunc([ '<upper(', controlName, ')>' ]), ...
                               obsoleteFunc([ 'lower(',  controlName, ')'  ]), ...
                               obsoleteFunc([ 'upper(',  controlName, ')'  ])  ];
            if isempty(listDeprecated)
                return
            end
            listDeprecated = unique(listDeprecated);
            throwCode( exception.ParseTime('Preparser:CTRL_OBSOLETE_UPPER_LOWER', 'error'), ...
                       listDeprecated{:} );
        end%             
    end
end
