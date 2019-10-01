function outputTable = table(this, varargin)
% table  Display table of exogenized and endogenized data points 
%{
%}

% -IRIS Macroeconomic Modeling Toolbox
% -Copyright (c) 2007-2019 IRIS Solutions Team

persistent parser
if isempty(parser)
    parser = extend.InputParser('Plan.table');
    parser.addRequired('Plan', @(x) isa(x, 'Plan'));
    parser.addParameter('InputDatabank', [ ], @(x) isempty(x) || isstruct(x));
    parser.addParameter('WriteTable', '', @(x) isempty(x) || ischar(x) || isa(x, 'string'));
end
parse(parser, this, varargin{:});
opt = parser.Options;

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
posOfDates = find(inxDates);
dates = this.ExtendedStart + posOfDates - 1;
inxExogenized = any(inxAnticipatedExogenized | inxUnanticipatedExogenized, 2);
numExogenized = nnz(inxExogenized);
inxEndogenized = any(inxAnticipatedEndogenized | inxUnanticipatedEndogenized, 2);
dateNames = DateWrapper.toDefaultString(dates);
% dateNames = strcat(this.DATE_PREFIX, dateNames);

isData = false;
data = cell.empty(0, 0);
if ~isempty(opt.InputDatabank)
    data = databank.toDoubleArray(opt.InputDatabank, this.NamesOfEndogenous, this.ExtendedRange, 1);
    data = transpose(data);
    isData = true;
end

rowNames = cell.empty(0, 1);
idColumn = uint16.empty(0, 1);
tableData = cell.empty(0, numDates);
for id = uint16(1) : this.SwapId
    markExogenized = repmat({''}, this.NumOfEndogenous, this.NumOfExtendedPeriods);
    inxAnticipated = this.IdOfAnticipatedExogenized==id;
    inxUnanticipated = this.IdOfUnanticipatedExogenized==id;
    inxExogenized = inxAnticipated | inxUnanticipated;
    anyExogenized = any(inxExogenized(:));
    if anyExogenized
        markExogenized(inxAnticipated) = {this.ANTICIPATED_MARK};
        markExogenized(inxUnanticipated) = {this.UNANTICIPATED_MARK};
        keep = any(inxAnticipated | inxUnanticipated, 2);
        numKeep = nnz(keep);
        markExogenized = markExogenized(keep, inxDates);
        if isData
            valuesExogenized = nan(this.NumOfEndogenous, this.NumOfExtendedPeriods);
            valuesExogenized(inxExogenized) = data(inxExogenized);
            addTableData = cell(2*numKeep, numDates);
            addTableData(1:2:end) = markExogenized;
            addTableData(2:2:end) = num2cell(valuesExogenized(keep, inxDates));
            addIdColumn = repmat(id-1, 2*numKeep, 1);
            addRowNames = repmat({''}, 2*numKeep, 1);
            addRowNames(1:2:end) = this.NamesOfEndogenous(keep);
            addRowNames(2:2:end) = {'='};
        else
            addTableData = markExogenized;
            addIdColumn = repmat(id-1, numKeep, 1);
            addRowNames = this.NamesOfEndogenous(keep);
        end
        tableData = [tableData; addTableData];
        idColumn = [idColumn; addIdColumn];
        rowNames = [rowNames; reshape(addRowNames, [ ], 1)];
    end

    inxAnticipated = this.IdOfAnticipatedEndogenized==id;
    inxUnanticipated = this.IdOfUnanticipatedEndogenized==id;
    anyEndogenized = any(inxAnticipated(:)) || any(inxUnanticipated(:));
    if anyEndogenized
        markEndogenized = repmat({''}, this.NumOfExogenous, this.NumOfExtendedPeriods);
        markEndogenized(inxAnticipated) = {this.ANTICIPATED_MARK};
        markEndogenized(inxUnanticipated) =  {this.UNANTICIPATED_MARK};
        keep = any(inxAnticipated | inxUnanticipated, 2);
        numKeep = nnz(keep);
        markEndogenized = markEndogenized(keep, inxDates);
        tableData = [tableData; markEndogenized];
        idColumn = [idColumn; repmat(id-1, numKeep, 1)];
        rowNames = [rowNames; reshape(this.NamesOfExogenous(keep), [ ], 1)];
    end
end

tableDataOrganized = cell(1, numDates);
for t = 1 : numDates
    tableDataOrganized{t} = tableData(:, t);
end
outputTable = table(idColumn, tableDataOrganized{:});
outputTable.Properties.RowNames = rowNames;
outputTable.Properties.VariableNames = [{'SwapId'}, dateNames];

% Write table to text or spreadsheet file
if ~isempty(opt.WriteTable)
    writetable(outputTable, opt.WriteTable, 'WriteRowNames', true);
end

end%

