function mainDatabank = merge(method, mainDatabank, varargin)
%{
% databank.merge  Merge two or more databanks
%
% Syntax
%--------------------------------------------------------------------------
%
%
%     outputDb = databank.merge(method, primaryDb, otherDb, ...)
%
%
% Input Arguments
%--------------------------------------------------------------------------
%
% __`method`__ [ `'horzcat'` | `'vertcat'` | `'replace'` | `'discard'` | `'error'` ] 
%
%     Action to perform when two or more of the input databanks contain a
%     field of the same name; see Description.
%
%
% __`primaryDb`__ [ struct | Dictionary ] 
%
%     Primary input databank that will be merged with the other input
%     databanks, `d1`, etc.  using the `method`.
%
%
% __`otherDb`__ [ struct | Dictionary ] 
%
%     One or more databanks which will be merged with the primaryinput databank
%     `primaryDb` to create the `outputDb`.
%
%
% Output Arguments
%--------------------------------------------------------------------------
%
%
% __`outputDb`__ [ struct | Dictionary ] 
%
%     Output databank created by merging the input databanks using the
%     method specified by the `method`.
%
%
% Options
%--------------------------------------------------------------------------
%
%
% __`MissingField=@rmfield`__ [ `@rmfield` | `NaN` | `[ ]` | * ] 
%
%     Action to perform when a field is missing from one or more of the
%     input databanks when the `method` is `'horzcat'`.
%
%
% Description
%--------------------------------------------------------------------------
%
%
% The fields from each of the additional databanks (`d1` and further) are
% added to the main databank `d`. If the name of a field to be added
% already exists in the main databank, `d`, one of the following actions is
% performed:
%
% * `horzcat` - the fields will be horizontally concatenated;
%
% * `replace` - the field in the main databank will be replaced with the
% new field;
% 
% * `discard` - the field in the main databank will be kept unchanged, and
% the new field will be discarded;
% 
% * `error` - an error will be thrown.
%
%
% Example
%--------------------------------------------------------------------------
%
%
%--------------------------------------------------------------------------
% See also databank.copy
%}

% -IRIS Macroeconomic Modeling Toolbox
% -Copyright (c) 2007-2020 IRIS Solutions Team

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
    pp.addRequired('Method', @(x) validate.anyString(char(x), 'horzcat', 'vertcat', 'replace', 'discard', 'error'));
    pp.addRequired('InputDatabank', @validate.databank);
    pp.addRequired('MergeWith');
    pp.addParameter('MissingField', @remove);
    pp.addParameter({'Names', 'List'}, @all, @(x) isequal(x, @all) || validate.list(x));
end
parse(pp, method, mainDatabank, mergeWith, varargin{:});
opt = pp.Options;

%--------------------------------------------------------------------------

numMergeWith = numel(mergeWith);
method = char(method);

if strcmpi(method, 'horzcat')
    mergeNext = @(varargin) catNext(@horzcat, varargin{:});
elseif strcmpi(method, 'vertcat')
    mergeNext = @(varargin) catNext(@vertcat, varargin{:});
elseif strcmpi(method, 'replace')
    mergeNext = @replaceNext;
elseif strcmpi(method, 'discard')
    mergeNext = @discardNext;
else
    mergeNext = @errorNext;
end

for i = 1 : numMergeWith
    mainDatabank = mergeNext(mainDatabank, mergeWith{i}, opt);
end

end%


%
% Local Functions
%


function mainDatabank = catNext(func, mainDatabank, mergeWith, opt)
    if isequal(opt.Names, @all)
        fieldsMainDatabank = fieldnames(mainDatabank);
        fieldsMergeWith = fieldnames(mergeWith);
        fieldsToMerge = [fieldsMainDatabank; fieldsMergeWith];
    else
        fieldsToMerge = reshape(cellstr(opt.Names), 1, [ ]);
    end
    fieldsToMerge = unique(fieldsToMerge, 'stable');
    numFieldsToMerge = numel(fieldsToMerge);
    for i = 1 : numFieldsToMerge
        name__ = fieldsToMerge{i};
        if isequal(opt.MissingField, @remove) || isequal(opt.MissingField, @rmfield)
            if ~isfield(mergeWith, name__)
                mainDatabank = rmfield(mainDatabank, name__);
                continue
            elseif ~isfield(mainDatabank, name__)
                continue
            end
        end
        if isfield(mainDatabank, name__)
            mainDatabankField = mainDatabank.(name__);
        else
            mainDatabankField = opt.MissingField;
        end
        if isfield(mergeWith, name__)
            mergeWithField = mergeWith.(name__);
        else
            mergeWithField = opt.MissingField;
        end
        mainDatabankField = func(mainDatabankField, mergeWithField);
        mainDatabank.(name__) = mainDatabankField;
    end
end%




function mainDatabank = replaceNext(mainDatabank, mergeWith, opt)
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
            mainDatabank.(name__) = mergeWith.(name__);
        end
    end
end%




function mainDatabank = discardNext(mainDatabank, mergeWith, opt)
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
        if ~isfield(mainDatabank, name__)
            mainDatabank.(name__) = mergeWith.(name__);
        end
    end
end%




function mainDatabank = errorNext(mainDatabank, mergeWith, opt)
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
        if isfield(mainDatabank, name__)
            inxErrorFields(i) = true;
            continue
        end
        mainDatabank.(name__) = mergeWith.(name__);
    end
    if any(inxErrorFields)
        thisError = [
            "Databank:ErrorMergingFieldsWithSameName"
            "This field name occurs in more than one input databank: %s "
        ];
        throw(exception.Base(thisError, 'error'), newFields{inxErrorFields});
    end
end%

