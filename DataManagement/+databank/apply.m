function [outputDatabank, appliedToNames, newNames] = apply(func, inputDatabank, varargin)

persistent parser
if isempty(parser)
    parser = extend.InputParser('databank.apply');
    parser.addRequired('Function', @(x) isempty(x) || isa(x, 'function_handle'));
    parser.addRequired('InputDatabank', @validate.databank);
    parser.addParameter({'HasPrefix', 'StartsWith'}, '',  @(x) ischar(x) || (isa(x, 'string') && isscalar(x)));
    parser.addParameter({'HasSuffix', 'EndsWith'}, '',  @(x) ischar(x) || (isa(x, 'string') && isscalar(x)));
    parser.addParameter({'AddPrefix', 'AddStart'}, '',  @(x) ischar(x) || (isa(x, 'string') && isscalar(x)));
    parser.addParameter({'AddSuffix', 'AddEnd'}, '',  @(x) ischar(x) || (isa(x, 'string') && isscalar(x)));
    parser.addParameter({'RemovePrefix', 'RemoveStart'}, false, @(x) isequal(x, true) || isequal(x, false));
    parser.addParameter({'RemoveSuffix', 'RemoveEnd'}, false, @(x) isequal(x, true) || isequal(x, false));
    parser.addParameter({'List', 'Names', 'Fields'}, @all, @(x) isequal(x, @all) || ischar(x) || iscellstr(x) || isa(x, 'string'));
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

if isa(inputDatabank, 'Dictionary')
    namesFields = cellstr(keys(inputDatabank));
elseif isstruct(inputDatabank)
    namesFields = fieldnames(inputDatabank);
end

numFields = numel(namesFields);
newNames = repmat({''}, size(namesFields));

lenHasPrefix = length(opt.HasPrefix);
lenHasSuffix = length(opt.HasSuffix);

outputDatabank = opt.AddToDatabank;
if isequal(outputDatabank, @auto)
    outputDatabank = inputDatabank;
end

inxApplied = false(size(namesFields));
for i = 1 : numFields
    ithName = namesFields{i};
    if ~isequal(opt.List, @all) && ~any(strcmpi(ithName, opt.List))
       continue
    end 
    if ~isempty(opt.HasPrefix) && ~strncmpi(ithName, opt.HasPrefix, lenHasPrefix)
        continue
    end
    if ~isempty(opt.HasSuffix) && ~strncmpi(fliplr(ithName), fliplr(opt.HasSuffix), lenHasSuffix)
        continue
    end
    inxApplied(i) = true;
    ithNewName = ithName;
    if opt.RemovePrefix
        ithNewName(1:lenHasPrefix) = '';
    end
    if opt.RemoveSuffix
        ithNewName(end-lenHasSuffix+1:end) = '';
    end
    if ~isempty(opt.AddPrefix)
        ithNewName = [opt.AddPrefix, ithNewName];
    end
    if ~isempty(opt.AddSuffix)
        ithNewName = [ithNewName, opt.AddSuffix];
    end
    newNames{i} = ithNewName;

    ithSeries = getfield(inputDatabank, ithName);
    if ~isempty(func)
        ithSeries = func(ithSeries);
    end
    outputDatabank = setfield(outputDatabank, ithNewName, ithSeries);
end

appliedToNames = namesFields(inxApplied);
newNames = newNames(inxApplied);

end%

