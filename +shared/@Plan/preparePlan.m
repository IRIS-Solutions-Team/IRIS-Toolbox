function plan = preparePlan(this, plan)

% Invoke unit tests
%(
if nargin==2 && isequal(plan, '--test')
    plan = functiontests({
        @setupOnce
        @modelTest
    });
    plan = reshape(plan, [ ], 1);
    return
end
%)

%--------------------------------------------------------------------------

plan.NamesOfEndogenous = getEndogenousForPlan(this);
plan.NamesOfExogenous = getExogenousForPlan(this);
[plan.ExtendedStart, plan.ExtendedEnd, ~, ~, inxBaseRange] = getExtendedRange(this, [plan.BaseStart, plan.BaseEnd]);
plan.AutoswapPairs = getAutoswapsForPlan(this);
sigmas = getSigmasForPlan(this);
numVariants = size(sigmas, 3);
numExtPeriods = plan.NumOfExtendedPeriods;
plan.DefaultSigmasOfExogenous = sigmas;
sigmas = repmat(sigmas, 1, numExtPeriods, 1);
sigmas(:, ~inxBaseRange, :) = NaN;
plan.SigmasOfExogenous = sigmas;

end%




%
% Unit Tests
%
%(
function setupOnce(testCase)
end%


function modelTest(testCase)
    f = model.File;
    f.FileName = "";
    f.Code = join([ 
        "!variables x, y, z !shocks ex, ey, ez "
        "!equations x=x{-1}+ex+0.1*ey+0.1*ez; y=0.1*ex+ey+0.1*ez; z=0.1*ex+0.1*ey+ez;"
    ]);
    m = Model(f, 'Linear=', true);
    p = Plan(m, 1:10);
    assertEqual(testCase, p.SigmasOfExogenous, [nan(3,1), ones(3,10)]);
    m8 = alter(m, 8);
    p8 = Plan(m8, 1:10);
    assertEqual(testCase, p8.SigmasOfExogenous, [nan(3,1,8), ones(3,10,8)]);
    m8 = assign(m8, 'std_ey', 1:8);
    p8 = Plan(m8, 1:10);
    exp = nan(3, 11, 8);
    exp(:, 2:end, :) = 1;
    exp(2, 2:end, :) = repmat(reshape(1:8, 1, 1, 8), 1, 10, 1);
    assertEqual(testCase, p8.SigmasOfExogenous, exp);
end%
%)
