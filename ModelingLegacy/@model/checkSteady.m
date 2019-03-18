function [flag, dcy, maxAbsDcy, listOfEquations] = checkSteady(this, variantsRequested, opt)
% checkSteady  Discrepancy in steady state of model equtions
%
% Backend IRIS function
% No help provided

% -IRIS Macroeconomic Modeling Toolbox.
% -Copyright (c) 2007-2019 IRIS Solutions Team.

% The input struct Opt is expected to include field .EquationSwitch, a switch between
% evaluating full dynamic versus steady-state equations.

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
numOfQuantities = length(this.Quantity);
ntm = sum(ixt | ixm);
nv = length(this);
if isequal(variantsRequested, Inf) || isequal(variantsRequested, @all)
    variantsRequested = 1 : nv;
end
numOfVariantsRequested = numel(variantsRequested);

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

flag = true(1, numOfVariantsRequested);
listOfEquations = cell(1, numOfVariantsRequested);
for i = 1 : numOfVariantsRequested
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
        listOfEquations{i} = transpose(this.Equation.Input(~inxWithinTol & ~inxWithinTolInAssignment));
    else
        listOfEquations{i} = cell.empty(0, 1);
    end
end

return
    
    
    function [dcy, dcyWithImag] = evalEquations( )
        % Check the full equations in two consecutive periods. This way we
        % can detect errors in both levels and growth rates.
        numOfShifts = length(sh);
        dcy = nan(ntm, 2, numOfVariantsRequested);
        isDelog = true;
        for t = 1 : 2
            vecT = t + sh;
            YXEPGT = createTrendArray(this, variantsRequested, isDelog, 1:numOfQuantities, vecT);
            dcy(:, t, :) = lhsmrhs(this, YXEPGT, Inf, variantsRequested, 'Kind=', equationSwitch);
        end
        
        % Substitute level+1i*growth for variables in YXE array to check direct
        % assignments in steady equations X=a+1i*b.
        dcyWithImag = nan(ntm, 1, numOfVariantsRequested);
        if strcmpi(equationSwitch, 'Steady')
            temp = this.Variant.Values(:, :, variantsRequested);
            YXEPGT = permute(temp, [2, 1, 3]);
            YXEPGT = repmat(YXEPGT, 1, numOfShifts);
            dcyWithImag = lhsmrhs(this, YXEPGT, Inf, variantsRequested, 'Kind=', equationSwitch);
        end
    end
end
