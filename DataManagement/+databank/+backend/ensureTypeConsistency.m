function runningDb = ensureTypeConsistency(runningDb, outputType)

if isequal(runningDb, []) || isequal(runningDb, false)
    if all(strcmpi(outputType, 'Dictionary'))
        runningDb = Dictionary( );
    else
        runningDb = struct( );
    end
else
    if isequal(outputType, @auto) || all(strcmpi(outputType, '__auto__')) || isa(runningDb, outputType)
        return
    end
    exception.error([
        "Databank:InvalidDatabankFormat"
        "The databank type in option AddToDatabank= "
        "is not consistent with the option OutputType= "
    ]);
end

end%

