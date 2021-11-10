% -[IrisToolbox] for Macroeconomic Modeling
% -Copyright (c) 2007-2021 [IrisToolbox] Solutions Team

% >=R2019b
%(
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
end
%)
% >=R2019b


% <=R2019a
%{
function outputTable = table(this, requests, varargin)

persistent pp
if isempty(pp)
    pp = extend.InputParser('@Model/table');

    addRequired(pp, 'model', @(x) isa(x, 'Model'));
    addRequired(pp, 'requests', @(x) ischar(x) || iscellstr(x) || isa(x, 'string'));
    
    addParameter(pp, 'CompareFirstColumn', true, @(x) isequal(x, true) || isequal(x, false));
    addParameter(pp, 'Diary', "", @(x) isempty(x) || ischar(x) || (isstring(x) && isscalar(x)));
    addParameter(pp, 'Round', Inf, @(x) isequal(x, Inf) || (isnumeric(x) && isscalar(x) && x==round(x)));
    addParameter(pp, 'SelectRows', false, @(x) isequal(x, false) || validate.list(x));
    addParameter(pp, {'SortAlphabetically', 'Sort'}, false, @(x) isequal(x, true) || isequal(x, false));
    addParameter(pp, 'WriteTable', "", @validate.mustBeTextScalar);
end
opt = parse(pp, this, requests, varargin{:});
%}
% <=R2019a


requests = reshape(string(requests), 1, []);
numRequests = numel(requests);

outputTable = table(this.Quantity.Name(:), 'VariableNames', {'Name'});

isFirstRequest = true;
for n = requests
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


    elseif any(strcmpi(n, {'Description', 'Descriptions'}))
        addTable = tableDescription(this);


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
    values = this.Quantity.Label(:);
    values = string(values);
    addTable = tableTopic(this, {'Description'}, [ ], values);
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

