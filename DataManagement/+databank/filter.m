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
    inputParser.addParameter({'Name', 'NameFilter'}, @all, @(x) isequal(x, @all) || ischar(x) || iscellstr(x) || isa(x, 'string'));
    inputParser.addParameter({'Class', 'ClassFilter'}, @all, @(x) isequal(x, @all) || ischar(x) || iscellstr(x) || isa(x, 'string'));
    inputParser.addParameter('Filter', [ ], @(x) isempty(x) || isa(x, 'function_handle'));
end
inputParser.parse(d, varargin{:});
opt = inputParser.Results;

%--------------------------------------------------------------------------

if isa(d, 'Dictionary')
    listFields = keys(d);
else
    listFields = fieldnames(d);
end
numFields = numel(listFields);

%
% Filter field names
%
tokens = repmat({[]}, size(listFields));
if isequal(opt.Name, @all) || isequal(opt.Name, "--all")
    inxName = true(size(listFields));
else
    if ~isa(opt.Name, 'string')
        opt.Name = string(opt.Name);
    end
    if isscalar(opt.Name) && startsWith(opt.Name, "--rexp:")
        opt.Name = erase(opt.Name, "--rexp:");
        [start, tokens] = regexp(listFields, opt.Name, 'start', 'tokens', 'once');
        inxName = ~cellfun(@isempty, start);
    else
        opt.Name = reshape(opt.Name, 1, [ ]);
        inxName = any(opt.Name==listFields, 2);
    end
end

%
% Filter field classes
%
listClasses = cellfun(@(x) class(getfield(d, x)), listFields, 'UniformOutput', false);
if isequal(opt.Class, @all) || isequal(opt.Class, "--all")
    inxClass = true(size(listFields));
else
    if ~isa(opt.Class, 'string')
        opt.Class = string(opt.Class);
    end
    opt.Class = opt.Class(:).';
    inxClass = any(opt.Class==listClasses, 2);
end

%
% Run user filter
%
if isempty(opt.Filter)
    inxFilter = true(size(listFields));
else
    inxFilter = cellfun(@(name) feval(opt.Filter, d.(name)), listFields);
end

%
% Combine all filters
%
inxSelect = inxName & inxClass & inxFilter;

select = listFields(inxSelect);
tokens = tokens(inxSelect);

end%

