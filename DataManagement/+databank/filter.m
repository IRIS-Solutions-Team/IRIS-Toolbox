function [select, tokens] = filter(d, varargin)
% filter  Filter databank fields by their names, classes or user filter
%{
%}

% -IRIS Macroeconomic Modeling Toolbox
% -Copyright (c) 2007-2019 IRIS Solutions Team

persistent inputParser
if isempty(inputParser)
    inputParser = extend.InputParser('databank.filter');
    inputParser.addRequired('Database', @validate.databank);
    inputParser.addParameter({'Name', 'NameFilter'}, "--all", @(x) isequal(x, @all) || ischar(x) || iscellstr(x) || isa(x, 'string'));
    inputParser.addParameter({'Class', 'ClassFilter'}, "--all", @(x) isequal(x, @all) || ischar(x) || iscellstr(x) || isa(x, 'string'));
    inputParser.addParameter('Filter', [ ], @(x) isempty(x) || isa(x, 'function_handle'));
end
inputParser.parse(d, varargin{:});
opt = inputParser.Results;

%--------------------------------------------------------------------------

listFields = fieldnames(d);
numFields = numel(listFields);
listClasses = cell(size(listFields));
for i = 1 : numFields
    ithName = listFields{i};
    x = getfield(d, ithName);
    listClasses{i} = class(getfield(d, ithName));
end
tokens = repmat({[]}, size(listFields));

if isequal(opt.Name, @all) || isequal(opt.Name, "--all")
    ixName = true(size(listFields));
else
    if ~isa(opt.Name, 'string')
        opt.Name = string(opt.Name);
    end
    if isscalar(opt.Name) && startsWith(opt.Name, "--rexp:")
        opt.Name = erase(opt.Name, "--rexp:");
        [start, tokens] = regexp(listFields, opt.Name, 'start', 'tokens', 'once');
        ixName = ~cellfun(@isempty, start);
    else
        opt.Name = opt.Name(:).';
        ixName = any(opt.Name==listFields, 2);
    end
end

if isequal(opt.Class, @all) || isequal(opt.Class, "--all")
    ixClass = true(size(listFields));
else
    if ~isa(opt.Class, 'string')
        opt.Class = string(opt.Class);
    end
    opt.Class = opt.Class(:).';
    ixClass = any(opt.Class==listClasses, 2);
end

if isempty(opt.Filter)
    ixFilter = true(size(listFields));
else
    ixFilter = cellfun(@(name) feval(opt.Filter, d.(name)), listFields);
end

ixSelect = ixName & ixClass & ixFilter;

select = listFields(ixSelect);
tokens = tokens(ixSelect);

end%

