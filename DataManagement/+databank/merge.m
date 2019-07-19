function mainDatabank = merge(method, mainDatabank, varargin)
% merge  Merge two or more databanks
%{
% ## Syntax ##
%
%     d = databank.merge(d, d1, ...)
%
%
% ## Input Arguments ##
%
% **`Method`** [ `'horzcat'` | `'replace'` | `'discard'` ] -
% Method applied when two or more of the input databanks contain a field of
% the same name; see Description.
%
% **`d`** [ struct ] -
% Databank that will be merged with the other input databanks, `d1`, etc.
% using the method specified by `Method=`.
%
% **`d1`** [ struct ] -
% One or more databanks which will be merged with the input databank `d`.
%
%
% ## Output Arguments ##
%
% **`d`** [ struct ] -
% Output databank created by merging the input databanks using the method
% specified by `Method=`.
%
%
% ## Options ##
%
% **`MissingField=@rmfield`** [ `@rmfield` | `NaN` | `[ ]` | * ] -
% What to do when a field is missing from one or more of the input
% databanks when applying the method `'horzcat'`.
%
%
% ## Description ##
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
    parser.addRequired('Method', @(x) any(strcmpi(x, {'horzcat', 'replace', 'discard'})));
    parser.addRequired('InputDatabank', @isstruct);
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
else
    mergeNext = @discardNext;
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

