function s = prepareSimulate2(this, s, iAlt)
% prepareSimulate2  Prepare i-th simulation round.
%
% Backed IRIS function.
% No help provided.

% -IRIS Macroeconomic Modeling Toolbox.
% -Copyright (c) 2007-2017 IRIS Solutions Team.

%--------------------------------------------------------------------------

ixe = this.Quantity.Type==int8(31) | this.Quantity.Type==int8(32);
ne = sum(ixe);
nn = sum(this.Equation.IxHash);
lastEa = s.LastEa;
lastEndgA = s.LastEndgA;
nPerNonlin = s.NPerNonlin;
nName = length(this.Quantity.Name);

% Forward expansion needed
%--------------------------
s.TPlusK = max([1,lastEa,lastEndgA,nPerNonlin]) - 1;

% Loop-dependent fields
%-----------------------
% Current values of parameters and steady states.
s.Update = model.IterateOver( );
s.Update.Quantity = this.Variant{iAlt}.Quantity;
s.Update.StdCorr = this.Variant{iAlt}.StdCorr;

% Solution matrices.
s.T = this.solution{1}(:,:,iAlt);
s.R = this.solution{2}(:,:,iAlt);
s.K = this.solution{3}(:,:,iAlt);
s.Z = this.solution{4}(:,:,iAlt);
s.H = this.solution{5}(:,:,iAlt);
s.D = this.solution{6}(:,:,iAlt);
s.U = this.solution{7}(:,:,iAlt);

% Solution expansion matrices.
s.Expand = cell(size(this.Expand));
for ii = 1 : numel(s.Expand)
    s.Expand{ii} = this.Expand{ii}(:,:,iAlt);
end

nPerMax = s.NPer;
% Effect of nonlinear add-factors in selective nonlinear simulations.
if isequal(s.Method, 'selective')
    nPerMax = nPerMax + s.NPerNonlin - 1;
    s.Q = this.solution{8}(:,:,iAlt);
end

% Get steady state lines that will be added to simulated paths to evaluate
% nonlinear equations; the steady state lines include pre-sample init cond.
if isequal(s.Method, 'selective')
    if s.IsDeviation && s.IsAddSstate
        isDelog = false;
        s.XBar = createTrendArray(this, iAlt, ...
            isDelog, this.Vector.Solution{2}, 0:nPerMax);
        s.YBar = createTrendArray(this,iAlt, ...
            isDelog, this.Vector.Solution{1}, 0:nPerMax);
    end
end

if s.IsRevision || isequal(s.Method, 'selective')
    % Steady state references.
    minSh = this.Incidence.Dynamic.Shift(1);
    maxSh = this.Incidence.Dynamic.Shift(end);
    s.MinT = minSh;
    isDelog = true;
    id = 1 : nName;
    tVec = (1+minSh) : (nPerMax+maxSh);
    s.L = createTrendArray(this,iAlt,isDelog,id,tVec);
end

% Expand solution forward up to t+k if needed.
if s.TPlusK > 0
    if isequal(s.Method, 'selective') && (ne > 0 || nn > 0)
        % Expand solution forward to t+k for both shocks and non-linear
        % add-factors.
        [s.R,s.Q] = model.myexpand(s.R,s.Q,s.TPlusK,s.Expand{1:6});
    elseif ne > 0
        % Expand solution forward to t+k for shocks only.
        s.R = model.myexpand(s.R,[ ],s.TPlusK,s.Expand{1:5},[ ]);
    end
end

end
