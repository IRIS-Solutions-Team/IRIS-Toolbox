%{
% 
% # `databank.merge` ^^(+databank)^^
% 
% {== Merge two or more databanks ==}
% 
% 
% ## Syntax
% 
%     outputDb = databank.merge(method, primaryDb [, otherDb ], ___)
% 
% 
% ## Shortcut syntax for `databank.merge("horzcat", ___)`
% 
%     outputDb = databank.horzcat(primaryDb, [, otherDb], ___)
% 
% 
% ## Input arguments
% 
% 
% __`method`__ [ `"horzcat"` | `"vertcat"` | `"replace"` | `"warning"` | `"discard"` | `"error"` ] 
% > 
% > Action to perform when two or more of the input mergeWith contain a
% > field of the same name; see Description.
% > 
% 
% 
% __`primaryDb`__ [ struct | Dictionary ] 
% > 
% > Primary input databank that will be merged with the other input
% > mergeWith, `d1`, etc.  using the `method`.
% > 
% 
% 
% __`otherDb`__ [ struct | Dictionary ] 
% > 
% > One or more mergeWith which will be merged with the primaryinput databank
% > `primaryDb` to create the `outputDb`.
% > 
% 
% 
% ## Output arguments
% 
% 
% __`outputDb`__ [ struct | Dictionary ] 
% > 
% > Output databank created by merging the input mergeWith using the
% > method specified by the `method`.
% > 
% 
% 
% ## Options
% 
% __`MissingField=@rmfield`__ [ `@rmfield` | `NaN` | `[ ]` | * ] 
% > 
% > Action to take when a field is missing from one or more of the
% > input mergeWith when the `method` is `"horzcat"`.
% > 
% 
% 
% __`WhenFailed="warning"`__ [ `"warning"` | `"silent"` | `"error"` ]
% >
% > Action to take when the `method` fails to merge a field across some of
% > the input databanks. `WhenFailed="warning"` or `WhenFailed="silent"`
% > results in the failed fields being excluded from the `outputDb`.
% >
% 
% 
% ## Description
% 
% The fields from each of the additional mergeWith (`d1` and further) are
% added to the main databank `d`. If the name of a field to be added
% already exists in the main databank, `d`, one of the following actions is
% performed:
% 
% * `"horzcat"` - horizontally concatenate the fields;
% 
% * `"replace"` - silently replace the field in the main databank with the
%   new field;
% 
% * `"warning"` - replace the field in the main databank with the
%   new field, and throw a warning;
% 
% * `"discard"` - keep the field in the main databank unchanged, and discard
%   the new field;
% 
% * `"error"` - throw an error whenever the main databank and the other
%   databank contain a field of the same name.
% 
% 
% ## Example
% 
% 
%}
% --8<--


% >=R2019b
%{
function [mainDb, info] = merge(method, mainDb, mergeWith, opt)

arguments
    method (1, 1) string { mustBeMember(method, ["horzcat", "vertcat", "replace", "warning", "discard", "error", "meta"]) }
    mainDb (1, 1) { validate.databank(mainDb) }
end

arguments (Repeating)
    mergeWith (1, 1) { local_validateMergeWith }
end

arguments
    opt.MissingField = @remove
    opt.Names { local_validateNames(opt.Names) } = @all
    opt.MetaNames = []
    opt.WhenFailed (1, 1) string = "warning"
end
%}
% >=R2019b


% <=R2019a
%(
function mainDb = merge(method, mainDb, varargin)

if isempty(varargin)
    return
end

inxDatabanks = cellfun(@validate.databank, varargin);
if ~inxDatabanks(1)
    return
end

if all(inxDatabanks)
    mergeWith = varargin;
    varargin(:) = [ ];
else
    posFirstNonStruct = find(~inxDatabanks, 1);
    posLastStruct = posFirstNonStruct - 1;
    mergeWith = varargin(1:posLastStruct);
    varargin(1:posLastStruct) = [ ];
end

persistent ip
if isempty(ip)
    ip = inputParser(); 
    addParameter(ip, "MissingField", @remove);
    addParameter(ip, "Names", @all);
    addParameter(ip, "MetaNames", []);
    addParameter(ip, "WhenFailed", "warning");
end
parse(ip, varargin{:});
opt = ip.Results;
%)
% <=R2019a


numMergeWith = numel(mergeWith);

switch string(method)
    case "meta"
        mainDb = local_createMetaFields(mainDb, 1, opt.MetaNames);
        for i = 1 : numMergeWith
            mergeWith{i} = local_createMetaFields(mergeWith{i}, 1+i, opt.MetaNames);
        end
        mergeNext = @(varargin) concatenateNext(@horzcat, varargin{:});
        opt.MissingField = [];
    case "horzcat"
        mergeNext = @(varargin) concatenateNext(@horzcat, varargin{:});
    case "vertcat"
        mergeNext = @(varargin) concatenateNext(@vertcat, varargin{:});
    case "replace"
        mergeNext = @(varargin) replaceNext(false, varargin{:});
    case "warning"
        mergeNext = @(varargin) replaceNext(true, varargin{:});
    case "discard"
        mergeNext = @discardNext;
    otherwise
        mergeNext = @errorNext;
end

if isequal(opt.Names, @all)
    fieldsToMerge = fieldnames(mainDb);
    for i = 1 : numMergeWith
        fieldsToMerge = [fieldsToMerge; fieldnames(mergeWith{i})];
    end
    fieldsToMerge = unique(fieldsToMerge, 'stable');
else
    fieldsToMerge = reshape(cellstr(opt.Names), [], 1);
end

fieldsFailed = string.empty(1, 0);
for i = 1 : numMergeWith
    [mainDb, fieldsToMerge, fieldsFailed__] = mergeNext(mainDb, mergeWith{i}, fieldsToMerge, opt);
    fieldsFailed = [fieldsFailed, fieldsFailed__];
end

if ~isempty(fieldsFailed) && opt.WhenFailed~="silent"
    exception.(char(opt.WhenFailed))([
        "Databank"
        "This field failed to merge across input databanks: %s"
    ], fieldsFailed);
end

info = struct();
if nargout>=2 && string(method)=="meta"
    for n = databank.fieldNames(mainDb)
        if numel(mainDb.(n))>1
            info.(n) = mainDb.(n);
        end
    end
end

end%


function [mainDb, fieldsToMerge, fieldsFailed] = concatenateNext(func, mainDb, mergeWith, fieldsToMerge, opt)
    %(
    fieldsToRemove = string.empty(1, 0);
    fieldsFailed = string.empty(1, 0);
    for n = reshape(string(fieldsToMerge), 1, [])
        if isequal(opt.MissingField, @remove) || isequal(opt.MissingField, @rmfield)
            if ~isfield(mergeWith, n)
                fieldsToRemove(end+1) = string(n);
                continue
            elseif ~isfield(mainDb, n)
                continue
            end
        end
        if isfield(mainDb, n)
            mainDatabankField = mainDb.(n);
        else
            mainDatabankField = opt.MissingField;
        end
        if isfield(mergeWith, n)
            mergeWithField = mergeWith.(n);
        else
            mergeWithField = opt.MissingField;
        end
        try
            mainDatabankField = func(mainDatabankField, mergeWithField);
            mainDb.(n) = mainDatabankField;
        catch
            fieldsToRemove(end+1) = n;
            fieldsFailed(end+1) = n;
        end
    end
    if ~isempty(fieldsToRemove)
        for n = textual.stringify(fieldsToRemove)
            if isfield(mainDb, n)
                mainDb = rmfield(mainDb, n);
            end
        end
        fieldsToMerge = setdiff(fieldsToMerge, fieldsToRemove);
    end
    %)
end%


function [mainDb, fieldsToMerge, fieldsFailed] = replaceNext(needsWarn, mainDb, mergeWith, fieldsToMerge, opt)
    %(
    fieldsFailed = string.empty(1, 0);
    overwrites = string.empty(1, 0);
    for n = reshape(string(fieldsToMerge), 1, [])
        if ~isfield(mergeWith, n)
            continue
        end
        if isfield(mergeWith, n)
            if needsWarn && isfield(mainDb, n)
                overwrites(end+1) = n;
            end
            mainDb.(n) = mergeWith.(n);
        end
    end
    if ~isempty(overwrites)
        exception.warning([
            "Databank"
            "This field name occurs in more than one input databank: %s "
        ], overwrites);
    end
    %)
end%


function [mainDb, fieldsToMerge, fieldsFailed] = discardNext(mainDb, mergeWith, fieldsToMerge, opt)
    %(
    fieldsFailed = string.empty(1, 0);
    for n = reshape(string(fieldsToMerge), 1, [])
        if ~isfield(mergeWith, n)
            continue
        end
        if ~isfield(mainDb, n)
            mainDb.(n) = mergeWith.(n);
        end
    end
    %)
end%


function [mainDb, fieldsToMerge, fieldsFailed] = errorNext(mainDb, mergeWith, fieldsToMerge, opt)
    %(
    fieldsFailed = string.empty(1, 0);
    errorFields = string.empty(1, 0);
    for n = reshape(string(fieldsToMerge), 1, [])
        if ~isfield(mergeWith, n)
            continue
        end
        if isfield(mainDb, n)
            errorFields(end+1) = n;
            continue
        end
        mainDb.(n) = mergeWith.(n);
    end
    if ~isempty(errorFields)
        exception.error([
            "Databank:ErrorMergingFieldsWithSameName"
            "This field name occurs in more than one input databank: %s "
        ], errorFields);
    end
    %)
end%


function local_validateNames(input)
    if isequal(input, @all) || validate.list(input)
        return
    end
    error("Input value must be @all or a string array");
end%


function local_validateMergeWith(input)
    %(
    if validate.databank(input)
        return
    end
    error("Input value must be a struct or a Dictionary.");
    %)
end%


function db = local_createMetaFields(db, i, metaNames)
    %(
    if isempty(metaNames)
        value = i;
    else
        value = metaNames(i);
    end
    for n = databank.fieldNames(db)
        db.(n) = value;
    end
    %)
end%

