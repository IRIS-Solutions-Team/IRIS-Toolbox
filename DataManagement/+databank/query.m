function [ select, tokens ] = query( runningDatabank, varargin )
% query  Filter databank fields by their names, classes or user query
%{
%}

% -IRIS Macroeconomic Modeling Toolbox
% -Copyright (c) 2007-2020 IRIS Solutions Team

persistent pp
if isempty(pp)
    pp = extend.InputParser('databank.query');
    pp.addRequired('database', @validate.databank);
    pp.addParameter({'Name', 'NameFilter'}, @all, @(x) isa(x, 'function_handle') || ischar(x) || iscellstr(x) || isa(x, 'string'));
    pp.addParameter({'Class', 'ClassFilter'}, @all, @(x) isequal(x, @all) || ischar(x) || iscellstr(x) || isa(x, 'string'));
    pp.addParameter('Filter', [ ], @(x) isempty(x) || isa(x, 'function_handle'));
end
pp.parse(runningDatabank, varargin{:});
opt = pp.Options;

if isstruct(runningDatabank)
    keys = @fieldnames;
    retrieve = @getfield;
end

%--------------------------------------------------------------------------

allKeys = keys(runningDatabank);
allKeys = reshape(allKeys, 1, [ ]);
numFields = numel(allKeys);

%
% Filter keys (field names)
%
tokens = repmat({[ ]}, size(allKeys));
if isequal(opt.Name, @all) || isequal(opt.Name, "--all")
    inxName = true(size(allKeys));
elseif isa(opt.Name, 'function_handle')
    if iscellstr(allKeys)
        inxName = cellfun(opt.Name, allKeys);
    else
        inxName = arrayfun(opt.Name, allKeys);
    end
else
    if ~isa(opt.Name, 'string')
        opt.Name = string(opt.Name);
    end
    if isscalar(opt.Name) && startsWith(opt.Name, "--rexp:")
        opt.Name = eraseBetween(opt.Name, 1, 7);
        [start, tokens] = regexp(allKeys, opt.Name, 'start', 'tokens', 'once');
        inxName = ~cellfun(@isempty, start);
    else
        opt.Name = reshape(opt.Name, 1, [ ]);
        inxName = any(opt.Name==allKeys, 2);
    end
end

%
% Filter field classes
%
listClasses = cellfun(@(name) class(retrieve(runningDatabank, name)), allKeys, 'UniformOutput', false);
if isequal(opt.Class, @all) || isequal(opt.Class, "--all")
    inxClass = true(size(allKeys));
else
    if ~isa(opt.Class, 'string')
        opt.Class = string(opt.Class);
    end
    opt.Class = reshape(opt.Class, 1, [ ]);
    inxClass = any(opt.Class==listClasses, 2);
end

%
% Run user query
%
if isempty(opt.Filter)
    inxFilter = true(size(allKeys));
else
    inxFilter = cellfun(@(name) feval(opt.Filter, retrieve(runningDatabank, name)), allKeys);
end

%
% Combine all filters
%
inxSelect = inxName & inxClass & inxFilter;

select = allKeys(inxSelect);
tokens = tokens(inxSelect);

end%

