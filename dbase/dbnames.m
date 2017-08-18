function list = dbnames(varargin)
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
% * `List` [ cellstr ] - List of input database entries that pass the name
% or class test.
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

% Empty name filter and empty class filter returns empty list.
if isempty(opt.namefilter) && isempty(opt.classfilter)
    list = cell(1, 0);
    return
end

if ( isequal(opt.namefilter, @all) || isequal(opt.namefilter, Inf) ) ...
        && ( isequal(opt.classfilter, @all) || isequal(opt.classfilter, Inf) )
    list = fieldnames(D);
    return
end

% Get the database entry names and classes. Make sure order of names
% corresponds to order of classes (not guaranteed by Matlab in general).
c = structfun(@class, D, 'UniformOutput', false);
list = fieldnames(c).';
c = struct2cell(c).';
c = strrep(c, 'Series', 'tseries');

ixClassTest = validate(c, opt.classfilter);
ixNameTest = validate(list, opt.namefilter);

% Return the names that pass both tests.
list = list(ixNameTest & ixClassTest);

end




function ixTest = validate(list, filter)
ixTest = true(size(list));
if isequal(filter, @all)
    ixTest(:) = true;
    return
elseif isempty(filter)
    ixTest(:) = false;
    return
elseif ischar(filter) || isa(filter, 'rexp')
    x = regexp(list, filter, 'once');
    ixTest = ~cellfun(@isempty, x);
    return
elseif iscellstr(filter)
    for i = 1 : numel(list)
        ixTest(i) = any(strcmp(list{i}, filter));
    end
end
end
