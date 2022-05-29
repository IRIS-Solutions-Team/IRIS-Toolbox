% table  Display table of exogenized and endogenized data points 
%{
%}

% -[IrisToolbox] for Macroeconomic Modeling
% -Copyright (c) 2007-2022 [IrisToolbox] Solutions Team

function outputTable = table(this, varargin)

%( Input parser
persistent pp
if isempty(pp)
    pp = extend.InputParser('@Plan/table');
    addRequired(pp, 'plan', @(x) isa(x, 'Plan'));
    addOptional(pp, 'inputDb', [ ], @validate.databank);

    addParameter(pp, 'WriteTable', '', @(x) isempty(x) || ischar(x) || isa(x, 'string'));
end
%)
opt = parse(pp, this, varargin{:});
inputDb = pp.Results.inputDb;

%-------------------------------------------------------------------------------

inxAnticipatedExogenized    = this.InxOfAnticipatedExogenized;
inxUnanticipatedExogenized  = this.InxOfUnanticipatedExogenized;
inxAnticipatedEndogenized   = this.InxOfAnticipatedEndogenized;
inxUnanticipatedEndogenized = this.InxOfUnanticipatedEndogenized;

inxDates = any([ 
    inxAnticipatedExogenized 
    inxUnanticipatedExogenized
    inxAnticipatedEndogenized
    inxUnanticipatedEndogenized
], 1);
numDates = nnz(inxDates);
posDates = find(inxDates);
dates = this.ExtendedStart + posDates - 1;
inxExogenized = any(inxAnticipatedExogenized | inxUnanticipatedExogenized, 2);
numExogenized = nnz(inxExogenized);
inxEndogenized = any(inxAnticipatedEndogenized | inxUnanticipatedEndogenized, 2);

isData = false;
data = cell.empty(0, 0);
if ~isempty(inputDb)
    data = databank.toDoubleArray(inputDb, this.NamesOfEndogenous, this.ExtendedRange, 1);
    data = transpose(data);
    isData = true;
end

rowNames = cell.empty(0, 1);
linkColumn = int16.empty(0, 1);
actionColumn = string.empty(0, 1);
tableData = cell.empty(0, numDates);
for id = getUniqueIds(this)
    %
    % Collect info on exogenized variables
    %
    marksExogenized = repmat({this.EMPTY_MARK}, this.NumOfEndogenous, this.NumExtdPeriods);
    inxAnticipated = this.IdAnticipatedExogenized==id;
    inxUnanticipated = this.IdUnanticipatedExogenized==id;
    inxWhenData = this.InxToKeepEndogenousNaN;
    inxExogenized = inxAnticipated | inxUnanticipated;
    anyExogenized = any(inxExogenized(:));
    if anyExogenized
        marksExogenized(inxAnticipated & ~inxWhenData) = {[this.ANTICIPATED_MARK, this.ALWAYS_MARK]};
        marksExogenized(inxAnticipated & inxWhenData) = {[this.ANTICIPATED_MARK, this.WHEN_DATA_MARK]};
        marksExogenized(inxUnanticipated & ~inxWhenData) = {[this.UNANTICIPATED_MARK, this.ALWAYS_MARK]};
        marksExogenized(inxUnanticipated & inxWhenData) = {[this.UNANTICIPATED_MARK, this.WHEN_DATA_MARK]};
        keep = any(inxAnticipated | inxUnanticipated, 2);
        numKeep = nnz(keep);
        addTableData = marksExogenized(keep, inxDates);
        if isData
            addValues = repmat({char.empty(1, 0)}, size(inxExogenized));
            addValues(inxExogenized) = arrayfun(@(x) sprintf('[%g]', x), data(inxExogenized), 'UniformOutput', false);
            addTableData = strcat(addTableData, addValues(keep, inxDates));
        end
        tableData = [tableData; addTableData];
        linkColumn = [linkColumn; repmat(id, numKeep, 1)];
        actionColumn = [actionColumn; repmat("Exogenize", numKeep, 1)];
        rowNames = [rowNames; reshape(this.NamesOfEndogenous(keep), [ ], 1)];
    end

    %
    % Collect info on endogenized variables
    %
    inxAnticipated = this.IdAnticipatedEndogenized==id;
    inxUnanticipated = this.IdUnanticipatedEndogenized==id;
    anyEndogenized = any(inxAnticipated(:)) || any(inxUnanticipated(:));
    if anyEndogenized
        marksEndogenized = repmat({this.EMPTY_MARK}, this.NumOfExogenous, this.NumExtdPeriods);
        marksEndogenized(inxAnticipated) = {this.ANTICIPATED_MARK};
        marksEndogenized(inxUnanticipated) =  {this.UNANTICIPATED_MARK};
        keep = any(inxAnticipated | inxUnanticipated, 2);
        numKeep = nnz(keep);
        marksEndogenized = marksEndogenized(keep, inxDates);
        tableData = [tableData; marksEndogenized];
        linkColumn = [linkColumn; repmat(id, numKeep, 1)];
        actionColumn = [actionColumn; repmat("Endogenize", numKeep, 1)];
        rowNames = [rowNames; reshape(this.NamesOfExogenous(keep), [ ], 1)];
    end
end

tableDataOrganized = cell(1, numDates);
for t = 1 : numDates
    tableDataOrganized{t} = string(tableData(:, t));
end
outputTable = table(string(rowNames), actionColumn, linkColumn, tableDataOrganized{:});

dateNames = cellstr(dater.toDefaultString(dates));
try
    outputTable.Properties.VariableNames = [{'Name', 'Action', 'Link'}, dateNames];
catch
    dateNames = strcat(this.DATE_PREFIX, dateNames);
    outputTable.Properties.VariableNames = [{'Name', 'Action', 'Link'}, dateNames];
end

% Write table to text or spreadsheet file
if ~isempty(opt.WriteTable)
    writetable(outputTable, opt.WriteTable, 'WriteRowNames', true);
end

end%

