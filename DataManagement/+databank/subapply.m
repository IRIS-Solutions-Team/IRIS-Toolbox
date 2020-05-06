function db = subapply(func, db, whenMissing, varargin)
% databank.subapply  Apply function to a crosslist of nested fields
%{
% Syntax
%--------------------------------------------------------------------------
%
% 
%     db = databank.subapply(func, db, whenMissing, level1, level2, ..., levelK)
%
%
% Input Arguments
%--------------------------------------------------------------------------
%
%
% __`func`__ [ function_handle ]
%
%     Function that is applied to the crosslist of fields of the input
%     databank, `db`.
%
%
% __`db`__ [ struct | Dictionary ]
%
%     Input databank, possibly nested; the function `func` is applied to
%     the crosslist of fields of `db`, and the resulting databank is
%     returned.
%
%
% __`whenMissing`__ [ any | `@error` ]
%
%     Value used to create a field if it is missing from `db`, before the
%     function `func` is applied to it; if `whenMissing=@error`, an error
%     message is thrown.
%
%
% __`levelK`__ [ string ]
%
%     List of fields at nested level K from which the crosslist will be
%     compiled; the crosslist consists of all the combinations of the
%     fields at` the respective nesting levels given by the lists
%     `level1`, ..., `levelK`, where K is the maximum nesting depth.
%
%
% Output Arguments
%--------------------------------------------------------------------------
%
%
% __`db`__ [ struct | Dictionary ]
%
%     Output databank created from the input databank by applying the
%     function `func` to the crosslist of fields given by the lists
%     `level1`, ..., `levelK`
%
%
% Description
%--------------------------------------------------------------------------
%
%
% Example
%--------------------------------------------------------------------------
%
%}

% -[IrisToolbox] for Macroeconomic Modeling
% -Copyright (c) 2007-2020 [IrisToolbox] Solutions Team

if nargin==2
    return
elseif nargin==3
    crosslist = reshape(string(varargin{1}), 1, [ ]);
else
    crosslist = textual.xlist(".", varargin{:});
end

%--------------------------------------------------------------------------

deliverSub = nargin(func)>=2;

reportMissing = string.empty(1, 0);
for composite = crosslist
    components = split(composite, ".");
    inputs = cell(1, 2*numel(components));
    inputs(1:2:end) = {'.'};
    inputs(2:2:end) = cellstr(components);
    ref = substruct(inputs{:});
    extras = cell.empty(1, 0);
    if deliverSub
        if numel(inputs)>2
            extras = { subsref(db, substruct(inputs{1:end-2})) };
        else
            extras = { db };
        end
    end
    try
        field = subsref(db, ref);
    catch
        if isequal(whenMissing, @error)
            reportMissing = [reportMissing, composite];
            continue
        else
            field = whenMissing;
        end
    end
    db = subsasgn(db, ref, func(field, extras{:}));
end

if ~isempty(reportMissing)
    hereReportMissingFields( );
end

return

    function hereReportMissingFields( )
        %(
        thisError = [
            "Databank:InvalidFieldReference"
            "This composite field reference does not exist in the databank: %s"
        ];
        throw(exception.Base(thisError, 'error'), reportMissing);
        %)
    end%
end%


