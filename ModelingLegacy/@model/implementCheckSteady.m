% implementCheckSteady  Discrepancy in steady state of model equtions
%
% Backend [IrisToolbox] method
% No help provided

% -[IrisToolbox] for Macroeconomic Modeling
% -Copyright (c) 2007-2020 [IrisToolbox] Solutions Teamk

function [flag, dcy, maxAbsDcy, listEquations] = implementCheckSteady(this, variantsRequested, opt)

% The input struct Opt is expected to include field .EquationSwitch, a switch between
% evaluating full dynamic versus steady-state equations

TYPE = @int8;
STEADY_TOLERANCE = this.Tolerance.Steady;

try
    opt; %#ok<VUNUS>
catch
    opt = prepareCheckSteady(this, variantsRequested);
end

%--------------------------------------------------------------------------

ixt = this.Equation.Type==TYPE(1);
ixm = this.Equation.Type==TYPE(2);
numQuantities = length(this.Quantity);
ntm = sum(ixt | ixm);
nv = length(this);
if isequal(variantsRequested, Inf) || isequal(variantsRequested, @all)
    variantsRequested = 1 : nv;
end
numVariantsRequested = numel(variantsRequested);

if strcmpi(opt.EquationSwitch, 'Dynamic') || strcmpi(opt.EquationSwitch, 'Full')
    equationSwitch = 'Dynamic';
else 
    equationSwitch = 'Steady';
end
[minSh, maxSh] = getActualMinMaxShifts(this);
sh = minSh : maxSh;
[dcy, dcyWithImag] = evalEquations( );

maxAbsDcy = max(abs(dcy), [ ], 2);
maxAbsDcy = maxAbsDcy(:, :);
absDcyWithImag = abs(dcyWithImag); % 
absDcyWithImag = absDcyWithImag(:, :);

flag = true(1, numVariantsRequested);
listEquations = cell(1, numVariantsRequested);
for i = 1 : numVariantsRequested
    inxWithinTol = maxAbsDcy(:, i)<=STEADY_TOLERANCE;
    flag(i) = all(inxWithinTol);
    inxWithinTolInAssignment = false(size(inxWithinTol));
    if strcmpi(equationSwitch, 'Steady') && ~flag(i)
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
    
    
    function [dcy, dcyWithImag] = evalEquations( )
        % Check the full equations in two consecutive periods. This way we
        % can detect errors in both levels and growth rates.
        numShifts = length(sh);
        dcy = nan(ntm, 2, numVariantsRequested);
        isDelog = true;
        for t = 1 : 2
            vecT = t + sh;
            YXEPGT = createTrendArray(this, variantsRequested, isDelog, 1:numQuantities, vecT);
            dcy(:, t, :) = lhsmrhs(this, YXEPGT, Inf, variantsRequested, 'Kind=', equationSwitch);
        end
        
        % Substitute level+1i*growth for variables in YXE array to check direct
        % assignments in steady equations X=a+1i*b.
        dcyWithImag = nan(ntm, 1, numVariantsRequested);
        if strcmpi(equationSwitch, 'Steady')
            temp = this.Variant.Values(:, :, variantsRequested);
            YXEPGT = permute(temp, [2, 1, 3]);
            YXEPGT = repmat(YXEPGT, 1, numShifts);
            dcyWithImag = lhsmrhs(this, YXEPGT, Inf, variantsRequested, 'Kind=', equationSwitch);
        end
    end
end
