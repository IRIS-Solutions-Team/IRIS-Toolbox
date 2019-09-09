function [outp, flag, listErrors, listWarnings] = dbfun(varargin)
% dbfun  Apply function to databank fields
%
%
% __Syntax__
%
% Input arguments marked with a `~` sign may be omitted.
%
%     [inputDatabanks, Flag, ErrList, WarnList] = dbfun(Func, inputDatabanks, ...)
%     [inputDatabanks, Flag, ErrList, WarnList] = dbfun(Func, inputDatabanks, ~D2, ~D3, ..., ~Dk, ...)
%
%
% __Initialize__
%
% * `Func` [ function_handle | char ] - Function that will be applied to
% each field.
%
% * `inputDatabanks` [ struct ] - Primary input databank whose fields will be processed
% by the function `Func`.
%
% * `~D2`, `~D3`, ... [ struct ] - Secondary input databases whose fields
% will be passed into `Func` (`Func` accepts more than one input argument).
%
%
% __Output Arguments__
%
% * `inputDatabanks` [ struct ] - Output databank whose fields will be created by
% applying `Func` to each field of the input databank or databases.
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
% * `Subdbase=true` [ `true` | `false` ] - Cycle through all sub-databases
% (i.e. struct fields within the input struct), applying the function
% `Func` to their fields, too.
%
% * `ClassFilter=@all` [ cell | cellstr | rexp | `@all` ] - Apply `Func`
% only to databank fields whose class is on the list or matches the regular
% expression; `@all` means all fields in the input databank `inputDatabanks` will be
% processed.
%
% * `Fresh=false` [ `true` | `false` ] - Remove unprocessed entries from
% the output databank.
%
% * `NameList=@all` [ cell | cellstr | rexp | `@all` ] - Apply `Func` only
% to this list of databank field names or names that match this regular
% expression; `@all` means all entries in the input databank `inputDatabanks` wil be
% processed.
%
% * `IfError='Remove'` [ `NaN` | `'Remove'` ] - What to do with the
% databank entry if an error occurs when the entry is being evaluated.
%
% * `IfWarning='Keep'` [ `'Keep'` | `NaN` | `'Remove'` ] - What to do with
% the databank entry if an error occurs when the entry is being evaluated.
%
%
% __Description__
%
%
% __Example__
%
%     d = struct( );
%     d.a = [1, 2];
%     d.b = Series(1:3, @ones);
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

% -IRIS Macroeconomic Modeling Toolbox
% -Copyright (c) 2007-2019 IRIS Solutions Team

inputDatabanks = cell(1, nargin);
[Fn, inputDatabanks{1}, varargin] = irisinp.parser.parse('dbase.dbfun', varargin{:});

% Find last secondary input databank in varargin.
nSecDb = max([ 0, find(cellfun(@isstruct, varargin), 1, 'last') ]);
nDb = nSecDb + 1;
inputDatabanks(1+(1:nSecDb)) = varargin(1:nSecDb);
inputDatabanks(nDb+1:end) = [ ];
varargin(1:nSecDb) = [ ];

[opt, unmatched] = passvalopt('dbase.dbfun', varargin{:});

% `list` is the list of *all* fields in databank `D1`; selected names (to
% be processed) will be stored in `select`.
fieldNames = fieldnames(inputDatabanks{1});
fieldNames = fieldNames(:).';
nField = numel(fieldNames);
X = cell(1, nField);
inxKeep = false(1, nField);

% __Process Subdatabases__
if opt.recursive
    for i = 1 : nField
        name = fieldNames{i};
        if ~isstruct(inputDatabanks{1}.(name))
            continue
        end
        argList = cell(1, nDb);
        for iDb = 1 : nDb
            argList{iDb} = inputDatabanks{iDb}.(name);
        end
        % Cannot pass in opt because it is a struct and would be confused
        % for a secondary input databank.
        X{i} = dbfun(Fn, argList{:}, varargin{:});
        inxKeep(i) = true;
    end
end

%--------------------------------------------------------------------------

listSelect = dbnames(inputDatabanks{1}, unmatched{:});
listErrors = cell(1, nField);
inxErrors = false(1, nField);
listWarnings = cell(1, nField);
inxWarnings = false(1, nField);

% Index of fields to be processed; exclude sub-databases (processed
% earlier) and fields not on the select list.
testFunc = @(field) ~isstruct(inputDatabanks{1}.(field)) ...
                    && any(strcmp(field, listSelect));
inxToProcess = cellfun(testFunc, fieldNames);

for i = find(inxToProcess)
    inxKeep(i) = true;
    try
        fnArgList = cellfun( @(x) x.(fieldNames{i}), inputDatabanks, ...
                             'UniformOutput', false );
        lastwarn('');
        X{i} = feval(Fn, fnArgList{:});
        if ~isempty( lastwarn( ) )
            listWarnings{i} = lastwarn( );
            inxWarnings(i) = true;
        end
    catch Exc
        listErrors{i} = Exc.message;
        inxErrors(i) = true;
    end
end

% Report Matlab errors and warnings
if any(inxWarnings)
    hereReportMatlabWarnings( );
end
flag = ~any(inxErrors);
if any(inxErrors)
    hereReportMatlabErrors( );
end

% Create output databank
if any(inxKeep)    
    if opt.fresh || length(inputDatabanks{1})>1
        % Only processed fields are included.
        outp = cell2struct(X(inxKeep), fieldNames(inxKeep), 2);
    else
        % Keep unprocessed fields in the output databank
        for i = find(inxKeep)
            inputDatabanks{1}.(fieldNames{i}) = X{i};
        end
        outp = inputDatabanks{1};
    end
else
    if opt.fresh || length(inputDatabanks{1})>1
        outp = struct( );
    else
        outp = inputDatabanks{1};
    end
end

return


    function hereReportMatlabErrors( )
        % Throw warnings for Matlab errors.
        errorMessage = cell.empty(1, 0);
        for ii = find(inxErrors)
            errorMessage{end+1} = fieldNames{ii}; %#ok<AGROW>
            errorMessage{end+1} = listErrors{ii}; %#ok<AGROW>
        end
        if isequaln(opt.iferror, NaN) || strcmpi(opt.iferror, 'NaN')
            X(inxErrors) = { NaN };
        else
            inxKeep(inxErrors) = false;
            inputDatabanks{1} = rmfield(inputDatabanks{1}, fieldNames(inxErrors));
        end
        throw( exception.Base('Dbase:DbfunReportError', 'warning'), ...
               errorMessage{:} );
    end%

    
    function hereReportMatlabWarnings( )
        % Throw warnings for Matlab warnings.
        warningMessage = cell.empty(1, 0);
        for ii = find(inxWarnings)
            warningMessage{end+1} = fieldNames{ii}; %#ok<AGROW>
            warningMessage{end+1} = listWarnings{ii}; %#ok<AGROW>
        end
        if isequaln(opt.ifwarning, NaN) || strcmpi(opt.ifwarning, 'NaN')
            X(inxWarnings) = { NaN };
        elseif strcmpi(opt.ifwarning, 'Remove')
            inxKeep(inxWarnings) = false;
        else
            % Do nothing
        end
        throw( exception.Base('Dbase:DbfunReportWarning', 'warning'), ...
               warningMessage{:} );
    end%
end%
