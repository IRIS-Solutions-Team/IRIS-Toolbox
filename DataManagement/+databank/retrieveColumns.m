%{
% 
% # `databank.retrieveColumns` ^^(+databank)^^
% 
% {== Retrieve selected columns from databank fields ==}
% 
% 
% ## Syntax
% 
%     outputDb = function(inputDb, refs,...)
% 
% 
% ## Input Arguments
% 
% __`inputDb`__ [ struct | Dictionary ]
% > 
% > Input databank from whose fields the selected columns given by the `ref`
% > will be extracted and included in the `outputDb`.
% > 
% 
% __`refs`__ [ numeric | cell ]
% > 
% > References to columns that will be retrieved from the fields of the
% > `inputDb`; the references can be either numeric (refering to 2nd
% > dimension) or a cell array (referring to multiple dimensions starting
% > from 2nd).
% > 
% 
% ## Output Arguments
% 
% __`outputDb`__ [ struct | Dictionary ]
% > 
% > Output databank with the fields from the `inputDb` reduced to the
% > selected columns `refs`; what happens when the columns cannot be
% > retrieved from a field is determined by the option `WhenFails`.
% > 
% 
% ## Options
% 
% __`WhenFails="remove"`__ [ "error" | "keep" | "remove" ]
% > 
% > This option determines what happens when an attempt to reference and
% > retrieve the selected columns from a field fails (when Matlab throws an
% > error):
% > 
% > * `"error"` - an error will be thrown listing the failed fields;
% > 
% > * `"keep"` - the field will be kept in the `outputDb` unchanged;
% > 
% > * `"remove"` - the field will be removed from the `outputDb`.
% > 
% 
% ## Description
% 
% 
% ## Example
% 
% 
% 
%}
% --8<--


% >=R2019b
%(
function db = retrieveColumns(db, refs, opt)

arguments
    db {validate.mustBeDatabank}
    refs (1, :) 

    opt.WhenFails (1, 1) string {mustBeMember(opt.WhenFails, ["error", "remove", "keep"])} = "remove";
end
%)
% >=R2019b


% <=R2019a
%{
function db = retrieveColumns(db, refs, varargin)

persistent pp
if isempty(pp)
    pp = extend.InputParser();
    addParameter(pp, "WhenFails", "remove");
end
parse(pp, varargin{:});
opt = pp.Results;
%}
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

