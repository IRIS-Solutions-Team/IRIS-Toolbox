classdef Log ...
    < parser.theparser.Generic

    properties (Constant)
        ALLBUT_KEYWORD = '!all-but'
    end
    
    
    methods
        function  log = parse(this, code)
            except = false;
            if contains(code, parser.theparser.Log.ALLBUT_KEYWORD)
                except = true;
                code = erase(code, parser.theparser.Log.ALLBUT_KEYWORD);
            end
            log = regexp(code, '\<[a-zA-Z]\w*\>', 'match');
            if except
                log = Except(log);
            end
        end%

        
        function precheck(~, ~, blocks)
            inxPresent = cellfun( @isempty, regexp(blocks, parser.theparser.Log.ALLBUT_KEYWORD, 'match', 'once') );
            if any(inxPresent) && ~all(inxPresent)
                THIS_ERROR = { 'TheParser:InconsistentAllBut'
                               'Keyword !all-but must be used consistently in either all or none of the !log-variables declaration blocks '};
                throw( exception.ParseTime(THIS_ERROR, 'error') );
            end
        end%
    end
end

