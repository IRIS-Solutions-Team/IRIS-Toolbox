function controls = assignControls(this, inputDb)
% assignControls  Create struct with control parameters assigned from input database

% -[IrisToolbox] for Macroeconomic Modeling
% -Copyright (c) 2007-2019 IRIS Solutions Team

%--------------------------------------------------------------------------

controls = struct( );

controlNames = collectControlNames(this);
if isempty(controlNames)
    return
end

listMissing = string.empty(1, 0);
for n = reshape(controlNames, 1, [ ])
    if ~isfield(inputDb, n)
        listMissing = [listMissing, n];
        continue
    end
    controls.(n) = inputDb.(n);
end

if ~isempty(listMissing)
    hereReportMissing( );
end

return

    function hereReportMissing( )
        listMissing = cellstr(listMissing);
        thisError = [ 
            "ExplanatoryEquation:MissingControl"
            "This control parameter is missing from the input databank: %s"
        ];
        throw(exception.Base(thisError, "error"), listMissing{:});
    end%
end%

