function [outputDatabank, appliedToNames, newNames] = apply(func, inputDatabank, varargin)

persistent inputParser
if isempty(inputParser)
    inputParser = extend.InputParser('databank.apply');
    inputParser.addRequired('Function', @(x) isempty(x) || isa(x, 'function_handle'));
    inputParser.addRequired('InputDatabank', @isstruct);
    inputParser.addParameter('HasPrefix', '',  @(x) ischar(x) || (isa(x, 'string') && isscalar(x)));
    inputParser.addParameter('HasSuffix', '',  @(x) ischar(x) || (isa(x, 'string') && isscalar(x)));
    inputParser.addParameter('AddPrefix', '',  @(x) ischar(x) || (isa(x, 'string') && isscalar(x)));
    inputParser.addParameter('AddSuffix', '',  @(x) ischar(x) || (isa(x, 'string') && isscalar(x)));
    inputParser.addParameter('RemovePrefix', false, @(x) isequal(x, true) || isequal(x, false));
    inputParser.addParameter('RemoveSuffix', false, @(x) isequal(x, true) || isequal(x, false));
    inputParser.addParameter('List', @all, @(x) isequal(x, @all) || ischar(x) || iscellstr(x) || isa(x, 'string'));
    inputParser.addParameter('AddToDatabank', @auto, @(x) isequal(x, @auto) || isstruct(x));
end
inputParser.parse(func, inputDatabank, varargin{:});
opt = inputParser.Options;

if ~isequal(opt.List, @all)
    opt.List = cellstr(opt.List);
end

opt.HasPrefix = char(opt.HasPrefix);
opt.HasSuffix = char(opt.HasSuffix);
opt.AddPrefix = char(opt.AddPrefix);
opt.AddSuffix = char(opt.AddSuffix);

%--------------------------------------------------------------------------

namesOfFields = fieldnames(inputDatabank);
numOfFields = numel(namesOfFields);
newNames = repmat({''}, size(namesOfFields));

lenOfHasPrefix = length(opt.HasPrefix);
lenOfHasSuffix = length(opt.HasSuffix);

outputDatabank = opt.AddToDatabank;
if isequal(outputDatabank, @auto)
    outputDatabank = inputDatabank;
end

inxOfApplied = false(size(namesOfFields));
for i = 1 : numOfFields
    ithName = namesOfFields{i};
    if ~isequal(opt.List, @all) && ~any(strcmpi(ithName, opt.List))
       continue
    end 
    if ~isempty(opt.HasPrefix) && ~strncmpi(ithName, opt.HasPrefix, lenOfHasPrefix)
        continue
    end
    if ~isempty(opt.HasSuffix) && ~strncmpi(fliplr(ithName), fliplr(opt.HasSuffix), lenOfHasSuffix)
        continue
    end
    inxOfApplied(i) = true;
    ithNewName = ithName;
    if opt.RemovePrefix
        ithNewName(1:lenOfHasPrefix) = '';
    end
    if opt.RemoveSuffix
        ithNewName(end-lenOfHasSuffix+1:end) = '';
    end
    if ~isempty(opt.AddPrefix)
        ithNewName = [opt.AddPrefix, ithNewName];
    end
    if ~isempty(opt.AddSuffix)
        ithNewName = [ithNewName, opt.AddSuffix];
    end
    newNames{i} = ithNewName;
    inputSeries = inputDatabank.(ithName);
    if isempty(func)
        outputDatabank.(ithNewName) = inputSeries;
    else
        outputDatabank.(ithNewName) = func(inputSeries);
    end
end

appliedToNames = namesOfFields(inxOfApplied);
newNames = newNames(inxOfApplied);

end%

