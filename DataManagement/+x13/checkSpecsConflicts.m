function checkSpecsConflicts(specs)

specsNames = reshape(string(fieldnames(specs)), 1, [ ]);
prefixes = extractBefore(specsNames, "_");
attributes = extractAfter(specsNames, "_");

if any(lower(prefixes)=="x11") && any(lower(prefixes)=="seats")
    exception.error([
        "X13:SpecsConflict"
        "Cannot include both X11 and SEATS specs in one run of the X13 procedure."
    ]);
end

end%

