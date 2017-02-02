classdef Log < parser.theparser.Generic
    properties
        TypeCanBeLog
    end
    
    
    
    
    methods
        function [quantity, equation] = parse(this, ~, code, quantity, equation, euc, puc, ~)
            nQuan = length(quantity.Name);
            if isempty(strfind(code, '!all_but'))
                default = false;
            else
                default = true;
                code = strrep(code, '!all_but', '');
            end
            
            lsLog = regexp(code, '\<[a-zA-Z]\w*\>', 'match');
            ell = lookup(quantity, lsLog, this.TypeCanBeLog{:});
            
            ixValid = ~isnan(ell.PosName);
            if any(~ixValid)
                throw( exception.ParseTime('TheParser:INVALID_LOG_NAME_DECLARED', 'error'), ...
                    lsLog{~ixValid} );
            end
            
            ixCanBeLog = ell.IxKeep;
            quantity.IxLog = ixCanBeLog & repmat(default, 1, nQuan);
            quantity.IxLog(ell.IxName) = ~default;
            
        end
        
        
        
        
        function precheck(~, ~, blocks)
            % The keyword `!all_but` must be in all or none of flag blocks.
            ixPresent = cellfun( @isempty, regexp(blocks, '!all_but', 'match', 'once') );
            if any(ixPresent) && ~all(ixPresent)
                throw( exception.ParseTime('TheParser:INCONSISTENT_ALL_BUT', 'error') );
            end
        end
    end
end