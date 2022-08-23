function [d, list0, list, flag] = dbbatch(d, newName, userExpression, varargin)
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
% * `'NameList='` [ cellstr | *`Inf`* ] - Evaluate the expression `userExpression` on
% this list of existing database entries.
%
% * `'StringList='` [ cellstr | *empty* ] - Evaluate the expression `userExpression`
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
% For each field (all assumed to be time series) create a first difference, and
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
% or, if you want to make sure only time series objects will be selected (in
% case there are database entries ending with a `u` other than time series
% objects)
%
%     d = dbbatch(d, '$1', 'x12(d.$0)', ...
%         'nameFilter=', '(.*)u', 'classFilter=', 'Series');
%

% -IRIS Macroeconomic Modeling Toolbox.
% -Copyright (c) 2007-2022 IRIS Solutions Team.

% TODO: Streamline dbquery/unmask.

WARNING_ERROR_EVALUATING = { 'Databank:ErrorEvaluatingExpression', ... 
                             [ 'Error evaluating this expression in dbbatch(~): %s \n', ...
                               '\h$ENGINE$ says: %s' ] };
WARNING_WARNING_EVALUATING = { 'Databank:WarningEvaluatingExpression', ...
                               'The above warning occurred when evaluating this expression in dbbatch(~): %s ' };

persistent parser
if isempty(parser)
    parser = extend.InputParser('dbase.dbbatch');
    parser.addRequired('InputDatabank', @isstruct);
    parser.addRequired('NewName', @(x) ischar(x) || isa(x, 'string'));
    parser.addRequired('Expression', @(x) ischar(x) || isa(x, 'string'));
    parser.addParameter('AddToDatabank', @auto, @(x) isequal(x, @auto) || isempty(x) || isstruct(x));
    parser.addParameter({'ClassList', 'ClassFilter'}, @all, @(x) isequal(x, @all) || isequal(x, Inf) || ischar(x) || iscellstr(x) || isa(x, 'string'));
    parser.addParameter('FreqFilter', Inf, @isnumeric);
    parser.addParameter('InputDatabankName', @auto, @(x) isequal(x, @auto) || ischar(x) || isa(x, 'string'));
    parser.addParameter('NameFilter', '', @(x) isempty(x) || isequal(x, Inf) || ischar(x) || isa(x, 'string'));
    parser.addParameter('NameList', Inf, @(x) isequal(x, Inf) || ischar(x) || iscellstr(x) || isa(x, 'string'));
    parser.addParameter('Fresh', false, @(x) isequal(x, @auto) || isequal(x, true) || isequal(x, false) || isstruct(x));
    parser.addParameter('StringList', cell.empty(1, 0), @(x) iscellstr(x) || ischar(x) || isa(x, 'string'));
end
parser.parse(d, newName, userExpression, varargin{:});
opt = parser.Options;
processOptions( ); 

%--------------------------------------------------------------------------

userExpression = strrep(userExpression, '"', '''');

% Get the list of requested names.
[list0, tokens] = query(d, opt);

% Parse the new name patterns and the expression patterns.
[list, userExpression] = parse(newName, userExpression, list0, tokens);

flag = true;

% When called from within a ***function***, the output database is "under
% construction" and cannot be evaluated from within dbbatch. Try to create
% a new database in the caller workspace and rename all references to the
% old database in the expressions. This may fail if the input database is a
% substruct or an element in cell array (in which case `inputname(1)`
% returns an empty string).
%
% `dbbatch( )` will ***always fail*** when called on a subdatabase, i.e.
% `dbbatch(d.e, ...)` or `dbbatch(d{1}, ...)` or `dbbatch(d(1), ...)`, etc.
% from within a function.

% Create a temporary databank in the caller workspace whenever possible
expressionToEval = userExpression;
inputDatabankName = opt.InputDatabankName;
tempDatabankName = '';
if isequal(inputDatabankName, @auto)
    inputDatabankName = inputname(1);
end
if ~isempty(inputDatabankName);
    tempDatabankName = tempname('.');
    tempDatabankName(1:2) = '';
    assignin('caller', tempDatabankName, d);
    expressionToEval = regexprep( expressionToEval, ...
                                  ['\<', inputDatabankName, '\>'], ...
                                  tempDatabankName );
end

initializeOutputDatabank( );

listOfErrors = cell.empty(1, 0);
for i = 1 : length(list0)
    try
        lastwarn('');
        value = evalin('caller', expressionToEval{i});
        d.(list{i}) = value;
        msg = lastwarn( );
        if ~isempty(msg)
            textfun.loosespace( );
            throw( exception.Base(WARNING_WARNING_EVALUATING, 'warning'), ...
                   userExpression{i} );
        end
    catch Error
        msg = Error.message;
        msg = regexprep(msg, '^Error:\s*', '', 'once');
        msg = strtrim(msg);
        listOfErrors = [listOfErrors, userExpression(i), {msg}]; %#ok<AGROW>
    end
end

if ~isempty(listOfErrors)
    flag = false;   
    throw( exception.Base(WARNING_ERROR_EVALUATING, 'warning'), ...
           listOfErrors{:} );
end

% Clean up
if ~isempty(tempDatabankName)
    evalin('caller', ['clear ', tempDatabankName]);
end

return


    function processOptions( )
        if ischar(opt.NameList)
            opt.NameList = regexp(opt.NameList, '\w+', 'match');
        elseif isa(opt.NameList, 'string')
            opt.NameList = cellstr(opt.NameList);
        end
        if ischar(opt.StringList)
            opt.StringList = regexp(opt.StringList, '\w+', 'match');
        elseif isa(opt.StringList, 'string')
            opt.StringList = cellstr(opt.StringList);
        end
        if ischar(opt.ClassList)
            opt.ClassList = regexp(opt.ClassList, '\w+', 'match');
        elseif isa(opt.ClassList, 'string')
            opt.ClassList = cellstr(opt.ClassList);
        end
    end%


    function initializeOutputDatabank( )
        if ~isequal(opt.AddToDatabank, @auto)
            d = opt.AddToDatabank;
        end
        if ~isequal(opt.Fresh, @auto)
            if isequal(opt.Fresh, true)
                d = struct( );
            elseif isstruct(opt.Fresh)
                d = opt.Fresh;
            end
        end
    end%
end%


function [list0, tkn] = query(d, opt)
    classList = opt.ClassList;
    nameFilter = opt.NameFilter;
    nameList = opt.NameList;
    freqFilter = opt.FreqFilter;
    stringList = opt.StringList;
    if isempty(stringList)
        list0 = fieldnames(d).';
    else
        list0 = stringList;
    end
    tkn = cell(size(list0));
    tkn(:) = {{ }};
    % Name list
    if iscellstr(nameList)
        list0 = intersect(list0, nameList);
    end
    % Name filter
    if ~isequal(nameFilter, Inf) && ~isempty(nameFilter)
        if nameFilter(1) ~= '^'
            nameFilter = ['^', nameFilter];
        end
        if nameFilter(end) ~= '$'
            nameFilter = [nameFilter, '$'];
        end
        [inxOfPassed, ~, tkn] = textfun.matchindex(list0, nameFilter);
        list0 = list0(inxOfPassed);
    end
    % Class list.
    if ~isequal(classList, @all) && ~isequal(classList, Inf)
        inxOfPassed = false(size(list0));
        for i = 1 : numel(list0)
            x = d.(list0{i});
            inxOfPassed(i) = any(cellfun(@(cls) isa(x, cls), classList));
        end
        list0 = list0(inxOfPassed);
        tkn = tkn(inxOfPassed);
    end
    % Date frequency filter.
    if ~isequal(freqFilter, Inf)
        inxOfPassed = false(size(list0));
        for i = 1 : numel(list0)
            inxOfPassed(i) = ~isa(d.(list0{i}), 'Series') ...
                || any(freq(d.(list0{i})) == freqFilter);
        end
        list0 = list0(inxOfPassed);
        tkn = tkn(inxOfPassed);
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
end%


function c = parseOne(c, varargin)
    for i = 1 : length(varargin)
        c = strrep(c, sprintf('$.%g', i-1), lower(varargin{i}));
        c = strrep(c, sprintf('$:%g', i-1), upper(varargin{i}));
        c = strrep(c, sprintf('lower($%g)', i-1), lower(varargin{i}));
        c = strrep(c, sprintf('upper($%g)', i-1), upper(varargin{i}));
        c = strrep(c, sprintf('$%g', i-1), varargin{i});
    end
    c = regexprep(c, '\$\d*', '');
end%
