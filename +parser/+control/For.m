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
                        '(\s*=)(.*)' ]
    end
    
    
    
    
    methods
        function this = For(c, sh)
            import parser.control.*;
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
        
        
        
        
        function c = writeFinal(this, p, varargin)
            import parser.Preparser;
            c = '';
            if isempty(this.ForBody) || isempty(this.DoBody)
                return
            end
%             forCode = writeFinal(this.ForBody, p, varargin{:});
%             doCode = writeFinal(this.DoBody, p, varargin{:});
%             readForCode(this, forCode, p.Assigned);
%             c = replaceDoCode(this, doCode);
            
            forCode = writeFinal(this.ForBody, p, varargin{:});
            readForCode(this, forCode, p.Assigned);
            c = expandDoCode(this, p, varargin{:});
        end%
        
        
        
        
        function readForCode(this, forCode, assigned)
            import parser.control.For;
            forCode = strtrim(forCode);
            tkn = regexp(forCode, For.FOR_PATTERN, 'tokens', 'once');
            if ~isempty(tkn)
                controlName = tkn{1};
                tokenCode = tkn{3};
            else
                controlName = '?';
                tokenCode = forCode;
            end
            this.ControlName = controlName;
            this.Token = cell(1, 0);
            while true
                [x, from, to] = regexp(tokenCode, '[^\s,;]+', 'match', 'start', 'end', 'once');
                if isempty(x)
                    break
                end
                if strncmp(x, '<', 1)
                    [~, value, tokenCode] = parser.Interp.parse(tokenCode(from:end), assigned, 1);
                    this.Token = [this.Token, value];
                else
                    this.Token{end+1} = x;
                    tokenCode = tokenCode(to+1:end);
                end 
                if isempty(tokenCode)
                    break
                end
            end
        end%
        
        
        
        
        function c = expandDoCode(this, p, varargin)
            import parser.control.For;
            c = '';
            % Remove leading and trailing line breaks.
            % doCode = regexprep(doCode, '^\s*\n', '');
            % doCode = regexprep(doCode, '\n\s*$', '');
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
            import parser.control.For;
            if isempty(strfind(c, '?'))
                return
            end
            for i = 1 : size(p.StoreForCtrl, 1)
                ctrlName = p.StoreForCtrl{i, 1};
                tkn = p.StoreForCtrl{i, 2};
                For.chkObsolete(c, ctrlName);
                if length(ctrlName)>1
                    upperCtrlName = ['?:', ctrlName(2:end)];
                    upperToken = upper(tkn);
                    lowerCtrlName = ['?.', ctrlName(2:end)];
                    lowerToken = lower(tkn);
                    % Substitute lower case for for ?.name.
                    c = strrep(c, lowerCtrlName, lowerToken);
                    % Substitute upper case for for ?:name.
                    c = strrep(c, upperCtrlName, upperToken);
                end
                % Substitute for ?name.
                c = strrep(c, ctrlName, tkn);
            end
        end%
        
        
        
        
        function chkObsolete(c, controlName)
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
