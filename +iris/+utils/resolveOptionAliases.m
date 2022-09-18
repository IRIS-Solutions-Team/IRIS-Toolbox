function opt = resolveOptionAliases(opt, notAssigned, issueWarning)

allNames = reshape(string(fieldnames(opt)), 1, []);
inx = contains(allNames, "__");

if ~any(inx)
    return
end

for n = allNames(inx)
    if isequal(opt.(n), notAssigned)
        continue
    end
    primaryName = extractAfter(n, "__");
    aliasName = extractBefore(n, "__");
    if ~isfield(opt, primaryName)
        exception.error([
            "Internal"
            "Something went wrong inside IrisT: Cannot map option '%s' to '%s'. "
        ], aliasName, primaryName);
    end
    opt.(primaryName) = opt.(n);
    if isequal(issueWarning, true) ...
        || (isstring(issueWarning) && ismember(aliasName, issueWarning)) ...
        || (isa(issueWarning, 'Except') && ~ismember(aliasName, issueWarning.List))
        exception.warning([
            "Deprecated"
            "Option '%s' is obsolete and will be removed in the future. "
            "Use '%s' instead. "
        ], aliasName, primaryName)
    end
end

opt = rmfield(opt, allNames(inx));

end%
