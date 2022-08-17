function db = subapply(func, db, whenMissing, varargin)

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


