% validateNames  Must be unique, no reserved names, no reserved prefixes
%
% -[IrisToolbox] for Macroeconomic Modeling
% -Copyright (c) 2007-2021 [IrisToolbox] Solutions Team

function validateNames(this)

stringify = @(x) reshape(string(x), 1, []);
allNames = stringify(this.Name);

if isempty(allNames)
    return
end

% hereCheckValidMatlabNames();
hereCheckReservedNames();
here_validateTrendName();
hereCheckDoubleUnderscores();
hereCheckNonuniqueNames();
hereCheckReservedPrefixes();

return

    function hereCheckValidMatlabNames()
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


    function hereCheckReservedNames()
        % All model names must be different from reserved names
        %(
        reservedNames = [
            string(this.RESERVED_NAME_TTREND)
            string(this.RESERVED_NAME_LINEAR)
        ];
        allNamesExReserved = allNames(1:end-1);
        for n = reshape(reservedNames, 1, [])
            if any(allNamesExReserved==n)
                exception.error([
                    "Parser:ReservedName"
                    "This is an IrisT keyword and cannot be used as a model name: %s "
                ], n);
            end
        end
    end%


    function here_validateTrendName()
        if allNames(end)~=string(this.RESERVED_NAME_TTREND)
            exception.error([
                "Parser:ReservedName"
                "The " + this.RESERVED_NAME_TTREND + " keyword is not allowed to be renamed."
            ]);
        end
        %)
    end%


    function hereCheckDoubleUnderscores()
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


    function hereCheckNonuniqueNames()
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


    function hereCheckReservedPrefixes()
        %(
        inxReservedPrefix = startsWith(allNames, model.component.Quantity.RESERVED_PREFIXES);
        if any(inxReservedPrefix)
            exception.error([
                "Parser:ReservedPrefix"
                "This name starts with a reserved prefix: %s"
            ], allNames(inxReservedPrefix));
        end
        %)
    end%
end%

