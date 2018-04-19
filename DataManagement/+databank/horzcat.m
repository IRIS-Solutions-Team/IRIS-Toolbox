function mainDatabank = horzcat(mainDatabank, varargin)

if isempty(varargin)
    return
end

indexStruct = cellfun('isclass', varargin, 'struct');
if ~indexStruct(1)
    return
end

if all(indexStruct)
    mergeWith = varargin;
    varargin(:) = [ ];
else
    posFirstNonStruct = find(~indexStruct, 1);
    posLastStruct = posFirstNonStruct - 1;
    mergeWith = varargin(1:posLastStruct);
    varargin(1:posLastStruct) = [ ];
end

persistent inputParser
if isempty(inputParser)
    inputParser = extend.InputParser('databank.horzcat');
    inputParser.addRequired('InputDatabank', @isstruct);
    inputParser.addRequired('MergeWith');
    inputParser.addParameter('MissingField', @rmfield);
end
inputParser.parse(mainDatabank, mergeWith, varargin{:});
opt = inputParser.Options;

%-------------------------------------------------------------------

numMergeWith = numel(mergeWith);

for i = 1 : numMergeWith
    mainDatabank = mergeWithOneDatabank(mainDatabank, mergeWith{i}, opt.MissingField);
end

end%


function mainDatabank = mergeWithOneDatabank(mainDatabank, mergeWith, missingField)
    fieldsMainDatabank = fieldnames(mainDatabank);
    fieldsMergeWith = fieldnames(mergeWith);
    fieldsMerged = [fieldsMainDatabank; fieldsMergeWith];
    fieldsMerged = unique(fieldsMerged, 'stable');
    numFieldsMerged = numel(fieldsMerged);
    for i = 1 : numFieldsMerged
        ithName = fieldsMerged{i};
        if isequal(missingField, @rmfield) 
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
            mainDatabankField = missingField;
        end
        if isfield(mergeWith, ithName)
            mergeWithField = mergeWith.(ithName);
        else
            mergeWithField = missingField;
        end
        mainDatabank.(ithName) = horzcat(mainDatabankField, mergeWithField);
    end
end%

