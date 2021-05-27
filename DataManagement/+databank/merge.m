% Type `web +databank/merge.md` for help on this function
%
% -[IrisToolbox] Macroeconomic Modeling Toolbox
% -Copyright (c) 2007-2021 [IrisToolbox] Solutions Team

% >=R2019b
%{
function mainDb = merge(method, mainDb, mergeWith, opt)

arguments
    method (1, 1) string { mustBeMember(method, ["horzcat", "vertcat", "replace", "discard", "error"]) }
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

persistent pp
if isempty(pp)
    pp = extend.InputParser('databank.merge');
    pp.addRequired("method", @(x) validate.anyString(string(x), ["horzcat", "vertcat", "replace", "discard", "error"]));
    pp.addRequired("mainDb", @validate.databank);
    pp.addRequired('MergeWith');
    pp.addParameter('MissingField', @remove);
    pp.addParameter({'Names', 'List'}, @all, @(x) isequal(x, @all) || validate.list(x));
end
parse(pp, method, mainDb, mergeWith, varargin{:});
opt = pp.Options;
%)
% <=R2019a

numMergeWith = numel(mergeWith);
method = char(method);

if strcmpi(method, 'horzcat')
    mergeNext = @(varargin) concatenateNext(@horzcat, varargin{:});
elseif strcmpi(method, 'vertcat')
    mergeNext = @(varargin) concatenateNext(@vertcat, varargin{:});
elseif strcmpi(method, 'replace')
    mergeNext = @replaceNext;
elseif strcmpi(method, 'discard')
    mergeNext = @discardNext;
else
    mergeNext = @errorNext;
end

for i = 1 : numMergeWith
    mainDb = mergeNext(mainDb, mergeWith{i}, opt);
end

end%

%
% Local Functions
%

function mainDb = concatenateNext(func, mainDb, mergeWith, opt)
    %(
    if isequal(opt.Names, @all)
        fieldsMainDatabank = fieldnames(mainDb);
        fieldsMergeWith = fieldnames(mergeWith);
        fieldsToMerge = [fieldsMainDatabank; fieldsMergeWith];
    else
        fieldsToMerge = reshape(cellstr(opt.Names), 1, [ ]);
    end
    fieldsToMerge = unique(fieldsToMerge, "stable");
    numFieldsToMerge = numel(fieldsToMerge);
    fieldsToRemove = string.empty(1, 0);
    for i = 1 : numFieldsToMerge
        name__ = fieldsToMerge{i};
        if isequal(opt.MissingField, @remove) || isequal(opt.MissingField, @rmfield)
            if ~isfield(mergeWith, name__)
                fieldsToRemove(end+1) = string(name__);
                % mainDb = rmfield(mainDb, name__);
                continue
            elseif ~isfield(mainDb, name__)
                continue
            end
        end
        if isfield(mainDb, name__)
            mainDatabankField = mainDb.(name__);
        else
            mainDatabankField = opt.MissingField;
        end
        if isfield(mergeWith, name__)
            mergeWithField = mergeWith.(name__);
        else
            mergeWithField = opt.MissingField;
        end
        mainDatabankField = func(mainDatabankField, mergeWithField);
        mainDb.(name__) = mainDatabankField;
    end
    if ~isempty(fieldsToRemove);
        mainDb = rmfield(mainDb, fieldsToRemove);
    end
    %)
end%


function mainDb = replaceNext(mainDb, mergeWith, opt)
    %(
    if isequal(opt.Names, @all)
        newFields = fieldnames(mergeWith);
    else
        newFields = reshape(cellstr(opt.Names), 1, [ ]);
    end
    numNewFields = numel(newFields);
    for i = 1 : numNewFields
        name__ = newFields{i};
        if ~isfield(mergeWith, name__)
            continue
        end
        if isfield(mergeWith, name__)
            mainDb.(name__) = mergeWith.(name__);
        end
    end
    %)
end%


function mainDb = discardNext(mainDb, mergeWith, opt)
    %(
    if isequal(opt.Names, @all)
        newFields = fieldnames(mergeWith);
    else
        newFields = reshape(cellstr(opt.Names), 1, [ ]);
    end
    numNewFields = numel(newFields);
    for i = 1 : numNewFields
        name__ = newFields{i};
        if ~isfield(mergeWith, name__)
            continue
        end
        if ~isfield(mainDb, name__)
            mainDb.(name__) = mergeWith.(name__);
        end
    end
    %)
end%


function mainDb = errorNext(mainDb, mergeWith, opt)
    %(
    if isequal(opt.Names, @all)
        newFields = fieldnames(mergeWith);
    else
        newFields = reshape(cellstr(opt.Names), 1, [ ]);
    end
    numNewFields = numel(newFields);
    inxErrorFields = false(1, numNewFields);
    for i = 1 : numNewFields
        name__ = newFields{i};
        if ~isfield(mergeWith, name__)
            continue
        end
        if isfield(mainDb, name__)
            inxErrorFields(i) = true;
            continue
        end
        mainDb.(name__) = mergeWith.(name__);
    end
    if any(inxErrorFields)
        thisError = [
            "Databank:ErrorMergingFieldsWithSameName"
            "This field name occurs in more than one input databank: %s "
        ];
        throw(exception.Base(thisError, 'error'), newFields{inxErrorFields});
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

