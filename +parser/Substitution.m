classdef Substitution < handle
    properties
        Block = cell.empty(1, 0) % Substitution definition blocks
        Name = cell.empty(1, 0) % Substitution names
        Body = cell.empty(1, 0) % Substitution bodies
        Code = cell.empty(1, 0) % Code with substition blocks removed
    end


    properties (Constant)
        SUBSTITUTION_PATTERN = '!substitutions(-preprocessor|-postprocessor)?(.*?)(?=![a-zA-Z]|$)'
        NAME_BODY_PATTERN = '(\<[a-zA-Z]\w*\>)\s*:?\s*=\s*([^;]*)\s*;'
    end


    methods
        function this = Substitution(c)
            if nargin==0
                return
            end
            this.Code = c;
            readBlock(this);
            readNameBody(this);
            checkUnique(this);
        end%


        function readBlock(this)
            block = cell.empty(1, 0);
            % Read the blocks one by one to preserve their order in the
            % model code; remove the substitution blocks from the code
            c = this.Code;
            while true
                [tok, start, finish] = regexp( ...
                    c, this.SUBSTITUTION_PATTERN, ...
                    'tokens', 'start', 'end', 'once' ...
                );
                if isempty(start)
                    break
                end
                block{1, end+1} = strip(tok{2}); %#ok<AGROW>
                processor = erase(string(tok{1}), "-");
                if processor=="preprocessor" || processor=="postprocessor"
                    temp = replace(c(start:finish), "!substitutions-"+processor, "!"+processor);
                    c = [c(1:start-1), char(temp), c(finish+1:end)];
                else
                    c(start:finish) = '';
                end
            end
            this.Code = c;
            this.Block = block;
        end%


        function readNameBody(this)
            % Read substitution names and bodies; do block by block to preserve their
            % order.
            name = cell.empty(1, 0);
            body = cell.empty(1, 0);
            leftover = cell.empty(1, 0);
            for i = 1 : length(this.Block)
                b = this.Block{i};
                while true
                    [tkn, from, to] = regexp( ...
                        b, this.NAME_BODY_PATTERN, ...
                        'tokens', 'start', 'end', 'once' ...
                    );
                    if isempty(from)
                        break
                    end
                    name{1, end+1} = tkn{1}; %#ok<AGROW>
                    body{1, end+1} = tkn{2}; %#ok<AGROW>
                    b(from:to) = '';
                end
                b = strtrim(b);
                if ~isempty(b)
                    leftover{1, end+1} = b; %#ok<AGROW>
                end
            end
            if ~isempty(leftover)
                throwCode( exception.ParseTime('Preparser:SUBS_LEFTOVER', 'error'), ...
                           leftover{:} );
            end
            this.Name = name;
            this.Body = body;
        end% 




        function checkUnique(this)
            [~, pos] = unique(this.Name);
            numNames = length(this.Name);
            if length(pos)~=numNames
                pos = unique(setdiff(1:numNames, pos));
                throw( exception.ParseTime('Preparser:SUBS_NAME_MULTIPLE', 'error'), ...
                       this.Name{pos} );
            end
        end%




        function c = writeFinal(this)
            c = this.Code;
            % Expand substitutions in other substitutions first
            numNames = length(this.Name);
            ptn = cell(1, numNames);
            for i = 1 : numNames
                ptn{i} = ['$', this.Name{i}, '$'];
                for j = i+1 : numNames
                    this.Body{j} = strrep(this.Body{j}, ptn{i}, this.Body{i});
                end
            end
            % Expand substitutions in the rest of the code. Proceed backward so
            % that unresolved substitutions in substitution bodies (pointing to
            % substitutions defined later) remain unresolved and can be caught as
            % an error.
            for i = numNames : -1 : 1
                c  = strrep(c, ptn{i}, this.Body{i});
            end
            this.Code = c;
            checkUndefined(this);
        end%


        function checkUndefined(this)
            c = this.Code;
            undefined = regexp(c, '\$\<[A-Za-z]\w*\>\$', 'match');
            if ~isempty(undefined)
                throw( exception.ParseTime('Preparser:SUBS_UNDEFINED', 'error'), ...
                       undefined{:} );
            end
        end%
    end


    methods (Static)
        function parse(p)
            c = p.Code;
            s = parser.Substitution(c); % Construct substitution object
            c = writeFinal(s); % Write final code
            p.Code = c;
            p.StoreSubstitutions = cell2struct(s.Body, cellstr(s.Name), 2);
        end%
    end
end

