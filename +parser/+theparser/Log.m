classdef Log < parser.theparser.Generic
    properties
        TypeCanBeLog
    end


    properties (Constant)
        ALLBUT_KEYWORD = '!all-but'
    end
    
    
    methods
        function [quantity, equation] = parse(this, ~, code, quantity, equation, euc, puc, ~)
            numQuantities = length(quantity.Name);
            if isempty(strfind(code, parser.theparser.Log.ALLBUT_KEYWORD))
                default = false;
            else
                default = true;
                code = strrep(code, parser.theparser.Log.ALLBUT_KEYWORD, '');
            end
            
            listLog = regexp(code, '\<[a-zA-Z]\w*\>', 'match');
            ell = lookup(quantity, listLog, this.TypeCanBeLog{:});
            
            inxValid = ~isnan(ell.PosName);
            if any(~inxValid)
                THIS_ERROR = { 'TheParser:InvalidLogNameDeclared'
                               'This name cannot be declared as log-variable: %s ' };
                throw( exception.ParseTime(THIS_ERROR, 'error'), ...
                       listLog{~inxValid} );
            end
            
            inxCanBeLog = ell.IxKeep;
            quantity.IxLog = inxCanBeLog & repmat(default, 1, numQuantities);
            quantity.IxLog(ell.IxName) = not(default);
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

