classdef CodeSegments < handle
    properties
        Body % Collection of code segments found at the same level.
    end
    
    
    
    
    methods
        function this = CodeSegments(c, wh, sh)
            import parser.control.*;
            if nargin==0
                return
            end
            try, sh; catch, sh = CodeSegments.createShadowCode(wh); end %#ok<VUNUS,NOCOM>
            [c, sh] = CodeSegments.handleStop(c, sh); % Remove everything after first !stop.
            body = { };
            while true
                posNextKey = find(real(sh)>0, 1);
                if isempty(posNextKey)
                    body{end+1} = c; %#ok<AGROW>
                    break
                end
                body{end+1} = c(1:posNextKey-1); %#ok<AGROW>
                c = c(posNextKey:end);
                sh = sh(posNextKey:end);
                if imag(sh(1))==0
                    [body, c, sh] = CodeSegments.handleInline(body, c, sh);
                else
                    [body, c, sh] = CodeSegments.handleBlock(body, c, sh);
                end
                if isempty(c)
                    break
                end
            end
            this.Body = body;
        end
        
        
        
        
        function c = writeFinal(this,p,varargin)
            import parser.control.For;
            c = '';
            n = numel(this.Body);
            for i = 1 : n
                g = this.Body{i};
                if ischar(g)
                    g = For.substitute(g, p);
                    c = [ c, g ]; %#ok<AGROW>
                else
                    c = [ c, writeFinal(g, p, varargin{:}) ]; %#ok<AGROW>
                end
            end
        end
        
        
        
        
        function flag = isempty(this)
            flag = isempty(this.Body) || ...
                ( ...
                iscellstr(this.Body) ...
                && all(cellfun(@isempty,this.Body)) ...
                );
        end
    end
    
    
    
    
    methods (Static)
        function sh = createShadowCode(wh)
            keywordEnum = enumeration('parser.control.Keyword');
            sh = zeros(1, length(wh), 'int8');
            for i = 1 : numel(keywordEnum)
                x = keywordEnum(i);
                ix = strfind(wh, toChar(x));
                if ~isempty(ix)
                    sh(ix) = int8(x);
                    wh(ix) = char(0);
                end
            end
        end
        
        
        
        
        function [c, sh] = handleStop(c, sh)
            pos = find(real(sh)==parser.control.Keyword.STOP, 1);
            if ~isempty(pos)
                c = c(1:pos-1);
                sh = sh(1:pos-1);
            end            
        end
        
        
        
        
        function [body, c, sh] = handleInline(body, c, sh)
            import parser.control.*;
            key = Keyword(sh(1));
            switch key
                case { Keyword.IMPORT, Keyword.INCLUDE, Keyword.INPUT }
                    [arg, c, sh] = Import.getBracketArg(key, c, sh);
                    body{end+1} = Import(arg);
                case { Keyword.CLONE }
                    [arg, c, sh] = Clone.getBracketArg(key, c, sh);
                    body{end+1} = Clone(arg);
                otherwise
                    throw( exception.Base('General:Internal', 'error') );
            end
        end
        
        
        
        
        function [body, c, sh] = handleBlock(body, c, sh)
            import parser.control.*;
            keyOpen = Keyword(sh(1));
            level = cumsum(imag(sh));
            close = find(level==0, 1);
            if isempty(close)
                throwCode( exception.ParseTime('Preparser:CTRL_MISSING_END', 'error'), c );
            end
            c1 = c(1:close-1);
            sh1 = sh(1:close-1);
            switch keyOpen
                case Keyword.EXPORT
                    body{end+1} = Export(c1, sh1);
                case Keyword.FUNCTION
                    body{end+1} = Function(c1, sh1);
                case Keyword.FOR
                    body{end+1} = For(c1, sh1);
                case Keyword.IF
                    body{end+1} = If(c1, sh1);
                case Keyword.SWITCH
                    body{end+1} = Switch(c1, sh1);
                otherwise
                    throw( exception.Base('General:Internal', 'error') );                    
            end
            keyClose = Keyword(sh(close));
            c = c(close+len(keyClose):end);
            sh = sh(close+len(keyClose):end);
        end  
    end
end
