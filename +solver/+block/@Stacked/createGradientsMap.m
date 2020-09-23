% createGradientsMap  Populate StackedJacob_GradientsMap and StackedJacob_InxLogWithinMap
%
% Backend [IrisToolbox] function
% No help provided

% -[IrisToolbox] for Macroeconomic Modeling
% -Copyright (c) 2007-2020 [IrisToolbox] Solutions Team

function createGradientsMap(this)

inxLogWithinModel = this.ParentBlazer.Model.Quantity.InxLog;
columnsToRun = this.ParentBlazer.ColumnsToRun;
numPtrEquations = numel(this.PtrEquations);
numColumns = numel(columnsToRun);
idQuantities = cellfun(@(x) reshape(x, [ ], 1) + 1i*columnsToRun, this.Gradients(2, :), "uniformOutput", false);
numWrts = cellfun(@numel, this.Gradients(2, :));

%
% Index of equations in common Jacobian that need update (because the
% gradient functions involve at least one quantity solved for in this
% block). The index is for each pointer, not each equation, because the
% common Jacobian is for multiple columns in 2nd dimension.
%
inxNeedsUpdate = false(1, numPtrEquations);
idsWithinGradient = cell(1, numPtrEquations);
for i = 1 : numPtrEquations
    idsWithinGradient{i} = reshape(this.Gradients{3, i}, 1, [ ]) + reshape(1i*columnsToRun, [ ], 1);
    inxNeedsUpdate(i) = any(any(reshape(idsWithinGradient{i}, [ ], 1)==this.IdQuantities));
end
needsUpdate = any(inxNeedsUpdate);
accelerateUpdate = ~all(inxNeedsUpdate);

offset = 0;
offset_Update = 0;
numRowsLhs = numel(this.IdEquations);

%
% Number of rows of the array of gradients; each equation has its gradient
% evaluated w.r.t. a different number of variables and shocks, with not all
% of them actually used in the Jacobian in this block.
%
numRowsRhs = sum(numWrts);
if needsUpdate && accelerateUpdate
    numRowsRhs_Update = sum(numWrts(inxNeedsUpdate));
end

linxLhs = [ ];
linxRhs = [ ];
inxLogWithinMap = [ ];
columnsJacob = [ ];

if needsUpdate && accelerateUpdate
    linxLhs_Update = [ ];
    linxRhs_Update = [ ];
    inxLogWithinMap_Update = [ ];
    columnsJacob_Update = [ ];
end

for i = 1 : numPtrEquations
    for j = 1 : numColumns
        for k = 1 : numWrts(i)
            inx = idQuantities{i}(k, j)==this.IdQuantities;
            if ~any(inx)
                continue
            end
            ptrQuantity = real(idQuantities{i}(k, j));
            rowRhs = offset + k;
            rowRhs_Update = offset_Update + k;
            columnRhs = j;
            columnLhs = find(inx, 1);
            rowLhs = (j-1)*numPtrEquations + i;
            linxLhs(end+1) = (columnLhs-1)*numRowsLhs + rowLhs;
            linxRhs(end+1) = (columnRhs-1)*numRowsRhs + rowRhs;
            columnsJacob(end+1) = columnLhs;
            inxLogWithinMap(end+1) = inxLogWithinModel(ptrQuantity);
            if accelerateUpdate && inxNeedsUpdate(i)
                linxLhs_Update(end+1) = (columnLhs-1)*numRowsLhs + rowLhs;
                linxRhs_Update(end+1) = (columnRhs-1)*numRowsRhs_Update + rowRhs_Update;
                columnsJacob_Update(end+1) = columnLhs;
                inxLogWithinMap_Update(end+1) = inxLogWithinModel(ptrQuantity);
            end
        end
    end
    offset = offset + numWrts(i);
    if inxNeedsUpdate(i)
        offset_Update = offset_Update + numWrts(i);
    end
end

this.StackedJacob_GradientsMap = [linxLhs; linxRhs; columnsJacob];
this.StackedJacob_InxLogWithinMap = inxLogWithinMap;

this.StackedJacob_InxNeedsUpdate = inxNeedsUpdate;
if needsUpdate && accelerateUpdate
    this.StackedJacob_GradientsMap_Update = [linxLhs_Update; linxRhs_Update; columnsJacob_Update];
    this.StackedJacob_InxLogWithinMap_Update = inxLogWithinMap_Update;
end

end%

