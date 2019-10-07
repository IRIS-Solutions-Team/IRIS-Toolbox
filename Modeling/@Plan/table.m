function outputTable = table(this, varargin)
% table  Display table of exogenized and endogenized data points 
%{
%}

% -IRIS Macroeconomic Modeling Toolbox
% -Copyright (c) 2007-2019 IRIS Solutions Team

persistent parser
if isempty(parser)
    parser = extend.InputParser('Plan.table');
    parser.addRequired('plan', @(x) isa(x, 'Plan'));
    parser.addOptional('inputDatabank', [ ], @validate.databank);
    parser.addParameter('WriteTable', '', @(x) isempty(x) || ischar(x) || isa(x, 'string'));
end
parse(parser, this, varargin{:});
opt = parser.Options;
inputDatabank = parser.Results.inputDatabank;

%-------------------------------------------------------------------------------

inxAnticipatedExogenized    = this.InxOfAnticipatedExogenized;
inxUnanticipatedExogenized  = this.InxOfUnanticipatedExogenized;
inxAnticipatedEndogenized   = this.InxOfAnticipatedEndogenized;
inxUnanticipatedEndogenized = this.InxOfUnanticipatedEndogenized;

inxDates = any( [ inxAnticipatedExogenized 
                  inxUnanticipatedExogenized
                  inxAnticipatedEndogenized
                  inxUnanticipatedEndogenized ], 1 );
numDates = nnz(inxDates);
posDates = find(inxDates);
dates = this.ExtendedStart + posDates - 1;
inxExogenized = any(inxAnticipatedExogenized | inxUnanticipatedExogenized, 2);
numExogenized = nnz(inxExogenized);
inxEndogenized = any(inxAnticipatedEndogenized | inxUnanticipatedEndogenized, 2);

isData = false;
data = cell.empty(0, 0);
if ~isempty(inputDatabank)
    data = databank.toDoubleArray(inputDatabank, this.NamesOfEndogenous, this.ExtendedRange, 1);
    data = transpose(data);
    isData = true;
end

rowNames = cell.empty(0, 1);
idColumn = int16.empty(0, 1);
tableData = cell.empty(0, numDates);
for id = getUniqueIds(this)
    marksExogenized = repmat({this.EMPTY_MARK}, this.NumOfEndogenous, this.NumOfExtendedPeriods);
    inxAnticipated = this.IdOfAnticipatedExogenized==id;
    inxUnanticipated = this.IdOfUnanticipatedExogenized==id;
    inxExogenized = inxAnticipated | inxUnanticipated;
    anyExogenized = any(inxExogenized(:));
    if anyExogenized
        marksExogenized(inxAnticipated) = {this.ANTICIPATED_MARK};
        marksExogenized(inxUnanticipated) = {this.UNANTICIPATED_MARK};
        keep = any(inxAnticipated | inxUnanticipated, 2);
        numKeep = nnz(keep);
        addTableData = marksExogenized(keep, inxDates);
        if isData
            addValues = repmat({char.empty(1, 0)}, size(inxExogenized));
            addValues(inxExogenized) = arrayfun(@(x) sprintf('[%g]', x), data(inxExogenized), 'UniformOutput', false);
            addTableData = strcat(addTableData, addValues(keep, inxDates));
        end
        tableData = [tableData; addTableData];
        idColumn = [idColumn; repmat(id, numKeep, 1)];
        rowNames = [rowNames; reshape(this.NamesOfEndogenous(keep), [ ], 1)];
    end

    inxAnticipated = this.IdOfAnticipatedEndogenized==id;
    inxUnanticipated = this.IdOfUnanticipatedEndogenized==id;
    anyEndogenized = any(inxAnticipated(:)) || any(inxUnanticipated(:));
    if anyEndogenized
        marksEndogenized = repmat({this.EMPTY_MARK}, this.NumOfExogenous, this.NumOfExtendedPeriods);
        marksEndogenized(inxAnticipated) = {this.ANTICIPATED_MARK};
        marksEndogenized(inxUnanticipated) =  {this.UNANTICIPATED_MARK};
        keep = any(inxAnticipated | inxUnanticipated, 2);
        numKeep = nnz(keep);
        marksEndogenized = marksEndogenized(keep, inxDates);
        tableData = [tableData; marksEndogenized];
        idColumn = [idColumn; repmat(id, numKeep, 1)];
        rowNames = [rowNames; reshape(this.NamesOfExogenous(keep), [ ], 1)];
    end
end

tableDataOrganized = cell(1, numDates);
for t = 1 : numDates
    tableDataOrganized{t} = char(tableData(:, t));
end
outputTable = table(char(rowNames), idColumn, tableDataOrganized{:});

dateNames = cellstr(DateWrapper.toDefaultString(dates));
try
    outputTable.Properties.VariableNames = [{'Name', 'SwapId'}, dateNames];
catch
    dateNames = strcat(this.DATE_PREFIX, dateNames);
    outputTable.Properties.VariableNames = [{'Name', 'SwapId'}, dateNames];
end

% Write table to text or spreadsheet file
if ~isempty(opt.WriteTable)
    writetable(outputTable, opt.WriteTable, 'WriteRowNames', true);
end

end%

