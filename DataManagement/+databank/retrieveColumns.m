% >=R2019b
%{
function db = retrieveColumns(db, refs, opt)

arguments
    db {validate.mustBeDatabank}
    refs (1, :) 

    opt.WhenFails (1, 1) string {mustBeMember(opt.WhenFails, ["error", "remove", "keep"])} = "remove";
end
%}
% >=R2019b


% <=R2019a
%(
function db = retrieveColumns(db, refs, varargin)

persistent pp
if isempty(pp)
    pp = extend.InputParser();
    addParameter(pp, "WhenFails", "remove");
end
parse(pp, varargin{:});
opt = pp.Results;
%)
% <=R2019a


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

