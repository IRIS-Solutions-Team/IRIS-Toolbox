function [flag, dcy, maxAbsDcy, lsEqtn] = mychksstate(this, vecAlt, opt)
% mychksstate  Discrepancy in steady state of model equtions.
%
% Backend IRIS function.
% No help provided.

% -IRIS Macroeconomic Modeling Toolbox.
% -Copyright (c) 2007-2017 IRIS Solutions Team.

% The input struct Opt is expected to include field .Kind, a switch between
% evaluating full dynamic versus steady-state equations.

TYPE = @int8;
STEADY_TOLERANCE = this.Tolerance.Steady;

try
    opt; %#ok<VUNUS>
catch
    opt = passvalopt('model.mychksstate');
end

%--------------------------------------------------------------------------

ixt = this.Equation.Type==TYPE(1);
ixm = this.Equation.Type==TYPE(2);
nQty = length(this.Quantity);
ntm = sum(ixt | ixm);
nAlt = length(this);
if isequal(vecAlt, Inf)
    vecAlt = 1 : nAlt;
end

if strcmpi(opt.Kind, 'dynamic') || strcmpi(opt.Kind, 'full')
    sh = this.Incidence.Dynamic.Shift;
    kind = 'Dynamic';
    [dcy, dcyAssign] = evalEquations( );
else 
    sh = this.Incidence.Steady.Shift;
    kind = 'Steady';
    [dcy, dcyAssign] = evalEquations( );
end
maxAbsDcy = max(abs(dcy), [ ], 2);
absDcyAssign = abs(dcyAssign); % 

flag = true(1, nAlt);
lsEqtn = cell(1, nAlt);
for iAlt = vecAlt
    ixTol = maxAbsDcy(:, iAlt)<=STEADY_TOLERANCE ...
        | absDcyAssign(:, iAlt)<=STEADY_TOLERANCE;
    flag(iAlt) = all(ixTol);
    if ~flag(iAlt) && nargout>=4
        lsEqtn{iAlt} = this.Equation.Input(~ixTol);
    else
        lsEqtn{iAlt} = { };
    end
end

flag = flag(vecAlt);
lsEqtn = lsEqtn(vecAlt);
dcy = dcy(:, :, vecAlt);
maxAbsDcy = maxAbsDcy(:,:,vecAlt);

return
    
    
    
    
    function [dcy, dcyAssign] = evalEquations( )
        % Check the full equations in two consecutive periods. This way we
        % can detect errors in both levels and growth rates.
        nsh = length(sh);
        dcy = nan(ntm, 2, nAlt);
        dcyAssign = inf(ntm, 1, nAlt);
        isDelog = true;
        nVecAlt = numel(vecAlt);
        for t = 1 : 2
            vecT = t + sh;
            YXEPGT = [
                createTrendArray(this, vecAlt, isDelog, 1:nQty, vecT)
                repmat(vecT, 1, 1, nVecAlt)
                ];
            dcy(:, t, vecAlt) = lhsmrhs(this, YXEPGT, Inf, vecAlt, 'Kind=', kind);
        end
        
        % Substitute level+1i*growth for variables in YXE array to check direct
        % assignments in steady equations X=a+1i*b.
        if strcmpi(kind, 'Steady')
            temp = model.Variant.getQuantity(this.Variant, 1:nQty, vecAlt);
            YXEPGT = [
                permute(temp, [2, 1, 3])
                zeros(1, 1, nVecAlt)
                ];
            YXEPGT = repmat(YXEPGT, 1, nsh);
            dcyAssign(:, :, vecAlt) = ...
                lhsmrhs(this, YXEPGT, Inf, vecAlt, 'Kind=', kind);
        end
    end
end
