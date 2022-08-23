% validateNames  Must be unique, no reserved names, no reserved prefixes
%
% -[IrisToolbox] for Macroeconomic Modeling
% -Copyright (c) 2007-2022 [IrisToolbox] Solutions Team

function validateNames(this)

stringify = @(x) reshape(string(x), 1, []);
allNames = stringify(this.Name);

if isempty(allNames)
    return
end

here_checkReservedNames();
here_checkDoubleUnderscores();
here_checkNonuniqueNames();
here_checkReservedPrefixes();

return

    function here_checkValidMatlabNames()
        %(
        % All model names must be valid Matlab names
        inxValid = arrayfun(@isvarname, allNames);
        if any(~inxValid)
            exception.error([
                "Parser:InvalidName"
                "This name is not a valid Matlab name: %s"
            ], allNames(~inxValid));
        end
        %)
    end%


    function here_checkReservedNames()
        %(
        if nnz(string(allNames)==string(this.RESERVED_NAME_TTREND))>1
            exception.error([
                "Parser"
                "This is a reserved keyword and cannot be used as a quantity name: %s "
            ], string(this.RESERVED_NAME_TTREND));
        end
        %)
    end%


    function here_checkDoubleUnderscores()
        % Shock names must not contain double scores because of the way
        % cross-correlations are referenced
        %(
        inxE = this.Type==31 | this.Type==32;
        if ~any(inxE)
            return
        end
        shockNames = allNames(inxE);
        inxValid = ~contains(shockNames, "__");
        if any(~inxValid)
            exception.error([
                "Parser:ShocNameWithDoubleUnderscore"
                "Names of shocks are not allowed to contain double underscores: %s "
            ], shockNames(~inxValid));
        end
        %)
    end%


    function here_checkNonuniqueNames()
        %(
        [flag, nonuniques] = textual.nonunique(allNames);
        if flag
            exception.error([
                "Parser:NonuniqueNames"
                "This name is declared more than once: %s "
            ], nonuniques);
        end
        %)
    end%


    function here_checkReservedPrefixes()
        %(
        inxReservedPrefix = startsWith(allNames, model.Quantity.RESERVED_PREFIXES);
        if any(inxReservedPrefix)
            exception.error([
                "Parser:ReservedPrefix"
                "This name starts with a reserved prefix: %s"
            ], allNames(inxReservedPrefix));
        end
        %)
    end%
end%

