classdef Pairing < parser.theparser.Equation
    properties
    end


    properties (Constant)
        PATTERN = '^\s*(?<Lhs>\w+)\s*(:=|=|~)\s*(?<Rhs>\w+)\s*;'
    end


    methods
        function [qty, eqn, euc] = parse(this, ~, code, ~, qty, eqn, euc, puc, ~)
            code = char(code);
            eqtn = this.splitCodeIntoEquations(code);
            if isempty(eqtn)
                return
            end
            eqtn = strrep(eqtn, ' ', '');
            tkn = regexp(eqtn, this.PATTERN, 'names');
            ixValid = cellfun(@(x) numel(x)==1, tkn);
            if any(~ixValid)
                throw( exception.ParseTime('TheParser:INVALID_PAIRING_DEFINITION', 'error'), eqtn{~ixValid} );
            end
            tkn = [ tkn{:} ];
            nAdd = numel(tkn);
            puc.Type = [puc.Type, repmat(this.Type, 1, nAdd)];
            puc.Lhs = [puc.Lhs, {tkn.Lhs}];
            puc.Rhs = [puc.Rhs, {tkn.Rhs}];
        end%
    end
end
