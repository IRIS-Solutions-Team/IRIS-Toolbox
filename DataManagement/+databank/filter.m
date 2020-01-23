function [select, tokens] = filter(d, varargin)
% filter  Filter databank fields by their names, classes or user filter
%{
%}

% -IRIS Macroeconomic Modeling Toolbox
% -Copyright (c) 2007-2020 IRIS Solutions Team

persistent pp
if isempty(pp)
    pp = extend.InputParser('databank.filter');
    addRequired(pp, 'Database', @validate.databank);
    addParameter(pp, {'Name', 'NameFilter'}, @all, @(x) isequal(x, @all) || ischar(x) || iscellstr(x) || isstring(x));
    addParameter(pp, {'Class', 'ClassFilter'}, @all, @(x) isequal(x, @all) || ischar(x) || iscellstr(x) || isstring(x));
    addParameter(pp, 'Filter', [ ], @(x) isempty(x) || isa(x, 'function_handle'));
end
parse(pp, d, varargin{:});
opt = pp.Options;

%--------------------------------------------------------------------------

if isa(d, 'Dictionary')
    listFields = keys(d);
else
    listFields = fieldnames(d);
end
listFields = reshape(cellstr(listFields), 1, [ ]);

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
inxName = reshape(inxName, 1, [ ]);


%
% Filter field classes
%
if isequal(opt.Class, @all) || isequal(opt.Class, "--all")
    inxClass = true(size(listFields));
else
    if isa(d, 'Dictionary')
        func = @(x) class(retrieve(d, x));
    else
        func = @(x) class(d.(x));
    end
    listClasses = cellfun(func, listFields, 'UniformOutput', false);
    listClasses = reshape(string(listClasses), [ ], 1);
    opt.Class = reshape(string(opt.Class), 1, [ ]);
    inxClass = any(opt.Class==listClasses, 2);
end
inxClass = reshape(inxClass, 1, [ ]);


%
% Run user filter
%
if isempty(opt.Filter)
    inxFilter = true(size(listFields));
else
    inxFilter = cellfun(@(name) feval(opt.Filter, d.(name)), listFields);
end
inxFilter = reshape(inxFilter, 1, [ ]);


%
% Combine all filters
%
inxSelect = inxName & inxClass & inxFilter;

select = listFields(inxSelect);
tokens = tokens(inxSelect);

end%

