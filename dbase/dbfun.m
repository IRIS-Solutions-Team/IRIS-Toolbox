function [outp, flag, lsError, lsWarning] = dbfun(varargin)
% dbfun  Apply function to database fields.
%
%
% __Syntax__
%
% Input arguments marked with a `~` sign may be omitted.
%
%     [D,Flag,ErrList,WarnList] = dbfun(Func,D,...)
%     [D,Flag,ErrList,WarnList] = dbfun(Func,D,~D2,~D3,...,~Dk,...)
%
%
% __Initialize__
%
% * `Func` [ function_handle | char ] - Function that will be applied to
% each field.
%
% * `D` [ struct ] - Primary input database whose fields will be processed
% by the function `Func`.
%
% * `~D2`, `~D3`, ... [ struct ] - Secondary input databases whose fields
% will be passed into `Func` (`Func` accepts more than one input argument).
%
%
% __Output Arguments__
%
% * `D` [ struct ] - Output database whose fields will be created by
% applying `Func` to each field of the input database or databases.
%
% * `Flag` [ `true` | `false` ] - True if no error occurs when evaluating
% the function.
%
% * `ErrList` [ cellstr ] - List of fields on which the function has thrown
% an error.
%
% * `WarnList` [ cellstr ] - List of fields on which the function has
% thrown a warning.
%
%
% __Options__
%
% * `'Subdbase='` [ *`true`* | `false` ] - Go through all sub-databases
% (i.e. struct fields within the input struct), applying the function
% `Func` to their fields, too.
%
% * `'ClassFilter='` [ cell | cellstr | rexp | *`@all`* ] - Apply `Func`
% only to database fields whose class is on the list or matches the regular
% expression; `@all` means all fields in the input database `D` will be
% processed.
%
% * `'Fresh='` [ `true` | *`false`* ] - Remove unprocessed entries from the
% output database.
%
% * `'NameList='` [ cell | cellstr | rexp | *`@all`* ] - Apply `Func` only
% to this list of database field names or names that match this regular
% expression; `@all` means all entries in the input database `D` wil be
% processed.
%
% * `'IfError='` [ `'NaN'` | *`'remove'`* ] - What to do with the database
% entry if an error occurs when the entry is being evaluated.
%
% * `'IfWarning='` [ *`'keep'`* | `'NaN'` | `'remove'` ] - What to do with
% the database entry if an error occurs when the entry is being evaluated.
%
%
% __Description__
%
%
% __Example__
%
%     d = struct( );
%     d.a = [1, 2];
%     d.b = Series(1:3,@ones);
%     d = dbfun( @(x) 2*x, d)
%
%     d = 
%         a: [2 4]
%         b: [3x1 tseries]
%
%     d.b
%     ans = 
%         tseries object: 3-by-1
%         1:  2
%         2:  2
%         3:  2
%         ''
%         user data: empty
%         export files: [0]
%

% -IRIS Macroeconomic Modeling Toolbox.
% -Copyright (c) 2007-2018 IRIS Solutions Team.

D = cell(1, nargin);
[Fn, D{1}, varargin] = irisinp.parser.parse('dbase.dbfun', varargin{:});

% Find last secondary input database in varargin.
nSecDb = max([ 0, find(cellfun(@isstruct,varargin), 1, 'last') ]);
nDb = nSecDb + 1;
D(1+(1:nSecDb)) = varargin(1:nSecDb);
D(nDb+1:end) = [ ];
varargin(1:nSecDb) = [ ];

opt = passvalopt('dbase.dbfun', varargin{:});

% `list` is the list of *all* fields in database `D1`; selected names (to
% be processed) will be stored in `select`.
lsField = fieldnames(D{1});
lsField = lsField(:).';
nField = numel(lsField);
X = cell(1,nField);
ixKeep = false(1,nField);

% __Process Subdatabases__
if opt.recursive
    for i = 1 : nField
        name = lsField{i};
        if ~isstruct(D{1}.(name))
            continue
        end
        argList = cell(1,nDb);
        for iDb = 1 : nDb
            argList{iDb} = D{iDb}.(name);
        end
        % Cannot pass in opt because it is a struct and would be confused
        % for a secondary input database.
        X{i} = dbfun(Fn, argList{:}, varargin{:});
        ixKeep(i) = true;
    end
end

%--------------------------------------------------------------------------

lsSelect = dbnames( ...
    D{1}, ...
    'classFilter=', opt.classfilter, ...
    'nameFilter=', opt.namefilter ...
);

lsError = cell(1,nField);
ixError = false(1,nField);
lsWarning = cell(1,nField);
ixWarning = false(1,nField);

% Index of fields to be processed; exclude sub-databases (processed
% earlier) and fields not on the select list.
testFunc = @(field) ...
    ~isstruct(D{1}.(field)) ...
    && any( strcmp(field, lsSelect) );
ixProcess = cellfun(testFunc, lsField);

for i = find(ixProcess)
    ixKeep(i) = true;
    try
        fnArgList = cellfun( ...
            @(d) d.(lsField{i}), D, ...
            'UniformOutput', false );
        lastwarn('');
        X{i} = feval(Fn, fnArgList{:});
        if ~isempty( lastwarn( ) )
            lsWarning{i} = lastwarn( );
            ixWarning(i) = true;
        end
    catch Exc
        lsError{i} = Exc.message;
        ixError(i) = true;
    end
end

% Report Matlab errors and warnings.
if any(ixWarning)
    reportMatlabWarnings( );
end
flag = ~any(ixError);
if any(ixError)
    reportMatlabErrors( );
end

% Create output database.
if any(ixKeep)    
    if opt.fresh || length(D{1})>1
        % Only processed fields are included.
        outp = cell2struct(X(ixKeep), lsField(ixKeep), 2);
    else
        % Keep unprocessed fields in the output database.
        for i = find(ixKeep)
            D{1}.(lsField{i}) = X{i};
        end
        outp = D{1};
    end
else
    if opt.fresh || length(D{1})>1
        outp = struct( );
    else
        outp = D{1};
    end
end

return


    function reportMatlabErrors( )
        % Throw warnings for Matlab errors.
        errMsg = { };
        for ii = find(ixError)
            errMsg{end+1} = lsField{ii}; %#ok<AGROW>
            errMsg{end+1} = lsError{ii}; %#ok<AGROW>
            switch lower(opt.iferror)
            end
        end
        if strcmpi(opt.iferror,'nan')
            X(ixError) = { NaN };
        else
            ixKeep(ixError) = false;
            D{1} = rmfield(D{1}, lsField(ixError));
        end
        throw( ...
            exception.Base('Dbase:DbfunReportError', 'warning'), ...
            errMsg{:} ...
        );
    end

    
    function reportMatlabWarnings( )
        % Throw warnings for Matlab warnings.
        warnMsg = { };
        for ii = find(ixWarning)
            warnMsg{end+1} = lsField{ii}; %#ok<AGROW>
            warnMsg{end+1} = lsWarning{ii}; %#ok<AGROW>
            switch lower(opt.ifwarning)
                case 'nan'
                    X{ii} = NaN;
                case 'remove'
                    ixKeep(ii) = false;
                otherwise
                    % Do nothing.
            end
        end
        throw( ...
            exception.Base('Dbase:DbfunReportWarning', 'warning'), ...
            warnMsg{:}...
        );
    end
end
