function [outputDatabank, appliedToNames, newNames] = apply(func, inputDatabank, varargin)

persistent parser
if isempty(parser)
    parser = extend.InputParser('databank.apply');
    parser.addRequired('Function', @(x) isempty(x) || isa(x, 'function_handle'));
    parser.addRequired('InputDatabank', @isstruct);
    parser.addParameter({'HasPrefix', 'StartsWith'}, '',  @(x) ischar(x) || (isa(x, 'string') && isscalar(x)));
    parser.addParameter({'HasSuffix', 'EndsWith'}, '',  @(x) ischar(x) || (isa(x, 'string') && isscalar(x)));
    parser.addParameter({'AddPrefix', 'AddStart'}, '',  @(x) ischar(x) || (isa(x, 'string') && isscalar(x)));
    parser.addParameter({'AddSuffix', 'AddEnd'}, '',  @(x) ischar(x) || (isa(x, 'string') && isscalar(x)));
    parser.addParameter({'RemovePrefix', 'RemoveStart'}, false, @(x) isequal(x, true) || isequal(x, false));
    parser.addParameter({'RemoveSuffix', 'RemoveEnd'}, false, @(x) isequal(x, true) || isequal(x, false));
    parser.addParameter('List', @all, @(x) isequal(x, @all) || ischar(x) || iscellstr(x) || isa(x, 'string'));
    parser.addParameter('AddToDatabank', @auto, @(x) isequal(x, @auto) || isstruct(x));
end
parser.parse(func, inputDatabank, varargin{:});
opt = parser.Options;

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

