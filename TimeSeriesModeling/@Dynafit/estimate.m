% Type `web Dynafit/estimate.md` for help on this function
%
% -IRIS Macroeconomic Modeling Toolbox
% -Copyright (c) 2007-2022 IRIS Solutions Team

function ...
    [this, outputDb, contribDb, range] ...
    = estimate(this, d, range, crit, varargin)

persistent pp
if isempty(pp)
    pp = extend.InputParser('Dynafit.estimate');
    pp.addRequired('Dynafit', @(x) isa(x, 'Dynafit'));
    pp.addRequired('InputData', @isstruct);
    pp.addRequired('Range', @validate.range);
    pp.addRequired('RQ', ...
        @(x) isnumeric(x) && numel(x)==2 && x(1)>0 && x(1)<=1 && x(2)==round(x(2)) && x(2)>=1);
    pp.addParameter('Cross', true, ...
        @(x) isequal(x, true) || isequal(x, false) || (isnumeric(x) && isscalar(x) && x>=0 && x<=1));
    pp.addParameter('Method', 'auto', @(x) all(strcmpi(x, 'auto')) || isequal(x, 1) || isequal(x, 2));
    pp.addParameter('Order', @auto, @(x) isequal(x, @auto) || (isnumeric(x) && isscalar(x)))
    pp.addParameter('Rank', Inf, @(x) isnumeric(x) && isscalar(x));
    pp.addParameter('Mean', []);
    pp.addParameter('Std', []);
end
pp.parse(this, d, range, crit, varargin{:});
opt = pp.Options;

this.Mean = opt.Mean;
this.Std = opt.Std;

order = opt.Order;
if isequal(order, @auto)
    order = this.Order;
end
this.Order = order;

% Get input data
[y, range] = getEstimationData(this, d, range);
this.Range = double(range);

% Standardize input data
y0 = y;
[this, y] = stdize(this, y);

% Estimate static factors using principal components
[FF, this.C, U, this.Sigma, this.SingValues, sample, ctf] ...
    = Dynafit.pc(y, crit, opt.Method);

% Estimate VAR(p, q) on factors
[this.A, this.B, this.Omega, E, this.IxFitted] ...
    = locallyEstimateVAR(FF, order, opt.Rank);

% Triangularize transition matrix, compute eigenvalues and stability
this = schur(this);

% Reduce or zero off-diagonal elements in the cov matrix of idiosyncratic
% residuals if requested
this.Cross = double(opt.Cross);
if this.Cross<1
    index = logical(eye(size(this.Sigma)));
    this.Sigma(~index) = this.Cross*this.Sigma(~index);
end

% Common components
common = Dynafit.cc(this.C, FF);
common = Dynafit.destdize(common, this.Mean, this.Std); 

% Idiosyncratic residuals
U = Dynafit.destdize(U, 0, this.Std);


%
% Create output databank
%

allData = [y0; common; FF; U; E];

allNames = [ ...
    this.ObservedNames, this.CommonNames, this.FactorNames ...
    , this.IdiosyncraticResidualNames, this.FactorResidualNames ...
];

outputDb = databank.backend.fromArrayNoFrills( ...
    allData, allNames, range(1) ...
    , [], @all, "struct", struct() ...
);

range = Dater(range(sample));

if nargout>2
    contribDb = databank.backend.fromArrayNoFrills( ...
        ctf, this.ContributionNames, range(1) ...
        , [], @all, "struct", struct() ...
    );
end

end%

%
% Local functions
%

function [A, B, Omg, u, fitted] = locallyEstimateVAR(X, P, Q)
    %(
    nx = size(X, 1);
    nPer = size(X, 2);

    % Stack vectors of x(t), x(t-1), etc.
    t = P+1 : nPer;
    presample = nan(nx, P);
    x0 = [presample, X(:, t)];
    x1 = [ ];
    for i = 1 : P
       x1 = [x1;presample, X(:, t-i)]; %#ok<AGROW>
    end

    % Determine dates with no missing observations.
    fitted = all(~isnan([x0;x1]));
    nObs = sum(fitted);

    % Estimate VAR and reduced-form residuals.
    A = x0(:, fitted)/x1(:, fitted);
    e = x0 - A*x1;
    Omg = e(:, fitted)*e(:, fitted)'/nObs;

    % Number of orthonormalised shocks driving the factor VAR.
    if Q > nx
       Q = nx;
    end

    % Compute principal components of reduced-form residuals, back out
    % orthonormalised residuals.
    % e = B u, 
    % Euu' = I.
    [B, u] = covfun.orthonorm(Omg, Q, 1, e);
    B = B(:, 1:Q, :);
    u = u(1:Q, :, :);
    %)
end%

