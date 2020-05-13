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
    if isa(runningDb, outputType)
        return
    end
    thisError = [
        "Databank:InvalidDatabankFormat"
        "The databank type in option AddToDatabank= "
        "is not consistent with the option OutputType= "
    ];
    throw(exception.Base(thisError, 'error'));
end

end%

