function [d, list0, list, flag] = dbbatch(d, newName, expn, varargin)
% dbbatch  Run a batch job to create new database fields.
%
% __Syntax__
%
%     [D, ListProcessed, ListAdded] = dbbatch(D, NewName, Expression, ...)
%
%
% __Input Arguments__
%
% * `D` [ struct ] - Input database.
%
% * `NewName` [ char ] - Pattern that will be used to create names for new
% database fields based on the existing ones; use `'$0'` to refer to the
% name of the currently processed database field; use `'$1'`, `'$2'`, etc.
% to refer to tokens captured in regular expression specified in the
% `'NameFilter='` option.
%
% * `Expression` [ char ] - Expression that will be evaluated on a
% selection of existing database entries to create new database entries;
% the expression can include `'$0'`, `'$1'`, etc.
%
%
% __Output Arguments__
%
% * `D` [ struct ] - Output database.
%
% * `ListProcessed` [ cellstr ] - List of database fields that have been
% used to create new fields.
%
% * `ListAdded` [ cellstr ] - List of new database fields created by
% evaluating `Expression` on the corresponding field in `ListProcessed`.
%
%
% __Options__
%
% * `'ClassFilter='` [ char | *`Inf`* ] - From the existing database entries, 
% select only those that are objects of the specified class or classes, and
% evaluate the expression `Expr` on these.
%
% * `'Fresh='` [ `true` | *`false`* ] - If `true`, the output database will
% only contain the newly created entries; if `false` the output database
% will also include all the entries from the input database.
%
% * `'NameFilter='` [ char | *empty* ] - From the existing database
% entries, select only those that match this regular expression, and
% evaluate the expression `Expr` on these.
%
% * `'NameList='` [ cellstr | *`Inf`* ] - Evaluate the expression `expn` on
% this list of existing database entries.
%
% * `'StringList='` [ cellstr | *empty* ] - Evaluate the expression `expn`
% on this list of strings; the strings do not need to be names existing in
% the database; this options can  be comined with `'NameFilter='`, 
% `'NameList='`, and/or `'ClassFilter='` to narrow the selection.
%
%
% __Description__
%
% This function is primarily meant to create new database fields, each
% based on an existing one. If you, on the otherhand, only wish to modify a
% number of existing fields without adding any new ones, use
% [`dbfun`](dbase/dbfun) instead.
%
% The expression `Expr` is evaluated in the caller workspace, and hence may
% refer to any variables existing in the workspace, not only to the
% database and its fields.
%
% To convert the strings `$0`, `$1`, `$2`, etc. to lower case or upper
% case, use the dot or colon syntax: `$.0`, `$.1`, `$.2` for ower case, and
% `$:0`, `$:1`, `$:2` for upper case.
%
%
% _Failure_
%
% The function `dbbatch` will *always* fail when called on a sub-database
% from within a function (as opposed to a script). A sub-database is a
% struct within a struct, a struct within a cell array, a struct within an
% array of structs, etc.
%
%     function ...
%         d.e = dbbatch(d.e, ...);
%         ...
%     end
%
%     function ...
%         d{1} = dbbatch(d{1}, ...);
%         ...
%     end
%
%     function ...
%         d(1) = dbbatch(d(1), ...);
%         ...
%     end
%
%
% __Example__
%
% For each field (all assumed to be tseries) create a first difference, and
% name the new series `DX` where `X` is the name of the original series.
%
%     d = dbbatch(d, 'D$0', 'diff(d.$0)');
%
% Note that the original series will be presered in the database, together
% with the newly created ones.
%
%
% __Example__
%
% Suppose that in database `D` you want to seasonally adjust all time
% series whose names end with `_u`, and give these seasonally adjusted series
% names without the _u.
%
%     d = dbbatch(d, '$1', 'x12(d.$0)', 'nameFilter', '(.*)u');
%
% or, if you want to make sure only tseries objects will be selected (in
% case there are database entries ending with a `u` other than tseries
% objects)
%
%     d = dbbatch(d, '$1', 'x12(d.$0)', ...
%         'nameFilter=', '(.*)u', 'classFilter=', 'tseries');
%

% -IRIS Macroeconomic Modeling Toolbox.
% -Copyright (c) 2007-2018 IRIS Solutions Team.

% TODO: Streamline dbquery/unmask.

pp = inputParser( );
pp.addRequired('d', @isstruct);
pp.addRequired('newName', @ischar);
pp.addRequired('expn', @ischar);
pp.parse(d, newName, expn);

opt = passvalopt('dbase.dbbatch', varargin{:});

processOptions( ); 

%--------------------------------------------------------------------------

expn = strrep(expn, '"', '''');

% Get the list of requested names.
[list0, tokens] = query(d, opt);

% Parse the new name patterns and the expression patterns.
[list, expn] = parse(newName, expn, list0, tokens);

flag = true;

% When called from within a ***function***, the output database is "under
% construction" and cannot be evaluated from within dbbatch. Try to create
% a new database in the caller workspace and rename all references to the
% old database in the expressions. This may fail if the input database is a
% substruct or an element in cell array (in which case `inputname(1)`
% returns an empty string).
%
% NB: `dbbatch( )` will ***always fail*** when called on a subdatabase, i.e.
% `dbbatch(d.e, ...)` or `dbbatch(d{1}, ...)` or `dbbatch(d(1), ...)`, etc.
% from within a function.

inpDbName = inputname(1);
expr2eval = expn;
if ~isempty(inpDbName)
    tempDbName = tempname('.');
    tempDbName(1:2) = '';
    assignin('caller', tempDbName, d);
    expr2eval = regexprep(expr2eval, ['\<', inpDbName, '\>'], tempDbName);
end

if opt.fresh
    d = struct( );
end

errList = { };
for i = 1 : length(list0)
    try
        lastwarn('');
        value = evalin('caller', expr2eval{i});
        d.(list{i}) = value;
        msg = lastwarn( );
        if ~isempty(msg)
            textfun.loosespace( );
            utils.warning('dbase:dbbatch', ...
                ['The above warning occurred when dbbatch( ) ', ...
                'attempted to evaluate ''%s''.'], ...
                expn{i});
        end
    catch Error
        msg = Error.message;
        msg = regexprep(msg, '^Error:\s*', '', 'once');
        msg = strtrim(msg);
        errList(end+(1:2)) = {expn{i}, msg}; %#ok<AGROW>
    end
end

if ~isempty(errList)
    flag = false;   
    utils.warning('dbase:dbbatch', ...
        ['Error evaluating this expression in dbbatch( ): ''%s''.\n', ...
        '\tUncle says: %s'], ...
        errList{:});
end

return




    function processOptions( )
        % Bkw compatibility.
        % Deprecated options 'merge' and 'append'.
        if ~isempty(opt.merge)
            opt.fresh = ~opt.merge;
            utils.warning('dbase:dbbatch', ...
                ['The option ''merge='' is deprecated and ', ...
                'will be removed from IRIS in a future version. ', ...
                'Use ''fresh='' instead.']);
        elseif ~isempty(opt.append)
            opt.fresh = ~opt.append;
            utils.warning('dbase:dbbatch', ...
                ['The option ''append='' is obsolete and ', ...
                'will be removed from IRIS in a future version. ', ...
                'Use ''fresh='' instead.']);
        end
        
        if ischar(opt.namelist)
            opt.namelist = regexp(opt.namelist, '\w+', 'match');
        end
        
        if ischar(opt.stringlist)
            opt.stringlist = regexp(opt.stringlist, '\w+', 'match');
        end
        
        if ischar(opt.classlist)
            opt.classlist = regexp(opt.classlist, '\w+', 'match');
        end
    end 
end




function [list0, tkn] = query(d, opt)
lsClass = opt.classlist;
lsNameFilter = opt.namefilter;
lsName = opt.namelist;
vecFreq = opt.freqfilter;
lsString = opt.stringlist;
if isempty(lsString)
    list0 = fieldnames(d).';
else
    list0 = lsString;
end
tkn = cell(size(list0));
tkn(:) = {{ }};
% Name list.
if iscellstr(lsName)
    list0 = intersect(list0, lsName);
end
% Name filter.
if ~isequal(lsNameFilter, Inf) && ~isempty(lsNameFilter)
    if lsNameFilter(1) ~= '^'
        lsNameFilter = ['^', lsNameFilter];
    end
    if lsNameFilter(end) ~= '$'
        lsNameFilter = [lsNameFilter, '$'];
    end
    [ixPass, ~, tkn] = textfun.matchindex(list0, lsNameFilter);
    list0 = list0(ixPass);
end
% Class list.
if ~isequal(lsClass, @all) && ~isequal(lsClass, Inf)
    ixPass = false(size(list0));
    for i = 1 : numel(list0)
        x = d.(list0{i});
        ixPass(i) = any(cellfun(@(cls) isa(x, cls), lsClass));
    end
    list0 = list0(ixPass);
    tkn = tkn(ixPass);
end
% Date frequency filter.
if ~isequal(vecFreq, Inf)
    ixPass = false(size(list0));
    for i = 1 : numel(list0)
        ixPass(i) = ~isa(d.(list0{i}), 'tseries') ...
            || any(freq(d.(list0{i})) == vecFreq);
    end
    list0 = list0(ixPass);
    tkn = tkn(ixPass);
end
end%




function [list1, expr] = parse(namePatt, exprPatt, list0, tkn)
    % Create new names from the pattern.
    if ~isempty(namePatt)
        list1 = cell(size(list0));
        for i = 1 : numel(list0)
            list1{i} = parseOne(namePatt, list0{i}, tkn{i}{:});
        end
    else
        list1(1:length(list0)) = {''};
    end
    % Create expressions from the pattern.
    if ~isempty(exprPatt)
        expr = cell(size(list0));
        for i = 1 : numel(list0)
            if ~isempty(exprPatt)
                expr{i} = parseOne(exprPatt, list0{i}, tkn{i}{:});
            end
        end
    else
        expr(1:length(list0)) = {''};
    end
end




function c = parseOne(c, varargin)
    for i = 1 : length(varargin)
        c = strrep(c, sprintf('$.%g', i-1), lower(varargin{i}));
        c = strrep(c, sprintf('$:%g', i-1), upper(varargin{i}));
        c = strrep(c, sprintf('lower($%g)', i-1), lower(varargin{i}));
        c = strrep(c, sprintf('upper($%g)', i-1), upper(varargin{i}));
        c = strrep(c, sprintf('$%g', i-1), varargin{i});
    end
    c = regexprep(c, '\$\d*', '');
end
