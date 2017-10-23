function listFields = dbnames(varargin)
% dbnames  List of database entries filtered by name and/or class.
%
% __Syntax__
%
%     List = dbnames(D, ...)
%
%
% __Input Arguments__
%
% * `D` [ struct ] - Input database.
%
%
% __Output Arguments__
%
% * `List` [ cellstr ] - List of input database entries that pass the name,
% class or user test.
%
%
% __Options__
%
% * `'NameFilter='` [ cellstr | char | rexp | *`@all`* ] - List of names or
% regular expression against which the database entry names will be
% matched; `@all` means all names will be matched.
%
% * `'ClassFilter='` [ cellstr | char | rexp | *`@all`* ] - List of names
% or regular expression against which the database entry class names will
% be matched; `@all` means all classes will be matched.
%
% * `'UserFilter='` [ function_handle ] - Function that accepts one input
% argument (the tested database entry) and returns `true` or `false`.
%
%
% __Description__
%
%
% __Example__
%
% Notice the differences in the following calls to `dbnames`:
%
%     dbnames(d, 'NameFilter=', 'L_')
%
% matches all names that contain `'L_'` (at the beginning, in the middle, 
% or at the end of the string), such as `'L_A'`, `'DL_A'`, `'XL_'`, or just
% `'L_'`.
%
%     dbnames(d, 'NameFilter=', '^L_')
%
% matches all names that start with `'L_'`, such as `'L_A'` or `'L_'`, but
% not `'DL_A'`. Finally, 
%
%     dbnames(d, 'NameFilter=', '^L_.')
%
% matches all names that start with `'L_'` and have at least one more
% character after that, such as `'L_A'` but not `'L_'` or `'L_RX'`.
%

% -IRIS Macroeconomic Modeling Toolbox.
% -Copyright (c) 2007-2017 IRIS Solutions Team.

[D, varargin] = irisinp.parser.parse('dbase.dbnames', varargin{:});
opt = passvalopt('dbase.dbnames', varargin{:});

%--------------------------------------------------------------------------

% Empty name filter and empty class filter returns empty listFields.
if isempty(opt.namefilter) && isempty(opt.classfilter)
    listFields = cell(1, 0);
    return
end

if ( isequal(opt.namefilter, @all) || isequal(opt.namefilter, Inf) ) ...
        && ( isequal(opt.classfilter, @all) || isequal(opt.classfilter, Inf) )
    listFields = fieldnames(D);
    return
end

if ischar(opt.classfilter) || isa(opt.classfilter, 'string')
    opt.classfilter = cellstr(opt.classfilter);
end

listFields = fieldnames(D);
listFields = listFields(:)';
indexClassTest = validateClasses(D, listFields, opt.classfilter);
indexNameTest = validateNames(listFields, opt.namefilter);

% Return the names that pass both tests.
listFields = listFields(indexNameTest & indexClassTest);

end


function indexTest = validateNames(listFields, nameFilter)
    indexTest = true(size(listFields));
    if isequal(nameFilter, @all)
        indexTest(:) = true;
        return
    elseif isempty(nameFilter)
        indexTest(:) = false;
        return
    elseif ischar(nameFilter) || isa(nameFilter, 'rexp')
        x = regexp(listFields, nameFilter, 'once');
        indexTest = ~cellfun(@isempty, x);
        return
    elseif iscellstr(nameFilter)
        for i = 1 : numel(listFields)
            indexTest(i) = any(strcmp(listFields{i}, nameFilter));
        end
    end
end


function indexTest = validateClasses(D, listFields, classFilter)
    indexTest = false(size(listFields));
    if isequal(classFilter, @all)
        indexTest(:) = true;
        return
    end
    if isempty(classFilter)
        indexTest(:) = true;
    end
    numFields = numel(listFields);
    if iscellstr(classFilter)
        for i = 1 : numFields
            for j = 1 : numel(classFilter)
                indexTest(i) = indexTest(i) | isa(D.(listFields{i}), classFilter{j});
            end
        end
    elseif isa(classFilter, 'rexp')
        for i = 1 : numFields
            ithClass = class(D.(listFields{i}));
            x = regexp(ithClass, classFilter, 'once');
            indexTest(i) = ~isempty(x);
        end
    end
end

