%{
% 
% # `table` ^^(Model)^^
% 
% {== Create table based on selected indicators from Model object ==}
% 
% 
% ## Syntax
% 
% 
%     outputTable = table(model, request, ...)
% 
% 
% ## Input arguments
% 
% __`model`__ [ Model ] 
% > 
% > Model object based on which the table will be prepared.
% > 
% 
% __`requests`__ [ char | cellstr | string ] 
% > 
% > Requested columns for the table; see Description for the list of
% > valid requests.
% > 
% 
% ## Output arguments
% 
% __`outputTable`__ [ table ]
% > 
% > Table object with requested values.
% > 
% 
% ## Options
% 
% __`CompareFirstColumn=true`__ [ `true` | `false` ] 
% > 
% > Include the first column in comparison tables (first column compares
% > itself with itself).
% > 
% 
% __`Diary=""`__ [ string ] 
% > 
% > If `Diary=` is not empty, the table will be printed on the screen in
% > the command window, and captured in a text file under this file name.
% > 
% 
% __`SelectRows=false`__ [ `false` | string ]
% > 
% > Select only a subset of rows (names of variables, shocks and/or
% > parameters) to be included in the `outputTable`.
% > 
% 
% __`Sort=false`__ [ `true` | `false` ] 
% > 
% > If `true` sort the table rows alphabetically by the row names.
% > 
% 
% __`Round=Inf`__ [ `Inf` | numeric ] 
% > 
% > Round numeric entries in the table to the specified number of digits;
% > `Inf` means no rounding.
% > 
% 
% __`WriteTable=""`__ [ string | cell ] 
% > 
% > If non-empty, the table will be exported to a text or spreadsheet
% > file (depending on the file extension provided) under this file name
% > using the standard `writetable( )` function;
% > 
% 
% ##  Description
% 
% This is the list of valid requests that can be combined in one call of
% the `table()` function:
% 
% * `"SteadyLevel"` - Steady-state level for each model variable.
% 
% * `"SteadyChange"` - Steady-state difference (for nonlog-variables) or
% steady-state gross rate of change (for log-variables) for each model
% variables.
% 
% * `"SteadyDiff"` - Steady-state difference for each model variable not
% declared as log-variables; `NaN` for log-variables.
% 
% * `"SteadyRate"` - Steady-state gross rate of growth for each model
% variable declared as log-variables; `NaN` for nonlog-variables.
% 
% * `"Form"` - Indicator of the form in which steady-state change and/or
% comparison are reported for each model variable: `"Diff-"` (meaning a
% first difference when reporting steady-state growth, or a difference
% between two steady states when reporting steady-state comparison) for
% each nonlog-variable, and `"Rate/"` for each log-variable.
% 
% * `"CompareSteadyLevel"` - Steady-state level for each model variable
% compared to the first parameter variant (a difference for each
% nonlog-variable, a ratio for each log-variable).
% 
% * `"CompareSteadyChange"` - Steady-state difference (for
% nonlog-variables) or steady-state gross rate of change (for
% log-variables) for each model variables compared to the first parameter
% variant (a difference for each nonlog-variable, a ratio for each
% log-variable).
% 
% * `"CompareSteadyDiff"` - Steady-state difference for each model variable
% not declared as log-variables, compared to the first parameter variant;
% `NaN` for log-variables.
% 
% * `"SteadyRate"` - Steady-state gross rate of growth for each model
% variable declared as log-variables, compared to the first parameter
% variant; `NaN` for nonlog-variables.
% 
% * `"Description"` - Description text from the model file (quoted text
%   preceding the name in a declaration section).
% 
% * `"Alias"` - Alias text from the model file (the part of the quoted text
%   preceding the name in a declaration section that follows after a double
%   exclamation mark).
% 
% * `"Log"` - Indicator of log-variables: `true` for each model variable
% declared as a log-variable, `false` otherwise.
% 
% This is the list of valid requests that can be called individually:
% 
% * `"Parameters"` - The currently assigned value for each parameter; this
% request can be combined with `"Description"`.
% 
% * `"Stationary"` - Indicator of stationarity of variables or log
% variables.
% 
% * `"Std"` - The currently assigned value for the standard deviation of
% each model shock.
% 
% * `"Corr"` - The currently assigned value for the cross-correlation
% coefficient of each pair of model shocks.
% 
% * `"CompareParameters"` - The currently assigned value for each parameter
% compared to the first parameter variant (a difference); this request can
% be combined with `"Description"`.
% 
% * `"CompareStd"` - The currently assigned value for the standard
% deviation of each model shock compared to the first parameter variant (a
% difference).
% 
% * `"CompareCorr"` - The currently assigned value for the cross-correlation
% coefficient of each pair of model shocks compared to the first parameter
% variant (a difference).
% 
% * `"AllRoots"` - All eigenvalues associated with the current solution.
% 
% * `"StableRoots"` - All stable eigenvalues (smaller than `1` in
% magnitude) associated with the current solution.
% 
% * `"UnitRoots"` - All unit eigenvalues (equal `1` in magnitude)
% associated with the current solution.
% 
% * `"UnstableRoots"` - All unstable eigenvalues (greater than `1` in
% magnitude) associated with the current solution.
% 
% 
% ## Examples
% 
% ### Plain vanilla table
% 
% Create table with a steady state summary:
% 
% ```matlab
% table(m, ["steadyLevel", "steadyChange", "form", "description"])
% ```
% 
% 
% ### Save table to spreadsheet
% 
% Create the same table as before, and save it to an Excel spreadsheet file:
% 
% ```matlab
% table( ...
%     m, ["steadyLevel", "steadyChange", "form", "description"] ...
%     writeTable="steadyState.xls" ...
% )
% ```
% 
%}
% --8<--


% -[IrisToolbox] for Macroeconomic Modeling
% -Copyright (c) 2007-2022 [IrisToolbox] Solutions Team

% >=R2019b
%{
function outputTable = table(this, requests, opt)

arguments
    this Model
    requests (1, :) string {validate.mustBeText}

    opt.CompareFirstColumn (1, 1) logical = false
    opt.Diary (1, 1) string = ""
    opt.Round (1, 1) double = Inf
    opt.SelectRows = false
    opt.SortAlphabetically (1, 1) logical = false
    opt.WriteTable (1, :) string = ""
    opt.NonstationaryLevel (1, 1) logical = true
    opt.Title (1, :) string = string.empty(1, 0)
end
%}
% >=R2019b


% <=R2019a
%(
function outputTable = table(this, requests, varargin)

persistent ip
if isempty(ip)
    ip = inputParser();
    addParameter(ip, "CompareFirstColumn", false);
    addParameter(ip, "Diary", "");
    addParameter(ip, "Round", Inf);
    addParameter(ip, "SelectRows", false);
    addParameter(ip, "SortAlphabetically", false);
    addParameter(ip, "WriteTable", "");
    addParameter(ip, "NonstationaryLevel", true);
    addParameter(ip, "Title", string.empty(1, 0));
end
parse(ip, varargin{:});
opt = ip.Results;
%)
% <=R2019a


requests = reshape(string(requests), 1, []);
numRequests = numel(requests);

outputTable = table(this.Quantity.Name(:), 'VariableNames', {'Name'});

isFirstRequest = true;
for n = requests
    n = erase(n, "-");

    if lower(n)==lower("steady")
        compare = false;
        addTable = tableValues(this, @(x)x, compare, [ ], '', 'Steady', opt);


    elseif any(strcmpi(n, {'SteadyLevel', 'SteadyLevels'}))
        compare = false;
        addTable = tableValues(this, @real, compare, [ ], '', 'SteadyLevel', opt);


    elseif any(strcmpi(n, {'CompareSteadyLevel', 'CompareSteadyLevels'}))
        compare = true;
        addTable = tableValues(this, @real, compare, [ ], '', 'CompareSteadyLevel', opt);


    elseif any(strcmpi(n, {'SteadyChange', 'SteadyChanges'}))
        compare = false;
        setNaN = []; %~getIndexByType(this.Quantity, 1, 2, 5);
        addTable = tableValues(this, @imag, compare, [], setNaN, 'SteadyChange', opt);


    elseif any(strcmpi(n, {'CompareSteadyChange', 'CompareSteadyChanges'}))
        compare = true;
        addTable = tableValues(this, @imag, compare, [ ], '', 'CompareSteadyChange', opt);

        
    elseif any(strcmpi(n, {'SteadyDiff', 'SteadyDiffs'}))
        compare = false;
        setNaN = []; % 'log';
        addTable = tableValues(this, @imag, compare, [ ], setNaN, 'SteadyDiff', opt);


    elseif any(strcmpi(n, {'CompareSteadyDiff', 'CompareSteadyDiffs'}))
        compare = true;
        setNaN = 'log';
        addTable = tableValues(this, @imag, compare, [ ], setNaN, 'CompareSteadyDiff', opt);

        
    elseif strcmpi(n, 'SteadyRate')
        compare = false;
        setNaN = 'nonlog';
        addTable = tableValues(this, @imag, compare, [ ], setNaN, 'SteadyRate', opt);


    elseif strcmpi(n, 'CompareSteadyRate')
        compare = true;
        setNaN = 'nonlog';
        addTable = tableValues(this, @imag, compare, [ ], setNaN, 'CompareSteadyRate', opt);


    elseif strcmpi(n, 'Form')
        addTable = tableForm(this);


    elseif lower(string(n))=="position"
        addTable = tablePosition(this);


    elseif any(strcmpi(n, {'Parameter', 'Parameters'}))
        inxParameters = this.Quantity.Type==4;
        compare = false;
        setNaN = '';
        addTable = tableValues(this, @real, compare, inxParameters, setNaN, 'Parameter', opt);


    elseif any(strcmpi(n, {'CompareParameter', 'CompareParameters'}))
        inxParameters = this.Quantity.Type==4;
        compare = true;
        setNaN = '';
        addTable = tableValues(this, @real, compare, inxParameters, setNaN, 'CompareParameters', opt);


    elseif startsWith(n, "description", "ignoreCase", true);
        addTable = tableDescription(this);


    elseif startsWith(n, "alias", "ignoreCase", true);
        addTable = tableAlias(this);


    elseif any(strcmpi(n, {'Log', 'LogStatus'}))
        addTable = tableLog(this);


    elseif any(strcmpi(n, {'Stationary'}))
        addTable = tableStationary(this);


    elseif any(strcmpi(n, {'Std', 'StdDeviation', 'StdDeviations'}))
        compare = false;
        outputTable = tableStd(this, compare);
        break

    elseif any(strcmpi(n, {'CompareStd', 'CompareStdDeviation', 'CompareStdDeviations'}))
        compare = true;
        outputTable = tableStd(this, compare);
        break


    elseif any(strcmpi(n, {'Corr', 'CorrCoeff', 'CorrCoeffs'}))
        nonzero = false;
        compare = false;
        outputTable = tableCorr(this, nonzero, compare);
        break


    elseif any(strcmpi(n, {'NonzeroCorr', 'NonzeroCorrCoeff', 'NonzeroCorrCoeffs'}))
        nonzero = true;
        compare = false;
        outputTable = tableCorr(this, nonzero, compare);
        break


    elseif any(strcmpi(n, {'CompareCorr', 'CompareCorrCoeff', 'CompareCorrCoeffs'}))
        nonzero = false;
        compare = true;
        outputTable = tableCorr(this, nonzero, compare);
        break


    elseif any(strcmpi(n, {'CompareNonzeroCorr', 'CompareNonzeroCorrCoeff', 'CompareNonzeroCorrCoeffs'}))
        nonzero = true;
        compare = true;
        outputTable = tableCorr(this, nonzero, compare);
        break


    elseif any(strcmpi(n, {'Roots', 'AllRoots', 'EigenValues', 'AllEigenValues'}))
        values = get(this, 'Roots');
        values = values(:);
        outputTable = table( ...
            values, abs(values), angle(values) ...
            , 'variableNames', {'Eigenvalue', 'Magnitude', 'Angle'} ...
        );
        break


    elseif any(strcmpi(n, {'StableRoots', 'StableEigenValues'}))
        values = get(this, 'StableRoots');
        values = values(:);
        outputTable = table( ...
            values, abs(values), angle(values) ...
            , 'variableNames', {'StableRoot', 'Magnitude', 'Angle'} ...
        );
        break


    elseif any(strcmpi(n, {'UnstableRoots', 'UnstableEigenValues'}))
        values = get(this, 'UnstableRoots');
        values = values(:);
        outputTable = table( ...
            values, abs(values), angle(values) ...
            , 'variableNames', {'UnstableRoot', 'Magnitude', 'Angle'} ...
        );
        break


    elseif any(strcmpi(n, {'UnitRoots', 'UnitEigenValues'}))
        values = get(this, 'UnitRoots');
        values = values(:);
        outputTable = table( ...
            values, abs(values), angle(values) ...
            , 'VariableNames', {'UnitRoot', 'Magnitude', 'Angle'} ...
        );
        break


    else
        throw(exception.Base('Model:TableInvalidRequest', 'error'), n);
    end

    if isFirstRequest
        outputTable = addTable;
        isFirstRequest = false;
    else
        outputTable = innerjoin(outputTable, addTable);
    end
end

if any(strcmp(outputTable.Properties.VariableNames, 'Name'))
    tempNames = outputTable.Name;
    try %#ok<TRYNC>
        outputTable = removevars(outputTable, 'Name');
        outputTable.Properties.RowNames = tempNames;
    end
end

% Select rows
if ~isequal(opt.SelectRows, false)
    selectRows = textual.stringify(opt.SelectRows);
    while true
        pos = find(startsWith(selectRows, ":"), 1);
        if isempty(pos)
            break
        end
        selectRows = [selectRows(1:pos-1), byAttributes(this, selectRows(pos)), selectRows(pos+1:end)];
    end
    outputTable = outputTable(selectRows, :);
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
% Table description (title)
%
try
    outputTable.Properties.Description = join(opt.Title, newline());
catch
    % Make it work for older Matlab versions too
    if isempty(opt.Title)
        description = '';
    else
        description = char(join(opt.Title, ' // '));
    end
    outputTable.Properties.Description = description;
end


% 
% Write table to file
%
if (iscell(opt.WriteTable) && ~isempty(opt.WriteTable)) || any(strlength(opt.WriteTable)>0)
    locallyWriteTable(outputTable, opt.WriteTable);
end


%
% Print table to screen and capture output in diary
%
if strlength(opt.Diary)>0
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
    
    if ~opt.NonstationaryLevel && ~contains(columnName, "change", "ignoreCase", true)
        stationaryStatus = getStationaryStatus(this, true);
        realValues = real(values);
        imagValues = imag(values);
        realValues(stationaryStatus==0, :) = NaN;
        values = realValues;
        if any(imagValues~=0)
            values = values + 1i*imagValues;
        end
    end

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
    if islogical(setNaN)
        values(setNaN, :) = NaN;
    elseif strcmpi(setNaN, 'log')
        values(inxLog, :) = NaN;
    elseif strcmpi(setNaN, 'nonlog')
        values(~inxLog, :) = NaN;
    end
    addTable = tableTopic(this, {columnName}, inx, values);
end%


function addTable = tableForm(this)
    numQuantities = numel(this.Quantity.Name);
    inxLog = reshape(this.Quantity.InxLog, 1, []);
    inxYX = reshape(getIndexByType(this.Quantity, 1, 2, 5), 1, []);
    values = repmat("", numQuantities, 1);
    values(inxYX & ~inxLog) = "Diff–";
    values(inxYX & inxLog) = "Rate/";
    addTable = tableTopic(this, {'Form'}, [ ], values);
end%


function addTable = tablePosition(this);
    values = reshape(1 : numel(this.Quantity.Name), [], 1);
    addTable = tableTopic(this, {'Position'}, [], values);
end%


function addTable = tableDescription(this)
    values = reshape(string(this.Quantity.Label), [], 1);
    addTable = tableTopic(this, {'Description'}, [ ], values);
end%


function addTable = tableAlias(this)
    values = reshape(string(this.Quantity.Alias), [], 1);
    addTable = tableTopic(this, {'Alias'}, [ ], values);
end%


function addTable = tableLog(this)
    values = this.Quantity.IxLog(:);
    addTable = tableTopic(this, {'LogStatus'}, [ ], values);
end%


function addTable = tableStationary(this)
    names = reshape(string(this.Quantity.Name), 1, []);
    stationary = get(this, 'Stationary');
    values = logical.empty(0, 1);
    for n = names
        if ~isfield(stationary, n) || stationary.(n)
            values = [values; true]; %#ok<AGROW>
        else
            values = [values; false]; %#ok<AGROW>
        end
    end
    addTable = tableTopic(this, {'Stationary'}, [ ], values);
end%


function addTable = tableTopic(this, columnNames, inx, varargin)
    names = reshape(this.Quantity.Name, [], 1);
    if ~isempty(inx)
        names = names(inx);
    end
    columnNames = [{'Name'}, columnNames];
    addTable = table( ...
        names, varargin{:} ...
        , 'VariableNames', columnNames ...
    );
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


function locallyWriteTable(table, writeTableOpt)
% Write table to text or spreadsheet file
    if isstring(writeTableOpt) && numel(writeTableOpt)>1
        writeTableOpt = cellstr(writeTableOpt);
    end
    if iscell(writeTableOpt) 
        fileName = string(writeTableOpt{1});
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

