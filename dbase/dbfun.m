function [outp, flag, listErrors, listWarnings] = dbfun(func, primary, varargin)
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
%         b: [3x1 Series]
%
%     d.b
%     ans = 
%         Series object: 3-by-1
%         1:  2
%         2:  2
%         3:  2
%         'Dates'    ''
%         User Data: Empty
%

% -IRIS Macroeconomic Modeling Toolbox
% -Copyright (c) 2007-2022 IRIS Solutions Team

% Find last secondary input databank in varargin.
inxDatabanks = cellfun(@validate.databank, varargin);
if all(inxDatabanks)
    numSecondary = numel(varargin);
else
    numSecondary = find(~inxDatabanks, 1) - 1;
end
inputDatabanks = cell(1, 1+numSecondary);
inputDatabanks{1} = primary;
inputDatabanks(2:end) = varargin(1:numSecondary);
varargin(1:numSecondary) = [ ];

persistent parser
if isempty(parser)
    parser = extend.InputParser('dbase.dbfun');
    parser.KeepUnmatched = true;
    addParameter(parser, {'Recursive', 'Cascade'}, true, @validate.logicalScalar);
    addParameter(parser, 'Fresh', false, @validate.logicalScalar);
    addParameter(parser, {'IfError', 'OnError'}, 'Remove', @(x) validate.anyString(x, 'Remove', 'NaN'));
    addParameter(parser, {'IfWarning', 'OnWarning'}, 'Keep', @(x) isequaln(x, NaN) || validate.anyString('Remove', 'Keep', 'NaN'));
end
parse(parser, varargin{:});
opt = parser.Options;
unmatched = parser.UnmatchedInCell;

% `list` is the list of *all* fields in databank `D1`; selected names (to
% be processed) will be stored in `select`.
fieldNames = reshape(fieldnames(inputDatabanks{1}), 1, [ ]);
numFields = numel(fieldNames);
X = cell(1, numFields);
inxKeep = false(1, numFields);

%
% Process nested databanks
%
if opt.Recursive
    for i = 1 : numFields
        name__ = fieldNames{i};
        field__ = inputDatabanks{1}.(name__);
        if ~validate.databank(field__)
            continue
        end
        args = cellfun(@(x) x.(name__), inputDatabanks, 'UniformOutput', false);
        % Cannot pass in opt because it is a struct and would be confused
        % for a secondary input databank.
        X{i} = dbfun(func, args{:}, varargin{:});
        inxKeep(i) = true;
    end
end

%--------------------------------------------------------------------------

listSelect = dbnames(inputDatabanks{1}, unmatched{:});
listErrors = cell(1, numFields);
inxErrors = false(1, numFields);
listWarnings = cell(1, numFields);
inxWarnings = false(1, numFields);

%
% Index of fields to be processed; exclude sub-databases (processed
% earlier) and fields not on the select list
%
testFunc = @(field) ...
    ~validate.databank(inputDatabanks{1}.(char(field))) ...
    && any(strcmp(field, listSelect));
inxToProcess = cellfun(testFunc, fieldNames);

for i = find(inxToProcess)
    inxKeep(i) = true;
    try
        fnArgList = cellfun( ...
            @(x) x.(fieldNames{i}), inputDatabanks, ...
            'UniformOutput', false ...    
        );
        lastwarn('');
        X{i} = feval(func, fnArgList{:});
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

%
% Create output databank
%
if any(inxKeep)    
    if opt.Fresh || numel(inputDatabanks{1})>1
        % Only processed fields are included
        outp = cell2struct(X(inxKeep), cellstr(fieldNames(inxKeep)), 2);
    else
        % Keep unprocessed fields in the output databank
        for i = find(inxKeep)
            inputDatabanks{1}.(fieldNames{i}) = X{i};
        end
        outp = inputDatabanks{1};
    end
else
    if opt.Fresh || length(inputDatabanks{1})>1
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
        if isequaln(opt.IfError, NaN) || strcmpi(opt.IfError, 'NaN')
            X(inxErrors) = { NaN };
        else
            inxKeep(inxErrors) = false;
            inputDatabanks{1} = rmfield(inputDatabanks{1}, fieldNames(inxErrors));
        end
        throw( ...
            exception.Base('Dbase:DbfunReportError', 'warning'), ...
            errorMessage{:} ...
        );
    end%

    
    function hereReportMatlabWarnings( )
        % Throw warnings for Matlab warnings.
        warningMessage = cell.empty(1, 0);
        for ii = find(inxWarnings)
            warningMessage{end+1} = fieldNames{ii}; %#ok<AGROW>
            warningMessage{end+1} = listWarnings{ii}; %#ok<AGROW>
        end
        if isequaln(opt.IfWarning, NaN) || strcmpi(opt.IfWarning, 'NaN')
            X(inxWarnings) = { NaN };
        elseif strcmpi(opt.IfWarning, 'Remove')
            inxKeep(inxWarnings) = false;
        else
            % Do nothing
        end
        throw( ...
            exception.Base('Dbase:DbfunReportWarning', 'warning'), ...
            warningMessage{:} ...
        );
    end%
end%
