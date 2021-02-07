% Type `type +databank/retrieveColumns.md` or `web +databank/retrieveColumns.md`
% for help on this function
%
% -[IrisToolbox] for Macroeconomic Modeling
% -Copyright (c) 2007-2020 [IrisToolbox] Solutions Team

function db = retrieveColumns(db, refs, opt)

arguments
    db {validate.mustBeDatabank}
    refs (1, :) 
    opt.WhenFails (1, 1) string {mustBeMember(opt.WhenFails, ["error", "remove", "keep"])} = "remove";
end

if ~iscell(refs)
    refs = {refs};
end

fieldsFailed = string.empty(1, 0);
for n = databank.fieldNames(db)
    try
        if isa(db.(n), "Series")
            db.(n) = db.(n){:, refs{:}};
        else
            db.(n) = db.(n)(:, refs{:});
        end
    catch
        fieldsFailed(end+1) = n;
    end
end

if ~isempty(fieldsFailed)
    if lower(opt.WhenFails)=="remove"
        db = rmfield(db, fieldsFailed);
    elseif lower(opt.WhenFails)=="error"
        exception.error([
            "Databank:FailedWhenRetrievingColumns"
            "Error retrieving columns from this field: %s"
        ], fieldsFailed);
    else
        % Do nothing
    end
end

end%

