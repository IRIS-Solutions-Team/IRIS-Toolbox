function outputTable = table(this, requests, varargin)
% table  Create table based on selected indicators from Model object 
%{
% Syntax
%--------------------------------------------------------------------------
%
%
%     outputTable = table(model, request, ...)
%
%
% Input Arguments
%--------------------------------------------------------------------------
%
%
% __`model`__ [ Model ] 
%
%     Model object based on which the table will be prepared.
%
%
% __`requests`__ [ char | cellstr | string ] 
% 
%     Requested columns for the table; see Description for the list of
%     valid requests.
%
% 
% Output Arguments
%--------------------------------------------------------------------------
%
%
% __`outputTable`__ [ table ]
% 
%     Table object with requested values.
%
%
% Options
%--------------------------------------------------------------------------
%
%
% __`CompareFirstColumn=true`__ [ `true` | `false` ] 
% 
%     Include the first column in comparison tables (first column compares
%     itself with itself).
%
%
% __`Diary=''`__ [ char | string ] 
%
%     If `Diary=` is not empty, the table will be printed on the screen in
%     the command window, and captured in a text file under this file name.
%
%
% __`SelectNames=false`__ [ `false` | string ]
% 
%     Select only a subset of names (variables, shocks, parameters) to be
%     included in the `outputTable`.
%
%
% __`Sort=false`__ [ `true` | `false` ] 
%
%     If `true` sort the table rows alphabetically by the row names.
%
%
% __`Round=Inf`__ [ `Inf` | numeric ] 
%
%     Round numeric entries in the table to the specified number of digits;
%     `Inf` means no rounding.
%
%
% __`WriteTable=''`__ [ char | string ] 
%
%     If not empty, the table will be exported to a text or spreadsheet
%     file (depending on the file extension provided) under this file name
%     using the standard `writetable( )` function.
%
%
% Description
%--------------------------------------------------------------------------
%
%
% This is the list of valid requests that can be combined in one call of
% the `table(~)` function:
%
% * `'SteadyLevel'` - Steady-state level for each model variable.
%
% * `'SteadyChange'` - Steady-state difference (for nonlog-variables) or
% steady-state gross rate of change (for log-variables) for each model
% variables.
%
% * `'SteadyDiff'` - Steady-state difference for each model variable not
% declared as log-variables; `NaN` for log-variables.
%
% * `'SteadyRate'` - Steady-state gross rate of growth for each model
% variable declared as log-variables; `NaN` for nonlog-variables.
%
% * `'Form'` - Indicator of the form in which steady-state change and/or
% comparison are reported for each model variable: `'Diff-'` (meaning a
% first difference when reporting steady-state growth, or a difference
% between two steady states when reporting steady-state comparison) for
% each nonlog-variable, and `'Rate/'` for each log-variable.
%
% * `'CompareSteadyLevel'` - Steady-state level for each model variable
% compared to the first parameter variant (a difference for each
% nonlog-variable, a ratio for each log-variable).
%
% * `'CompareSteadyChange'` - Steady-state difference (for
% nonlog-variables) or steady-state gross rate of change (for
% log-variables) for each model variables compared to the first parameter
% variant (a difference for each nonlog-variable, a ratio for each
% log-variable).
%
% * `'CompareSteadyDiff'` - Steady-state difference for each model variable
% not declared as log-variables, compared to the first parameter variant;
% `NaN` for log-variables.
%
% * `'SteadyRate'` - Steady-state gross rate of growth for each model
% variable declared as log-variables, compared to the first parameter
% variant; `NaN` for nonlog-variables.
%
% * `'Description'` - Description text from the model file.
%
% * `'Log'` - Indicator of log-variables: `true` for each model variable
% declared as a log-variable, `false` otherwise.
%
% This is the list of valid requests that can be called individually:
%
% * `'Parameters'` - The currently assigned value for each parameter; this
% request can be combined with `'Description'`.
%
% * `'Stationary'` - Indicator of stationarity of variables or log
% variables.
%
% * `'Std'` - The currently assigned value for the standard deviation of
% each model shock.
%
% * `'Corr'` - The currently assigned value for the cross-correlation
% coefficient of each pair of model shocks.
%
% * `'CompareParameters'` - The currently assigned value for each parameter
% compared to the first parameter variant (a difference); this request can
% be combined with `'Description'`.
%
% * `'CompareStd'` - The currently assigned value for the standard
% deviation of each model shock compared to the first parameter variant (a
% difference).
%
% * `'CompareCorr'` - The currently assigned value for the cross-correlation
% coefficient of each pair of model shocks compared to the first parameter
% variant (a difference).
%
% * `'AllRoots'` - All eigenvalues associated with the current solution.
%
% * `'StableRoots'` - All stable eigenvalues (smaller than `1` in
% magnitude) associated with the current solution.
%
% * `'UnitRoots'` - All unit eigenvalues (equal `1` in magnitude)
% associated with the current solution.
%
% * `'UnstableRoots'` - All unstable eigenvalues (greater than `1` in
% magnitude) associated with the current solution.
%
%
% __Example__
%
%}

% -[IrisToolbox] for Macroeconomic Modeling
% -Copyright (c) 2007-2020 [IrisToolbox] Solutions Team

TYPE = @int8;

%( Input parser
persistent pp
if isempty(pp)
    pp = extend.InputParser('@Model/table');

    addRequired(pp, 'model', @(x) isa(x, 'Model'));
    addRequired(pp, 'request', @(x) ischar(x) || iscellstr(x) || isa(x, 'string'));
    
    addParameter(pp, 'CompareFirstColumn', true, @(x) isequal(x, true) || isequal(x, false));
    addParameter(pp, 'Diary', '', @(x) isempty(x) || ischar(x) || (isa(x, 'string') && isscalar(x)));
    addParameter(pp, 'Round', Inf, @(x) isequal(x, Inf) || (isnumeric(x) && isscalar(x) && x==round(x)));
    addParameter(pp, 'SelectRows', false, @(x) isequal(x, false) || validate.list(x));
    addParameter(pp, {'SortAlphabetically', 'Sort'}, false, @(x) isequal(x, true) || isequal(x, false));
    addParameter(pp, 'WriteTable', '', @locallyValidateWriteTable); % @(x) isempty(x) || ischar(x) || (isa(x, 'string') && isscalar(x)));
end
%)
opt = parse(pp, this, requests, varargin{:});

if ischar(requests)
    requests = regexp(requests, '\w+', 'match');
else
    requests = cellstr(requests);
end

nv = numel(this.Variant);

%--------------------------------------------------------------------------

numRequests = numel(requests);
inxShocks = getIndexByType(this.Quantity, TYPE(31), TYPE(32));

outputTable = table(this.Quantity.Name(:), 'VariableNames', {'Name'});

for i = 1 : numRequests
    if any(strcmpi(requests{i}, {'SteadyLevel', 'SteadyLevels'}))
        compare = false;
        addTable = tableValues(this, @real, compare, [ ], '', 'SteadyLevel', opt);


    elseif any(strcmpi(requests{i}, {'CompareSteadyLevel', 'CompareSteadyLevels'}))
        compare = true;
        addTable = tableValues(this, @real, compare, [ ], '', 'CompareSteadyLevel', opt);

        
    elseif any(strcmpi(requests{i}, {'SteadyChange', 'SteadyChanges'}))
        compare = false;
        addTable = tableValues(this, @imag, compare, [ ], '', 'SteadyChange', opt);


    elseif any(strcmpi(requests{i}, {'CompareSteadyChange', 'CompareSteadyChanges'}))
        compare = true;
        addTable = tableValues(this, @imag, compare, [ ], '', 'CompareSteadyChange', opt);

        
    elseif any(strcmpi(requests{i}, {'SteadyDiff', 'SteadyDiffs'}))
        compare = false;
        setNaN = 'log';
        addTable = tableValues(this, @imag, compare, [ ], setNaN, 'SteadyDiff', opt);


    elseif any(strcmpi(requests{i}, {'CompareSteadyDiff', 'CompareSteadyDiffs'}))
        compare = true;
        setNaN = 'log';
        addTable = tableValues(this, @imag, compare, [ ], setNaN, 'CompareSteadyDiff', opt);

        
    elseif strcmpi(requests{i}, 'SteadyRate')
        compare = false;
        setNaN = 'nonlog';
        addTable = tableValues(this, @imag, compare, [ ], setNaN, 'SteadyRate', opt);


    elseif strcmpi(requests{i}, 'CompareSteadyRate')
        compare = true;
        setNaN = 'nonlog';
        addTable = tableValues(this, @imag, compare, [ ], setNaN, 'CompareSteadyRate', opt);


    elseif strcmpi(requests{i}, 'Form')
        addTable = tableForm(this);


    elseif any(strcmpi(requests{i}, {'Parameter', 'Parameters'}))
        inxParameters = this.Quantity.Type==TYPE(4);
        compare = false;
        setNaN = '';
        addTable = tableValues(this, @real, compare, inxParameters, setNaN, 'Parameter', opt);


    elseif any(strcmpi(requests{i}, {'CompareParameter', 'CompareParameters'}))
        inxParameters = this.Quantity.Type==TYPE(4);
        compare = true;
        setNaN = '';
        addTable = tableValues(this, @real, compare, inxParameters, setNaN, 'CompareParameters', opt);


    elseif any(strcmpi(requests{i}, {'Description', 'Descriptions'}))
        addTable = tableDescription(this);


    elseif any(strcmpi(requests{i}, {'Log'}))
        addTable = tableLog(this);


    elseif any(strcmpi(requests{i}, {'Stationary'}))
        addTable = tableStationary(this);


    elseif any(strcmpi(requests{i}, {'Std', 'StdDeviation', 'StdDeviations'}))
        compare = false;
        outputTable = tableStd(this, compare);
        break

    elseif any(strcmpi(requests{i}, {'CompareStd', 'CompareStdDeviation', 'CompareStdDeviations'}))
        compare = true;
        outputTable = tableStd(this, compare);
        break


    elseif any(strcmpi(requests{i}, {'Corr', 'CorrCoeff', 'CorrCoeffs'}))
        nonzero = false;
        compare = false;
        outputTable = tableCorr(this, nonzero, compare);
        break


    elseif any(strcmpi(requests{i}, {'NonzeroCorr', 'NonzeroCorrCoeff', 'NonzeroCorrCoeffs'}))
        nonzero = true;
        compare = false;
        outputTable = tableCorr(this, nonzero, compare);
        break


    elseif any(strcmpi(requests{i}, {'CompareCorr', 'CompareCorrCoeff', 'CompareCorrCoeffs'}))
        nonzero = false;
        compare = true;
        outputTable = tableCorr(this, nonzero, compare);
        break


    elseif any(strcmpi(requests{i}, {'CompareNonzeroCorr', 'CompareNonzeroCorrCoeff', 'CompareNonzeroCorrCoeffs'}))
        nonzero = true;
        compare = true;
        outputTable = tableCorr(this, nonzero, compare);
        break


    elseif any(strcmpi(requests{i}, {'Roots', 'AllRoots', 'EigenValues', 'AllEigenValues'}))
        values = get(this, 'Roots');
        values = values(:);
        outputTable = table( values, abs(values), ...
                             'VariableNames', {'AllRoots', 'Magnitudes'} );
        break


    elseif any(strcmpi(requests{i}, {'StableRoots', 'StableEigenValues'}))
        values = get(this, 'StableRoots');
        values = values(:);
        outputTable = table( values, abs(values), ...
                             'VariableNames', {'StableRoots', 'Magnitudes'} );
        break


    elseif any(strcmpi(requests{i}, {'UnstableRoots', 'UnstableEigenValues'}))
        values = get(this, 'UnstableRoots');
        values = values(:);
        outputTable = table( values, abs(values), ...
                             'VariableNames', {'UnstableRoots', 'Magnitudes'} );
        break


    elseif any(strcmpi(requests{i}, {'UnitRoots', 'UnitEigenValues'}))
        values = get(this, 'UnitRoots');
        values = values(:);
        outputTable = table( values, abs(values), ...
                             'VariableNames', {'UnitRoots', 'Magnitudes'} );
        break


    else
        throw( exception.Base('Model:TableInvalidRequest', 'error'), ...
               requests{i} );
    end

    if i==1
        outputTable = addTable;
    else
        outputTable = innerjoin(outputTable, addTable);
    end
end

if any(strcmp(outputTable.Properties.VariableNames, 'Name'))
    tempNames = outputTable.Name;
    try
        outputTable = removevars(outputTable, 'Name');
        outputTable.Properties.RowNames = tempNames;
    end
end

% Select rows
if ~isequal(opt.SelectRows, false)
    outputTable = outputTable(string(opt.SelectRows), :);
end

% Sort table rows alphabetically
if opt.SortAlphabetically
    outputTable = sortrows(outputTable, 'RowNames');
end

% Round numeric entries
if ~isinf(opt.Round)
    outputTable = roundTable(outputTable, opt.Round);
end


% 
% Write table to file
%
if ~isempty(opt.WriteTable) && ~isequal(opt.WriteTable, false)
    locallyWriteTable(outputTable, opt.WriteTable)
end


% Print table to screen and capture output in diary
if ~isempty(opt.Diary)
    if exist(opt.Diary, 'file')==2
        delete(opt.Diary);
    end
    diary(opt.Diary);
    disp(outputTable);
    diary off;
end

end%


%
% Local Functions
%


function outputTable = innerjoin(inputTable1, inputTable2)
    keys1 = inputTable1{:, 1};
    keys2 = inputTable2{:, 1};
    [~, pos1, pos2] = intersect(keys1, keys2, 'stable');
    outputTable = [inputTable1(pos1, :), inputTable2(pos2, 2:end)];
end%


function addTable = tableValues(this, retrieve, compare, inx, setNaN, columnName, opt)
    inxLog = this.Quantity.IxLog;
    inxLog = inxLog(:);
    values = this.Variant.Values;
    values = retrieve(values);
    values = permute(values, [2, 3, 1]);
    if ~isempty(inx)
        inxLog = inxLog(inx);
        values = values(inx, :);
    end
    if isequal(compare, true)
        values(~inxLog, :) = bsxfun(@minus, values(~inxLog, :), values(~inxLog, 1));
        values(inxLog, :) = bsxfun(@rdivide, values(inxLog, :), values(inxLog, 1));
        if ~opt.CompareFirstColumn
            values(:, 1) = [ ];
        end
    end
    if strcmpi(setNaN, 'log')
        values(inxLog, :) = NaN;
    elseif strcmpi(setNaN, 'nonlog')
        values(~inxLog, :) = NaN;
    end
    addTable = tableTopic(this, {columnName}, inx, values);
end%


function addTable = tableForm(this)
    inxLog = this.Quantity.IxLog;
    inxLog = inxLog(:);
    values = repmat("", numel(inxLog), 1);
    values(~inxLog) = "Diff-";
    values(inxLog) = "Rate/";
    addTable = tableTopic(this, {'Form'}, [ ], values);
end%


function addTable = tableDescription(this)
    values = this.Quantity.Label(:);
    values = string(values);
    addTable = tableTopic(this, {'Description'}, [ ], values);
end%


function addTable = tableLog(this)
    values = this.Quantity.IxLog(:);
    addTable = tableTopic(this, {'Log'}, [ ], values);
end%


function addTable = tableStationary(this)
    TYPE = @int8;
    inx = getIndexByType(this, TYPE(1), TYPE(2));
    names = this.Quantity.Name(inx);
    numNames = numel(names);
    temp = get(this, 'Stationary');
    values = true(numNames, 1);
    for i = 1 : numNames
        values(i) = temp.(names{i});
    end
    addTable = tableTopic(this, {'Stationary'}, inx, values);
end%


function addTable = tableTopic(this, columnNames, inx, varargin)
    names = this.Quantity.Name(:);
    if ~isempty(inx)
        names = names(inx);
    end
    columnNames = [{'Name'}, columnNames];
    addTable = table( names, varargin{:}, ...
                      'VariableNames', columnNames );
end%


function addTable = tableStd(this, compare)
    names = getStdNames(this.Quantity);
    names = names(:);
    numShocks = numel(names);
    values = permute( this.Variant.StdCorr(1, 1:numShocks, :), [2, 3, 1] );
    if compare
        values = bsxfun(@minus, values, values(:, 1));
    end
    columnNames = {'Name', 'StdDeviation'};
    addTable = table( names, values, ...
                      'VariableNames', columnNames );
end%


function addTable = tableCorr(this, compare, nonzero)
        names = getCorrNames(this.Quantity);
        numShocks = nnz(inxShocks);
        values = permute( this.Variant.StdCorr(1, numShocks+1:end, :), [2, 3, 1] );
        if nonzero
            inxNonzero = any(values~=0, 2);
            names = names(inxNonzero);
            values = values(inxNonzero, :);
        end
        if compare
            values = bsxfun(@minus, values, values(:, 1));
        end
        addTable = table( names, values, ...
                          'VariableNames', {'Names', 'CorrValues'} );
end%


function outputTable = roundTable(outputTable, decimals)
    list = outputTable.Properties.VariableNames;
    for i = 1 : numel(list)
        name = list{i};
        x = outputTable.(name);
        if ~isnumeric(x)
            continue
        end
        x = round(x, decimals);
        outputTable.(name) = x;
    end
end%


function flag = locallyValidateWriteTable(x)
    if isempty(x) || isequal(x, false)
        flag = true;
        return
    end
    if validate.stringScalar(x)
        flag = true;
        return
    end
    if iscell(x) && validate.stringScalar(x{1}) && iscellstr(x(2:2:end))
        flag = true;
        return
    end
    flag = false;
end%


function locallyWriteTable(table, writeTableOpt)
% Write table to text or spreadsheet file
    if iscell(writeTableOpt)
        fileName = writeTableOpt{1};
        writeTableOpt = writeTableOpt(2:end);
        writeTableOpt(1:2:end) = replace(writeTableOpt(1:2:end), '=', '');
    else
        fileName = writeTableOpt;
        writeTableOpt = cell.empty(1, 0);
    end
    writeRowNames = ~isempty(table.Properties.RowNames);
    [~, ~, ext] = fileparts(fileName);
    if startsWith(lower(ext), 'xls')
        writeMode = 'OverwriteSheet';
    else
        writeMode = 'Overwrite';
    end
    try
        writetable( ...
            table, fileName ...
            , 'WriteRowNames', writeRowNames ...
            , 'WriteMode', writeMode ...
            , writeTableOpt{:} ...
        );
    catch
        writetable( ...
            table, fileName ...
            , 'WriteRowNames', writeRowNames ...
            , writeTableOpt{:} ...
        );
    end
end%

