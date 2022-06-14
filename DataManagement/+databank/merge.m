% Type `web +databank/merge.md` for help on this function
%
% -[IrisToolbox] Macroeconomic Modeling Toolbox
% -Copyright (c) 2007-2022 [IrisToolbox] Solutions Team

% >=R2019b
%{
function mainDb = merge(method, mainDb, mergeWith, opt)

arguments
    method (1, 1) string { mustBeMember(method, ["horzcat", "vertcat", "replace", "warning", "discard", "error"]) }
    mainDb (1, 1) { validate.databank(mainDb) }
end

arguments (Repeating)
    mergeWith (1, 1) { locallyValidateMergeWith }
end

arguments
    opt.MissingField = @remove
    opt.Names { locallyValidateNames(opt.Names) } = @all
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
end
parse(ip, varargin{:});
opt = ip.Results;
%)
% <=R2019a


numMergeWith = numel(mergeWith);

switch string(method)
    case "horzcat"
        mergeNext = @(varargin) concatenateNext(@horzcat, varargin{:});
    case "vertcat"
        mergeNext = @(varargin) concatenateNext(@vertcat, varargin{:});
    case "replace"
        mergeNext = @(varargin) replaceNext(false, varargin{:});
    case "warning"
        mergeNext = @(varargin) replaceNext(true, varargin{:});
    case "discar"
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

for i = 1 : numMergeWith
    [mainDb, fieldsToMerge] = mergeNext(mainDb, mergeWith{i}, fieldsToMerge, opt);
end

end%

%
% Local Functions
%

function [mainDb, fieldsToMerge] = concatenateNext(func, mainDb, mergeWith, fieldsToMerge, opt)
    %(
    fieldsToRemove = string.empty(1, 0);
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
        mainDatabankField = func(mainDatabankField, mergeWithField);
        mainDb.(n) = mainDatabankField;
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


function [mainDb, fieldsToMerge] = replaceNext(needsWarn, mainDb, mergeWith, fieldsToMerge, opt)
    %(
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


function [mainDb, fieldsToMerge] = discardNext(mainDb, mergeWith, fieldsToMerge, opt)
    %(
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


function [mainDb, fieldsToMerge] = errorNext(mainDb, mergeWith, fieldsToMerge, opt)
    %(
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


function locallyValidateNames(input)
    if isequal(input, @all) || validate.list(input)
        return
    end
    error("Input value must be @all or a string array");
end%


function locallyValidateMergeWith(input)
    %(
    if validate.databank(input)
        return
    end
    error("Input value must be a struct or a Dictionary.");
    %)
end%

