classdef Substitution < handle
    properties
        Block % Substitution definition blocks.
        Name % List of substitution names.
        Body % Liest of substitution bodie.
        Code % Code with substition blocks removed.
    end
    
    
    
    properties (Constant)
        SUBSTITUTION_PATTERN = [ ...
            parser.substitution.Keyword.SUBSTITUTION, ...
            '(.*?)(?=![a-zA-Z]|$)', ...
            ];
        NAME_BODY_PATTERN = '(\<[a-zA-Z]\w*\>)\s*:?\s*=\s*([^;]*)\s*;';
    end
    
    
    
    
    methods
        function this = Substitution(c)
            if nargin==0
                return
            end
            this.Code = c;
            readBlock(this);
            readNameBody(this);
            chkUnique(this);
        end
        
        
        
        
        function readBlock(this)
            import parser.substitution.Substitution;
            block = { };
            % Read the blocks one by one to preserve their order in the
            % model code. Remove the substitution blocks from the code.
            c = this.Code;
            while true
                [tok,start,finish] = regexp( ...
                    c, ...
                    Substitution.SUBSTITUTION_PATTERN, ...
                    'tokens','start','end','once' ...
                    );
                if isempty(start)
                    break
                end
                block{end+1} = strtrim(tok{1}); %#ok<AGROW>
                c(start:finish) = '';
            end
            this.Code = c;
            this.Block = block;
        end
        
        
        
        
        function readNameBody(this)
            % Read substitution names and bodies; do block by block to preserve their
            % order.
            name = { };
            body = { };
            leftover = { };
            for i = 1 : length(this.Block)
                b = this.Block{i};
                while true
                    [tkn, from, to] = ...
                        regexp(b, this.NAME_BODY_PATTERN, ...
                        'tokens', 'start', 'end', 'once');
                    if isempty(from)
                        break
                    end
                    name{end+1} = tkn{1}; %#ok<AGROW>
                    body{end+1} = tkn{2}; %#ok<AGROW>
                    b(from:to) = '';
                end
                b = strtrim(b);
                if ~isempty(b)
                    leftover{end+1} = b; %#ok<AGROW>
                end
            end
            if ~isempty(leftover)
                throwCode( ...
                    exception.ParseTime('Preparser:SUBS_LEFTOVER', 'error'), ...
                    leftover{:} );
            end
            this.Name = name;
            this.Body = body;
        end
        
        
        
        
        function chkUnique(this)
            [~,pos] = unique(this.Name);
            nName = length(this.Name);
            if length(pos)~=nName
                pos = unique(setdiff(1:nName,pos));
                throw( ...
                    exception.ParseTime('Preparser:SUBS_NAME_MULTIPLE', 'error'), ...
                    this.Name{pos} );
            end
        end
        
        
        
        
        function c = writeFinal(this)
            c = this.Code;
            % Expand substitutions in other substitutions first.
            nName = length(this.Name);
            ptn = cell(1,nName);
            for i = 1 : nName
                ptn{i} = ['$',this.Name{i},'$'];
                for j = i+1 : nName
                    this.Body{j} = strrep(this.Body{j},ptn{i},this.Body{i});
                end
            end
            % Expand substitutions in the rest of the code. Proceed backward so
            % that unresolved substitutions in substitution bodies (pointing to
            % substitutions defined later) remain unresolved and can be caught as
            % an error.
            for i = nName : -1 : 1
                c  = strrep(c,ptn{i},this.Body{i});
            end
            this.Code = c;
            chkUndefined(this);
        end
        
        
        
        
        function chkUndefined(this)
            c = this.Code;
            undefined = regexp(c,'\$\<[A-Za-z]\w*\>\$','match');
            if ~isempty(undefined)
                throw( ...
                    exception.ParseTime('Preparser:SUBS_UNDEFINED', 'error'), ...
                    undefined{:} );
            end
        end
    end
    
    
    
    methods (Static)
        function parse(p)
            import parser.substitution.*;
            c = p.Code;
            s = Substitution(c); % Construct substitution object.
            c = writeFinal(s); % Write final code.
            p.Code = c;
        end
    end
end