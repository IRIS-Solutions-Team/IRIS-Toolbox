function List = dbnames(varargin)
% dbnames  List of database entries filtered by name and/or class.
%
%
% Syntax
% =======
%
%     List = dbnames(D,...)
%
%
% Input arguments
% ================
%
% * `D` [ struct ] - Input database.
%
%
% Output arguments
% =================
%
% * `List` [ cellstr ] - List of input database entries that pass the name
% or class test.
%
%
% Options
% ========
%
% * `'nameFilter='` [ cellstr | char | rexp | *`@all`* ] - List of names or
% regular expression against which the database entry names will be
% matched; `@all` means all names will be matched.
%
% * `'classFilter='` [ cellstr | char | rexp | *`@all`* ] - List of names
% or regular expression against which the database entry class names will
% be matched; `@all` means all classes will be matched.
%
%
% Description
% ============
%
%
% Example
% ========
%
% Notice the differences in the following calls to `dbnames`:
%
%     dbnames(d,'nameFilter=','L_')
%
% matches all names that contain `'L_'` (at the beginning, in the middle,
% or at the end of the string), such as `'L_A'`, `'DL_A'`, `'XL_'`, or just
% `'L_'`.
%
%     dbnames(d,'nameFilter=','^L_')
%
% matches all names that start with `'L_'`, such as `'L_A'` or `'L_'`, but
% not `'DL_A'`. Finally,
%
%     dbnames(d,'nameFilter=','^L_.')
%
% matches all names that start with `'L_'` and have at least one more
% character after that, such as `'L_A'` but not `'L_'` or `'L_RX'`.
%

% -IRIS Macroeconomic Modeling Toolbox.
% -Copyright (c) 2007-2017 IRIS Solutions Team.

[D,varargin] = irisinp.parser.parse('dbase.dbnames',varargin{:});
opt = passvalopt('dbase.dbnames',varargin{:});

%--------------------------------------------------------------------------

% Empty name filter and empty class filter returns empty list.
if isempty(opt.namefilter) && isempty(opt.classfilter)
    List = cell(1,0);
    return
end

if ( isequal(opt.namefilter,@all) || isequal(opt.namefilter,Inf) ) ...
        && ( isequal(opt.classfilter,@all) || isequal(opt.classfilter,Inf) )
    List = fieldnames(D);
    return
end

% Get the database entry names and classes. Make sure order of names
% corresponds to order of classes (not guaranteed by Matlab in general).
c = structfun(@class,D,'uniformOutput',false);
List = fieldnames(c).';
c = struct2cell(c).';

ixClassTest = xxValidate(c,opt.classfilter);
ixNameTest = xxValidate(List,opt.namefilter);

% Return the names that pass both tests.
List = List(ixNameTest & ixClassTest);

end


% Subfunctions...


%**************************************************************************


function IxTest = xxValidate(List,Filter)
IxTest = true(size(List));
if isequal(Filter,@all)
    IxTest(:) = true;
    return
elseif isempty(Filter)
    IxTest(:) = false;
    return
elseif ischar(Filter) || isrexp(Filter)
    x = regexp(List,Filter,'once');
    IxTest = ~cellfun(@isempty,x);
    return
elseif iscellstr(Filter)
    for i = 1 : numel(List)
        IxTest(i) = any(strcmp(List{i},Filter));
    end
end
end % xxValidate( )
