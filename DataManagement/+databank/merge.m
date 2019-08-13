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
% __`method`__ [ `'horzcat'` | `'replace'` | `'discard'` | `'error'` ] -
% Action to perform when two or more of the input databanks contain a field
% of the same name; see Description.
%
% __`d`__ [ struct | Dictionary | containers.Map ] -
% Databank that will be merged with the other input databanks, `d1`, etc.
% using the method specified by `Method=`.
%
% __`d1`__ [ struct | Dictionary | containers.Map ] -
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
% ## Example ##
%
%}

% -IRIS Macroeconomic Modeling Toolbox
% -Copyright (c) 2007-2019 IRIS Solutions Team

if isempty(varargin)
    return
end

inxOfStructs = cellfun('isclass', varargin, 'struct');
if ~inxOfStructs(1)
    return
end

if all(inxOfStructs)
    mergeWith = varargin;
    varargin(:) = [ ];
else
    posFirstNonStruct = find(~inxOfStructs, 1);
    posLastStruct = posFirstNonStruct - 1;
    mergeWith = varargin(1:posLastStruct);
    varargin(1:posLastStruct) = [ ];
end

persistent parser
if isempty(parser)
    parser = extend.InputParser('databank.merge');
    parser.addRequired('Method', @(x) Valid.anyString(x, 'horzcat', 'replace', 'discard', 'error'));
    parser.addRequired('InputDatabank', @validate.databank);
    parser.addRequired('MergeWith');
    parser.addParameter('MissingField', @rmfield);
end
parse(parser, method, mainDatabank, mergeWith, varargin{:});
opt = parser.Options;

%--------------------------------------------------------------------------

numOfMergeWith = numel(mergeWith);

if strcmpi(method, 'horzcat')
    mergeNext = @horzcatNext;
elseif strcmpi(method, 'replace')
    mergeNext = @replaceNext;
elseif strcmpi(method, 'discard')
    mergeNext = @discardNext;
else
    mergeNext = @errorNext;
end

for i = 1 : numOfMergeWith
    mainDatabank = mergeNext(mainDatabank, mergeWith{i}, opt);
end

end%


function mainDatabank = horzcatNext(mainDatabank, mergeWith, opt)
    fieldsMainDatabank = fieldnames(mainDatabank);
    fieldsMergeWith = fieldnames(mergeWith);
    fieldsMerged = [fieldsMainDatabank; fieldsMergeWith];
    fieldsMerged = unique(fieldsMerged, 'stable');
    numFieldsMerged = numel(fieldsMerged);
    for i = 1 : numFieldsMerged
        ithName = fieldsMerged{i};
        if isequal(opt.MissingField, @rmfield) 
            if ~isfield(mergeWith, ithName)
                mainDatabank = rmfield(mainDatabank, ithName);
                continue
            elseif ~isfield(mainDatabank, ithName);
                continue
            end
        end
        if isfield(mainDatabank, ithName)
            mainDatabankField = mainDatabank.(ithName);
        else
            mainDatabankField = opt.MissingField;
        end
        if isfield(mergeWith, ithName)
            mergeWithField = mergeWith.(ithName);
        else
            mergeWithField = opt.MissingField;
        end
        mainDatabank.(ithName) = horzcat(mainDatabankField, mergeWithField);
    end
end%




function mainDatabank = replaceNext(mainDatabank, mergeWith, ~)
    newFields = fieldnames(mergeWith);
    numOfNewFields = numel(newFields);
    for i = 1 : numOfNewFields
        name = newFields{i};
        mainDatabank.(name) = mergeWith.(name);
    end
end%




function mainDatabank = discardNext(mainDatabank, mergeWith, ~)
    newFields = fieldnames(mergeWith);
    numOfNewFields = numel(newFields);
    for i = 1 : numOfNewFields
        name = newFields{i};
        if isfield(mainDatabank, name)
            continue
        end
        mainDatabank.(name) = mergeWith.(name);
    end
end%




function mainDatabank = errorNext(mainDatabank, mergeWith, ~)
    newFields = fieldnames(mergeWith);
    numOfNewFields = numel(newFields);
    inxOfErrorFields = false(1, numOfNewFields);
    for i = 1 : numOfNewFields
        name = newFields{i};
        if isfield(mainDatabank, name)
            inxOfErrorFields(i) = true;
            continue
        end
        mainDatabank.(name) = mergeWith.(name);
    end
    if any(inxOfErrorFields)
        THIS_ERROR = { 'Databank:ErrorMergingFieldsWithSameName'
                       'This field name occurs in more than one input databank: %s ' };
        throw( exception.Base(THIS_ERROR, 'error'), ...
               newFields{inxOfErrorFields} );
    end
end%

