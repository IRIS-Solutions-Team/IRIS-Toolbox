function s = prepareSimulate2(this, s, variantRequested)
% prepareSimulate2  Prepare i-th simulation round for Selective
%
% Backend IRIS function
% No help provided

% -IRIS Macroeconomic Modeling Toolbox
% -Copyright (c) 2007-2022 IRIS Solutions Team

%--------------------------------------------------------------------------

ixe = this.Quantity.Type==int8(31) | this.Quantity.Type==int8(32);
ne = sum(ixe);
nh = sum(this.Equation.IxHash);
nName = length(this.Quantity.Name);

% __Loop-Dependent Fields__
% Current values of parameters and steady states.
s.Update = struct( );
s.Update.Quantity = this.Variant.Values(:, :, variantRequested);
s.Update.StdCorr = this.Variant.StdCorr(:, :, variantRequested);

nPerMax = s.NPer;

% Solution matrices expanded forward if needed
if strcmpi(s.Method, 'Selective')
    [s.T, s.R, s.K, s.Z, s.H, s.D, s.U, ~, ~, s.Q] = getSolutionMatrices(this, variantRequested);
    currentForward = min( size(s.R, 2)/ne, size(s.Q, 2)/nh ) - 1;
    if s.RequiredForward>currentForward
        vthExpansion = getIthFirstOrderExpansion(this.Variant, variantRequested);
        [s.R, s.Q] = model.expandFirstOrder(s.R, s.Q, vthExpansion, s.RequiredForward);
    end

    % Effect of nonlinear add-factors in selective nonlinear simulations
    nPerMax = nPerMax + s.NPerNonlin - 1;

    % Get steady state lines that will be added to simulated paths to evaluate
    % nonlinear equations; the steady state lines include pre-sample init cond.
    if s.IsDeviation && s.IsAddSstate
        isDelog = false;
        s.XBar = createTrendArray(this, variantRequested, ...
            isDelog, this.Vector.Solution{2}, 0:nPerMax);
        s.YBar = createTrendArray(this, variantRequested, ...
            isDelog, this.Vector.Solution{1}, 0:nPerMax);
    end

    % Steady state references.
    minSh = this.Incidence.Dynamic.Shift(1);
    maxSh = this.Incidence.Dynamic.Shift(end);
    s.MinT = minSh;
    isDelog = true;
    id = 1 : nName;
    tVec = (1+minSh) : (nPerMax+maxSh);
    s.L = createTrendArray(this, variantRequested, isDelog, id, tVec);
end

end%
