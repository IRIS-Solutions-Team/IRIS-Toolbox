% prepareStackedNoShocks  Prepare stacked simulation with no shocks
%
% Backend [IrisToolbox] function
% No help provided

% -[IrisToolbox] for Macroeconomic Modeling
% -Copyright (c) 2007-2022 [IrisToolbox] Solutions Team

function prepareStackedNoShocks(this, inxDataPoints)

resetStackedNoShocks(this);
if nnz(inxDataPoints)==0
    return
end

[numY, numXi, numXiB, numXiF] = sizeSolution(this);

%
% Create vector of positions of measurement and transition variables (as
% ordered in the @Model) within the [Y; Xi] vector
%
extractYX = hereCreateExtractor( );

numYX = numel(extractYX);
inxDataPointsYX = inxDataPoints(1:numYX, :);

[T, ~, K, Z, ~, D] = this.FirstOrderSolution{:};
[firstColumn, lastColumn] = hereCheckDataPointsWithinRange( );
numPeriods = round(lastColumn - firstColumn + 1);

M = [ ];
N = [ ];
TT = [zeros(numXiF, numXiB); eye(numXiB)];
KK = zeros(numXi, 1);
for t = firstColumn : lastColumn
    TT = T*TT(numXiF+1:end, :);
    KK = T*KK(numXiF+1:end, :) + K;
    % Create stacked simulation for YXi(t)
    addM = [Z*TT(numXiF+1:end, :); TT];
    addN = [Z*KK(numXiF+1:end, :) + D; KK];
    % Extract YX(t) from YXi(t)
    addM = addM(extractYX, :);
    addN = addN(extractYX, :);
    % Select only requested data points
    addM = addM(inxDataPointsYX(:, t), :);
    addN = addN(inxDataPointsYX(:, t), :);
    M = [M; addM];
    N = [N; addN];
end

this.StackedNoShocks_Transition = M;
this.StackedNoShocks_Constant = N;

this.StackedNoShocks_InxDataPoints = false(size(inxDataPoints));
this.StackedNoShocks_InxDataPoints(1:numYX, :) = inxDataPointsYX;

return

    function extractYX = hereCreateExtractor( )
        %(
        idXi = this.Vector.Solution{2};
        ptrXi = real(this.Vector.Solution{2});
        shiftXi = imag(this.Vector.Solution{2});
        minPtr = min(ptrXi);
        maxPtr = max(ptrXi);
        extractYX = reshape(this.Vector.Solution{1}, 1, [ ]);
        for ptr = minPtr : maxPtr
            extractYX(end+1) = numY + find(ptrXi==ptr & shiftXi==0);
        end
        %)
    end%


    function [firstColumn, lastColumn] = hereCheckDataPointsWithinRange( )
        %(
        firstColumn = this.FirstColumn;
        lastColumn = this.LastColumn;
        inxColumnsDataPoints = any(inxDataPoints, 1);
        firstColumnData = find(inxColumnsDataPoints, 1);
        lastColumnData = find(inxColumnsDataPoints, 1, 'last');
        if firstColumnData>=firstColumn && lastColumnData<=lastColumn
            lastColumn = lastColumnData;
            return
        end
        exception.error([
            "Rectangular:StackedSimulationDataPointsOutOfRange"
            "Some of the data points requested from a stacked time simulation "
            "out of the simulation range. "
        ]);
        %)
    end%
end%

