function [D,List0,List,Flag] = dbbatch(D,NewName,Expr,varargin)
% dbbatch  Run a batch job to create new database fields.
%
% Syntax
% =======
%
%     [D,Processed,Added] = dbbatch(D,NewName,Expr,...)
%
% Input arguments
% ================
%
% * `D` [ struct ] - Input database.
%
% * `NewName` [ char ] - Pattern that will be used to create names for new
% database fields based on the existing ones; use `'$0'` to refer to the
% name of the currently processed database field; use `'$1'`, `'$2'`, etc.
% to refer to tokens captured in regular expression specified in the
% `'namefilter='` option.
%
% * `Expr` [ char ] - Expression that will be evaluated on a selection of
% existing database entries to create new database entries; the expression
% can include `'$0'`, `'$1'`, etc.
%
% Output arguments
% =================
%
% * `D` [ struct ] - Output database.
%
% * `Processed` [ cellstr ] - List of database fields that have been used to
% create new fields.
%
% * `Added` [ cellstr ] - List of new database fields created by evaluating
% `Expr` on the corresponding field in `Processed`.
%
% Options
% ========
%
% * `'classFilter='` [ char | *`Inf`* ] - From the existing database entries,
% select only those that are objects of the specified class or classes, and
% evaluate the expression `Expr` on these.
%
% * `'fresh='` [ `true` | *`false`* ] - If `true`, the output database will
% only contain the newly created entries; if `false` the output database
% will also include all the entries from the input database.
%
% * `'nameFilter='` [ char | *empty* ] - From the existing database
% entries, select only those that match this regular expression, and
% evaluate the expression `Expr` on these.
%
% * `'nameList='` [ cellstr | *`Inf`* ] - Evaluate the `COMMAND` on this
% list of existing database entries.
%
% * `'stringList='` [ cellstr | *empty* ] - Evaluate the expression `Expr`
% on this list of strings; the strings do not need to be names existing in
% the database; this options can  be comined with `'nameFilter='`,
% `'nameList='`, and/or `'classFilter='` to narrow the selection.
%
% Description
% ============
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
% Failure
% --------
%
% The function `dbbatch` will *always* fail when called on a sub-database
% from within a function (as opposed to a script). A sub-database is a
% struct within a struct, a struct within a cell array, a struct within an
% array of structs, etc.
%
%     function ...
%         d.e = dbbatch(d.e,...);
%         ...
%     end
%
%     function ...
%         d{1} = dbbatch(d{1},...);
%         ...
%     end
%
%     function ...
%         d(1) = dbbatch(d(1),...);
%         ...
%     end
%
% Example
% ========
%
% For each field (all assumed to be tseries) create a first difference, and
% name the new series `DX` where `X` is the name of the original series.
%
%     d = dbbatch(d,'D$0','diff(d.$0)');
%
% Note that the original series will be presered in the database, together
% with the newly created ones.
%
% Example
% ========
%
% Suppose that in database `D` you want to seasonally adjust all time
% series whose names end with `_u`, and give these seasonally adjusted series
% names without the _u.
%
%     d = dbbatch(d,'$1','x12(d.$0)','nameFilter','(.*)u');
%
% or, if you want to make sure only tseries objects will be selected (in
% case there are database entries ending with a `u` other than tseries
% objects)
%
%     d = dbbatch(d,'$1','x12(d.$0)', ...
%         'nameFilter=','(.*)u','classFilter=','tseries');
%

% -IRIS Macroeconomic Modeling Toolbox.
% -Copyright (c) 2007-2017 IRIS Solutions Team.

% TODO: Streamline dbquery/unmask.

if ~isstruct(D) ...
        || ~ischar(NewName) ...
        || ~ischar(Expr) ...
        || ~iscellstr(varargin(1:2:nargin-3))
    error('Incorrect type of input argument(s).');
end

opt = passvalopt('dbase.dbbatch',varargin{:});

doOptions( ); 

%--------------------------------------------------------------------------

Expr = strrep(Expr,'"','''');

% Get the list of requested names.
[List0,tokens] = xxQuery(D,opt);

% Parse the new name patterns and the expression patterns.
[List,expr] = xxParse(NewName,Expr,List0,tokens);

Flag = true;

% When called from within a ***function***, the output database is "under
% construction" and cannot be evaluated from within dbbatch. Try to create
% a new database in the caller workspace and rename all references to the
% old database in the expressions. This may fail if the input database is a
% substruct or an element in cell array (in which case `inputname(1)`
% returns an empty string).
%
% NB: `dbbatch( )` will ***always fail*** when called on a subdatabase, i.e.
% `dbbatch(d.e,...)` or `dbbatch(d{1},...)` or `dbbatch(d(1),...)`, etc.
% from within a function.

inpDbName = inputname(1);
expr2eval = expr;
if ~isempty(inpDbName)
    tempDbName = tempname('.');
    tempDbName(1:2) = '';
    assignin('caller',tempDbName,D);
    expr2eval = regexprep(expr2eval,['\<',inpDbName,'\>'],tempDbName);
end

if opt.fresh
    D = struct( );
end

errList = { };
for i = 1 : length(List0)
    try
        lastwarn('');
        value = evalin('caller',expr2eval{i});
        D.(List{i}) = value;
        msg = lastwarn( );
        if ~isempty(msg)
            textfun.loosespace( );
            utils.warning('dbase:dbbatch', ...
                ['The above warning occurred when dbbatch( ) ', ...
                'attempted to evaluate ''%s''.'], ...
                expr{i});
        end
    catch Error
        msg = Error.message;
        msg = regexprep(msg,'^Error:\s*','','once');
        msg = strtrim(msg);
        errList(end+(1:2)) = {expr{i},msg}; %#ok<AGROW>
    end
end

if ~isempty(errList)
    Flag = false;   
    utils.warning('dbase:dbbatch', ...
        ['Error evaluating this expression in dbbatch( ): ''%s''.\n', ...
        '\tUncle says: %s'], ...
        errList{:});
end


% Nested functions...


%**************************************************************************

    
    function doOptions( )
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
            opt.namelist = regexp(opt.namelist,'\w+','match');
        end
        
        if ischar(opt.stringlist)
            opt.stringlist = regexp(opt.stringlist,'\w+','match');
        end
        
        if ischar(opt.classlist)
            opt.classlist = regexp(opt.classlist,'\w+','match');
        end
    end % doOptions( )

end


% Subfunctions...


%**************************************************************************


function [List0,Tokens] = xxQuery(D,Opt)

classl = Opt.classlist;
namef = Opt.namefilter;
namel = Opt.namelist;
freqf = Opt.freqfilter;
stringl = Opt.stringlist;

if isempty(stringl)
    List0 = fieldnames(D).';
else
    List0 = stringl;
end
Tokens = cell(size(List0));
Tokens(:) = {{ }};

% Name list.
if iscellstr(namel)
    List0 = intersect(List0,namel);
end

% Name filter.
if ~isequal(namef,Inf) && ~isempty(namef)
    if namef(1) ~= '^'
        namef = ['^',namef];
    end
    if namef(end) ~= '$'
        namef = [namef,'$'];
    end
    [index,~,Tokens] = textfun.matchindex(List0,namef);
    List0 = List0(index);
end

% Class list.
if ~(isnumeric(classl) && isinf(classl))
    index = false(size(List0));
    for i = 1 : numel(List0)
        c = class(D.(List0{i}));
        index(i) = any(strcmpi(c,classl));
    end
    List0 = List0(index);
    Tokens = Tokens(index);
end

% Frequency filter.
if ~isequal(freqf,Inf)
    index = false(size(List0));
    for i = 1 : numel(List0)
        index(i) = ~isa(D.(List0{i}),'tseries') ...
            || any(freq(D.(List0{i})) == freqf);
    end
    List0 = List0(index);
    Tokens = Tokens(index);
end

end % xxQuery( )


%**************************************************************************


function [List1,Expr] = xxParse(NamePatt,ExprPatt,List0,Tokens)

% Create new names from the pattern.
if ~isempty(NamePatt)
    List1 = cell(size(List0));
    for i = 1 : numel(List0)
        List1{i} = xxParseOne(NamePatt,List0{i},Tokens{i}{:});
    end
else
    List1(1:length(List0)) = {''};
end

% Create expressions from the pattern.
if ~isempty(ExprPatt)
    Expr = cell(size(List0));
    for i = 1 : numel(List0)
        if ~isempty(ExprPatt)
            Expr{i} = xxParseOne(ExprPatt,List0{i},Tokens{i}{:});
        end
    end
else
    Expr(1:length(List0)) = {''};
end

end % xxParse( )


%**************************************************************************


function C = xxParseOne(C,varargin)

for i = 1 : length(varargin)
    C = strrep(C,sprintf('$.%g',i-1),lower(varargin{i}));
    C = strrep(C,sprintf('$:%g',i-1),upper(varargin{i}));
    C = strrep(C,sprintf('lower($%g)',i-1),lower(varargin{i}));
    C = strrep(C,sprintf('upper($%g)',i-1),upper(varargin{i}));
    C = strrep(C,sprintf('$%g',i-1),varargin{i});
end
C = regexprep(C,'\$\d*','');

end % xxParseOne( )
