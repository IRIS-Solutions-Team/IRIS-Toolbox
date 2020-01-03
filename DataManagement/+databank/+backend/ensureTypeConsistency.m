function runningDatabank = ensureTypeConsistency(runningDatabank, outputType)
% ensureTypeConsistency  Ensure consistency of input/output databank and option OutputType
%
% Backend IRIS function
% No help provided

% -IRIS Macroeconomic Modeling Toolbox
% -Copyright (c) 2007-2020 IRIS Solutions Team

%--------------------------------------------------------------------------

if isequal(runningDatabank, [ ]) || isequal(runningDatabank, false)
    if strcmpi(outputType, 'containers.Map')
        runningDatabank = containers.Map('KeyType', 'char', 'ValueType', 'any');
    elseif strcmpi(outputType, 'Dictionary')
        runningDatabank = Dictionary( );
    else
        runningDatabank = struct( );
    end
else
    if isa(runningDatabank, outputType)
        return
    end
    THIS_ERROR = { 'Databank:InvalidDatabankFormat'
                   [ 'The type of the databank in option AddToDatabank= ', ...
                     'is not consistent with option OutputType= ' ] };
    throw( exception.Base(THIS_ERROR, 'error') );
end

end%

