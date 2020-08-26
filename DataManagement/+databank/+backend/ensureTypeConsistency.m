function runningDb = ensureTypeConsistency(runningDb, outputType)
% databank.backend.ensureTypeConsistency  Ensure consistency
% of input/output databank and option OutputType
%
% Backend [IrisToolbox] method
% No help provided

% -[IrisToolbox] for Macroeconomic Modeling
% -Copyright (c) 2007-2020 [IrisToolbox] Solutions Team

%--------------------------------------------------------------------------

if isequal(runningDb, [ ]) || isequal(runningDb, false)
    if strcmpi(outputType, 'containers.Map')
        runningDb = containers.Map('KeyType', 'char', 'ValueType', 'any');
    elseif strcmpi(outputType, 'Dictionary')
        runningDb = Dictionary( );
    else
        runningDb = struct( );
    end
else
    if isequal(outputType, @auto) || isa(runningDb, outputType)
        return
    end
    exception.error([
        "Databank:InvalidDatabankFormat"
        "The databank type in option AddToDatabank= "
        "is not consistent with the option OutputType= "
    ]);
end

end%

