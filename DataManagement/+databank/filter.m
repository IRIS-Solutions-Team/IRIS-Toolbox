function [select, tokens] = filter(d, varargin)

persistent inputParser
if isempty(inputParser)
    inputParser = extend.InputParser('databank.filter');
    inputParser.addRequired('Database', @isstruct);
    inputParser.addParameter('Name', "--all", @(x) ischar(x) || iscellstr(x) || isa(x, 'string'));
    inputParser.addParameter('Class', "--all", @(x) ischar(x) || iscellstr(x) || isa(x, 'string'));
    inputParser.addParameter('Filter', [ ], @(x) isempty(x) || isa(x, 'function_handle'));
end
inputParser.parse(d, varargin{:});
opt = inputParser.Results;

%--------------------------------------------------------------------------

listOfFields = fieldnames(d);
listOfClasses = cellfun(@class, struct2cell(d), 'UniformOutput', false);
tokens = repmat({[]}, size(listOfFields));

if isequal(opt.Name, "--all")
    ixName = true(size(listOfFields));
else
    if ~isa(opt.Name, 'string')
        opt.Name = string(opt.Name);
    end
    if isscalar(opt.Name) && startsWith(opt.Name, "--rexp:")
        opt.Name = erase(opt.Name, "--rexp:");
        [start, tokens] = regexp(listOfFields, opt.Name, 'start', 'tokens', 'once');
        ixName = ~cellfun(@isempty, start);
    else
        opt.Name = opt.Name(:).';
        ixName = any(opt.Name==listOfFields, 2);
    end
end

if isequal(opt.Class, "--all")
    ixClass = true(size(listOfFields));
else
    if ~isa(opt.Class, 'string')
        opt.Class = string(opt.Class);
    end
    opt.Class = opt.Class(:).';
    ixClass = any(opt.Class==listOfClasses, 2);
end

if isempty(opt.Filter)
    ixFilter = true(size(listOfFields));
else
    ixFilter = cellfun(@(name) feval(opt.Filter, d.(name)), listOfFields);
end

ixSelect = ixName & ixClass & ixFilter;

select = listOfFields(ixSelect);
tokens = tokens(ixSelect);

end
