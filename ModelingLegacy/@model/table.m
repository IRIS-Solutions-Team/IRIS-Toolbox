function outputTable = table(this, requests, varargin)
% table  Extract requested values from model to table
%
% __Syntax__
%
%     OutputTable = table(Model, Request, ...)
%
%
% __Input Arguments__
%
% * `Model` [ model ] - Model object.
%
% * `Requests` [ char | cellstr | string ] - Requested columns for the
% table; see Description for the list of valid requests.
%
% 
% __Output Arguments__
%
% * `OutputTable` [ table ] - Table object with requested values.
%
%
% __Options__
%
% * `Diary=''` [ char | string ] - If `Diary=` is not empty, the table will
% be printed on the screen in the command window, and captured in a text
% file under this file name.
%
% * `Round=Inf` [ `Inf` | numeric ] - Round numeric entries in the table to
% the specified number of digits; `Inf` means no rounding.
%
% * `WriteTable=''` [ char | string ] - If not empty, the table will be
% exported to a text or spreadsheet file (depending on the file extension
% provided) under this file name using the standard `writetable( )`
% function.
%
%
% __Description__
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
%

% -IRIS Macroeconomic Modeling Toolbox
% -Copyright (c) 2007-2018 IRIS Solutions Team

TYPE = @int8;

persistent parser
if isempty(parser)
    parser = extend.InputParser('model.table');
    parser.addRequired('Model', @(x) isa(x, 'model'));
    parser.addRequired('Request', @(x) ischar(x) || iscellstr(x) || isa(x, 'string'));
    parser.addParameter('CompareFirstColumn', true, @(x) isequal(x, true) || isequal(x, false));
    parser.addParameter('Diary', '', @(x) isempty(x) || ischar(x) || (isa(x, 'string') && isscalar(x)));
    parser.addParameter('Round', Inf, @(x) isequal(x, Inf) || (isnumeric(x) && isscalar(x) && x==round(x)));
    parser.addParameter('WriteTable', '', @(x) isempty(x) || ischar(x) || (isa(x, 'string') && isscalar(x)));
end
parser.parse(this, requests, varargin{:});
opt = parser.Options;

if ischar(requests)
    requests = regexp(requests, '\w+', 'match');
else
    requests = cellstr(requests);
end

nv = numel(this.Variant);

%--------------------------------------------------------------------------

numOfRequests = numel(requests);
inxOfShocks = this.Quantity.Type==TYPE(31) | this.Quantity.Type==TYPE(32);

outputTable = table(this.Quantity.Name(:), 'VariableNames', {'Name'});

for i = 1 : numOfRequests

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
        inxOfParameters = this.Quantity.Type==TYPE(4);
        compare = false;
        setNaN = '';
        addTable = tableValues(this, @real, compare, inxOfParameters, setNaN, 'Parameter', opt);


    elseif any(strcmpi(requests{i}, {'CompareParameter', 'CompareParameters'}))
        inxOfParameters = this.Quantity.Type==TYPE(4);
        compare = true;
        setNaN = '';
        addTable = tableValues(this, @real, compare, inxOfParameters, setNaN, 'CompareParameters', opt);


    elseif any(strcmpi(requests{i}, {'Description', 'Descriptions'}))
        addTable = tableDescription(this);


    elseif any(strcmpi(requests{i}, {'Log'}))
        addTable = tableLog(this);


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
    outputTable.Properties.RowNames = outputTable.Name;
    outputTable = removevars(outputTable, 'Name');
end

% Round numeric entries
if ~isinf(opt.Round)
    outputTable = roundTable(outputTable, opt.Round);
end

% Write table to text or spreadsheet file
if ~isempty(opt.WriteTable)
    writeRowNames = ~isempty(outputTable.Properties.RowNames);
    writetable(outputTable, opt.WriteTable, 'WriteRowNames', writeRowNames);
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
    [newKeys, pos1, pos2] = intersect(keys1, keys2, 'stable');
    outputTable = [inputTable1(pos1, :), inputTable2(pos2, 2:end)];
end%


function addTable = tableValues(this, retrieve, compare, inx, setNaN, columnName, opt)
    inxOfLog = this.Quantity.IxLog;
    inxOfLog = inxOfLog(:);
    values = this.Variant.Values;
    values = retrieve(values);
    values = permute(values, [2, 3, 1]);
    if ~isempty(inx)
        inxOfLog = inxOfLog(inx);
        values = values(inx, :);
    end
    if isequal(compare, true)
        values(~inxOfLog, :) = bsxfun(@minus, values(~inxOfLog, :), values(~inxOfLog, 1));
        values(inxOfLog, :) = bsxfun(@rdivide, values(inxOfLog, :), values(inxOfLog, 1));
        if ~opt.CompareFirstColumn
            values(:, 1) = [ ];
        end
    end
    if strcmpi(setNaN, 'log')
        values(inxOfLog, :) = NaN;
    elseif strcmpi(setNaN, 'nonlog')
        values(~inxOfLog, :) = NaN;
    end
    addTable = tableTopic(this, {columnName}, inx, values);
end%


function addTable = tableForm(this)
    inxOfLog = this.Quantity.IxLog;
    inxOfLog = inxOfLog(:);
    values = cell(size(inxOfLog));
    values(~inxOfLog) = {'Diff-'};
    values(inxOfLog) = {'Rate/'};
    addTable = tableTopic(this, {'Form'}, [ ], values);
end%


function addTable = tableDescription(this)
    values = this.Quantity.Label(:);
    addTable = tableTopic(this, {'Description'}, [ ], values);
end%


function addTable = tableLog(this)
    values = this.Quantity.IxLog(:);
    addTable = tableTopic(this, {'Log'}, [ ], values);
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
    numOfShocks = numel(names);
    values = permute( this.Variant.StdCorr(1, 1:numOfShocks, :), [2, 3, 1] );
    if compare
        values = bsxfun(@minus, values, values(:, 1));
    end
    columnNames = {'Name', 'StdDeviation'};
    addTable = table( names, values, ...
                      'VariableNames', columnNames );
end%


function addTable = tableCorr(this, compare, nonzero)
        names = getCorrNames(this.Quantity);
        numOfShocks = nnz(inxOfShocks);
        values = permute( this.Variant.StdCorr(1, numOfShocks+1:end, :), [2, 3, 1] );
        if nonzero
            inxOfNonzero = any(values~=0, 2);
            names = names(inxOfNonzero);
            values = values(inxOfNonzero, :);
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

