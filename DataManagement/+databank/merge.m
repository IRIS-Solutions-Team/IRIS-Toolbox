function mainDatabank = merge(method, mainDatabank, varargin)
% merge  Merge two or more databanks
%{
% ## Syntax ##
%
%     d = databank.merge(method, d, d1, ...)
%
%
% ## Input Arguments ##
%
% __`method`__ [ `'horzcat'` | `'vertcat'` | `'replace'` | `'discard'` | `'error'` ] -
% Action to perform when two or more of the input databanks contain a field
% of the same ithName; see Description.
%
% __`d`__ [ struct | Dictionary | containers.Map ] -
% Databank that will be merged with the other input databanks, `d1`, etc.
% using the method specified by `Method=`.
%
% __`d1`__ [ struct | Dictionary ] -
% One or more databanks which will be merged with the input databank `d`.
%
%
% ## Output Arguments ##
%
% __`d`__ [ struct | Dictionary | containers.Map ] -
% Output databank created by merging the input databanks using the method
% specified by `Method=`.
%
%
% ## Options ##
%
% __`MissingField=@rmfield`__ [ `@rmfield` | `NaN` | `[ ]` | * ] -
% Action to perform when a field is missing from one or more of the input
% databanks when applying the method `'horzcat'`.
%
%
% ## Description ##
%
% The fields from each of the additional databnaks (`d1` and further) are
% added to the main databank `d`. If the ithName of a field to be added
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
% ## Example ##
%
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

persistent parser
if isempty(parser)
    parser = extend.InputParser('databank.merge');
    parser.addRequired('Method', @(x) validate.anyString(char(x), 'horzcat', 'vertcat', 'replace', 'discard', 'error'));
    parser.addRequired('InputDatabank', @validate.databank);
    parser.addRequired('MergeWith');
    parser.addParameter('MissingField', @remove);
    parser.addParameter({'Names', 'List'}, @all, @(x) isequal(x, @all) || validate.list(x));
end
parse(parser, method, mainDatabank, mergeWith, varargin{:});
opt = parser.Options;

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
        ithName = fieldsToMerge{i};
        if isequal(opt.MissingField, @remove) || isequal(opt.MissingField, @rmfield)
            if ~isfield(mergeWith, ithName)
                mainDatabank = rmfield(mainDatabank, ithName);
                continue
            elseif ~isfield(mainDatabank, ithName)
                continue
            end
        end
        if isfield(mainDatabank, ithName)
            mainDatabankField = getfield(mainDatabank, ithName);
        else
            mainDatabankField = opt.MissingField;
        end
        if isfield(mergeWith, ithName)
            mergeWithField = getfield(mergeWith, ithName);
        else
            mergeWithField = opt.MissingField;
        end
        mainDatabankField = func(mainDatabankField, mergeWithField);
        mainDatabank = setfield(mainDatabank, ithName, mainDatabankField);
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
        ithName = newFields{i};
        if ~isfield(mergeWith, ithName)
            continue
        end
        if isfield(mergeWith, ithName)
            mainDatabank.(ithName) = mergeWith.(ithName);
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
        ithName = newFields{i};
        if ~isfield(mergeWith, ithName)
            continue
        end
        if ~isfield(mainDatabank, ithName)
            mainDatabank.(ithName) = mergeWith.(ithName);
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
        ithName = newFields{i};
        if ~isfield(mergeWith, ithName)
            continue
        end
        if isfield(mainDatabank, ithName)
            inxErrorFields(i) = true;
            continue
        end
        mainDatabank.(ithName) = mergeWith.(ithName);
    end
    if any(inxErrorFields)
        THIS_ERROR = { 'Databank:ErrorMergingFieldsWithSameName'
                       'This field ithName occurs in more than one input databank: %s ' };
        throw( exception.Base(THIS_ERROR, 'error'), ...
               newFields{inxErrorFields} );
    end
end%

