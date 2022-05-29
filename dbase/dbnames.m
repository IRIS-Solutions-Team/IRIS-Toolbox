function listFields = dbnames(inputDatabank, varargin)
% dbnames  List of database entries filtered by name and/or class
%
% ## Syntax ##
%
%     list = dbnames(inputDatabank, ...)
%
%
% ## Input Arguments ##
%
% __`inputDatabank`__ [ struct | Dictionary ] - 
% Input database.
%
%
% ## Output Arguments ##
%
% __`list`__ [ cellstr ] - 
% List of input database entries that pass the name, class or user test.
%
%
% ## Options ##
%
% __`NameFilter=@all`__ [ cellstr | char | rexp | `@all` ] - 
% List of names or regular expression against which the database entry
% names will be matched; `@all` means all names will be matched.
%
% __`ClassFilter=@all`__ [ cellstr | char | rexp | `@all` ] - 
% List of names or regular expression against which the database entry
% class names will be matched; `@all` means all classes will be matched.
%
% __`UserFilter=@all`__ [ function_handle | `@all` ] - 
% Function that accepts one input argument (the tested database entry) and
% returns `true` or `false`.
%
%
% ## Description ##
%
%
% ## Example ##
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

% -IRIS Macroeconomic Modeling Toolbox
% -Copyright (c) 2007-2022 IRIS Solutions Team

persistent parser
if isempty(parser)
    parser = extend.InputParser('dates.dbnames');
    addRequired(parser, 'InputDatabank', @validate.databank);
    addParameter(parser, {'ClassFilter', 'ClassList'}, @all, @(x) isequal(x, @all) || ischar(x) || iscellstr(x) || isa(x, 'rexp'));
    addParameter(parser, {'NameFilter', 'NameList'}, @all, @(x) isequal(x, @all) || ischar(x) || iscellstr(x) || isa(x, 'rexp'));
    addParameter(parser, 'UserFilter', @all, @(x) isequal(x, @all) || isa(x, 'function_handle'));
end
parse(parser, inputDatabank, varargin{:});
opt = parser.Options;

%--------------------------------------------------------------------------

% Empty name filter and empty class filter returns empty listFields
if isempty(opt.NameFilter) && isempty(opt.ClassFilter)
    listFields = cell(1, 0);
    return
end

if ( isequal(opt.NameFilter, @all) || isequal(opt.NameFilter, Inf) ) ...
        && ( isequal(opt.ClassFilter, @all) || isequal(opt.ClassFilter, Inf) ) ...
        && isequal(opt.UserFilter, @all)
    listFields = fieldnames(inputDatabank);
    return
end

if ischar(opt.ClassFilter) || isa(opt.ClassFilter, 'string')
    opt.ClassFilter = cellstr(opt.ClassFilter);
end

listFields = fieldnames(inputDatabank);
listFields = listFields(:)';
inxClassTest = validateClasses(inputDatabank, listFields, opt.ClassFilter);
inxNameTest = validateNames(listFields, opt.NameFilter);
inxUserTest = validateUser(inputDatabank, listFields, opt.UserFilter);

% Return the names that pass both tests
listFields = listFields(inxNameTest & inxClassTest & inxUserTest);

end%


%
% Local Functions
%


function inxTest = validateNames(listFields, nameFilter)
    inxTest = true(size(listFields));
    if isequal(nameFilter, @all)
        inxTest(:) = true;
        return
    elseif isempty(nameFilter)
        inxTest(:) = false;
        return
    elseif ischar(nameFilter) || isa(nameFilter, 'rexp')
        x = regexp(listFields, nameFilter, 'once');
        inxTest = ~cellfun(@isempty, x);
        return
    elseif iscellstr(nameFilter)
        for i = 1 : numel(listFields)
            inxTest(i) = any(strcmp(listFields{i}, nameFilter));
        end
    end
end%




function inxTest = validateClasses(inputDatabank, listFields, classFilter)
    inxTest = false(size(listFields));
    if isequal(classFilter, @all)
        inxTest(:) = true;
        return
    end
    if isempty(classFilter)
        inxTest(:) = false;
        return
    end
    numFields = numel(listFields);
    if iscellstr(classFilter)
        for i = 1 : numFields
            ithValue = inputDatabank.(listFields{i});
            for j = 1 : numel(classFilter)
                inxTest(i) = inxTest(i) | isa(ithValue, classFilter{j});
                if inxTest(i)
                    break
                end
            end
        end
    elseif isa(classFilter, 'rexp')
        for i = 1 : numFields
            ithValue = inputDatabank.(listFields{i});
            ithClass = class(ithValue);
            x = regexp(ithClass, classFilter, 'once');
            inxTest(i) = ~isempty(x);
        end
    end
end%




function inxTest = validateUser(inputDatabank, listFields, userFilter)
    inxTest = false(size(listFields));
    if isequal(userFilter, @all)
        inxTest(:) = true;
        return
    end
    for i = 1 : numel(listFields)
        ithValue = inputDatabank.(listFields{i});
        try
            pass = userFilter(ithValue);
        catch
            pass = false;
        end
        inxTest(i) = validate.logicalScalar(pass) && isequal(pass, true);
    end
end%

