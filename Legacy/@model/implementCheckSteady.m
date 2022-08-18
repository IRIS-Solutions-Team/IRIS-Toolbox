function [flag, dcy, maxAbsDcy, listEquations] = implementCheckSteady(this, variantsRequested, options)

STEADY_TOLERANCE = this.Tolerance.Steady;

inxT = this.Equation.Type==1;
inxM = this.Equation.Type==2;
numQuantities = numel(this.Quantity);
numTM = nnz(inxT | inxM);
numVariants = countVariants(this);
if isequal(variantsRequested, Inf) || isequal(variantsRequested, @all)
    variantsRequested = 1 : numVariants;
end
numVariantsRequested = numel(variantsRequested);

[minSh, maxSh] = getActualMinMaxShifts(this);
sh = minSh : maxSh;
[dcy, dcyWithImag] = hereEvalEquations( );

maxAbsDcy = max(abs(dcy), [ ], 2);
maxAbsDcy = maxAbsDcy(:, :);
absDcyWithImag = abs(dcyWithImag);
absDcyWithImag = absDcyWithImag(:, :);

flag = true(1, numVariantsRequested);
listEquations = cell(1, numVariantsRequested);
for i = 1 : numVariantsRequested
    inxWithinTol = maxAbsDcy(:, i)<=STEADY_TOLERANCE;
    flag(i) = all(inxWithinTol);
    inxWithinTolInAssignment = false(size(inxWithinTol));
    if options.EquationSwitch=="steady" && ~flag(i)
        inxWithinTolWithImag = absDcyWithImag(:, i)<=STEADY_TOLERANCE;
        inxWithinTolInAssignment = ~inxWithinTol & inxWithinTolWithImag;
        maxAbsDcy(inxWithinTolInAssignment, i) = absDcyWithImag(inxWithinTolInAssignment, i);
        flag(i) = all(inxWithinTol | inxWithinTolInAssignment);
    end
    if ~flag(i) && nargout>=4
        listEquations{i} = transpose(this.Equation.Input(~inxWithinTol & ~inxWithinTolInAssignment));
    else
        listEquations{i} = cell.empty(0, 1);
    end
end

return

    function [dcy, dcyWithImag] = hereEvalEquations( )
        % Check the full equations in two consecutive periods. This way we
        % can detect errors in both levels and growth rates.
        numShifts = length(sh);
        dcy = nan(numTM, 2, numVariantsRequested);
        isDelog = true;
        for t = 1 : 2
            vecT = t + sh;
            YXEPGT = createTrendArray(this, variantsRequested, isDelog, 1:numQuantities, vecT);
            dcy(:, t, :) = lhsmrhs(this, YXEPGT, Inf, variantsRequested, "equationSwitch", options.EquationSwitch);
        end

        % Substitute level+1i*growth for variables in YXE array to check direct
        % assignments in steady equations X=a+1i*b.
        dcyWithImag = nan(numTM, 1, numVariantsRequested);
        if options.EquationSwitch=="steady"
            temp = this.Variant.Values(:, :, variantsRequested);
            YXEPGT = permute(temp, [2, 1, 3]);
            YXEPGT = repmat(YXEPGT, 1, numShifts);
            dcyWithImag = lhsmrhs(this, YXEPGT, Inf, variantsRequested, "equationSwitch", options.EquationSwitch);
        end
    end
end%

