function [s, this] = diffsrf(this, time, lsPar, varargin)
% diffsrf  Differentiate shock response functions w.r.t. specified parameters.
%
% Syntax
% =======
%
%     S = diffsrf(M,Range,PList,...)
%     S = diffsrf(M,NPer,PList,...)
%
%
% Input arguments
% ================
%
% * `M` [ model ] - Model object whose response functions will be simulated
% and differentiated.
%
% * `Range` [ numeric | char ] - Simulation date range with the first date
% being the shock date.
%
% * `NPer` [ numeric ] - Number of simulation periods.
%
% * `PList` [ char | cellstr ] - List of parameters w.r.t. which the
% shock response functions will be differentiated.
%
%
% Output arguments
% =================
%
% * `S` [ struct ] - Database with shock reponse derivatives stowed in
% multivariate time series.
%
%
% Options
% ========
%
% See [`model/srf`](model/srf) for options available.
%
%
% Description
% ============
%
%
% Example
% ========
%

% -IRIS Macroeconomic Modeling Toolbox.
% -Copyright (c) 2007-2017 IRIS Solutions Team.

TYPE = @int8;

% Parse options.
opt = passvalopt('model.srf', varargin{:});

% Convert char list to cellstr.
if ischar(lsPar)
    lsPar = regexp(lsPar, '\w+', 'match');
end

%--------------------------------------------------------------------------

nAlt = length(this);
ixy = this.Quantity.Type==TYPE(1);
ixx = this.Quantity.Type==TYPE(2);
ixe = this.Quantity.Type==TYPE(31) | this.Quantity.Type==TYPE(32);
ixp = this.Quantity.Type==TYPE(4);
ixg = this.Quantity.Type==TYPE(5);

if nAlt>1
    utils.error('model:diffsrf', ...
        ['Cannot run diffsrf( ) on ', ...
        'model objects with multiple parameter variants.']);
end

ell = lookup(this.Quantity, lsPar, TYPE(4));
posPar = ell.PosName;
ixValidName = ~isnan(posPar);
if any(~ixValidName)
    throw( ...
        exception.Base('Model:INVALID_NAME', 'error'), ...
        'parameter ', lsPar{ixValidName} ...
        ); %#ok<GTARG>
end

% Find optimal step for two-sided derivatives.
asgn = this.Variant{1}.Quantity;
p = asgn(1, posPar);
nPar = length(posPar);
h = eps^(1/3) * max([p; ones(size(p))], [ ], 1);

% Assign alternative parameterisations p(i)+h(i) and p(i)-h(i).
this = alter(this, 2*nPar);
P = struct( );
twoSteps = nan(1, nPar);
for i = 1 : nPar
    pp = p(i)*ones(1, nPar);
    pp(i) = p(i) + h(i);
    pm = p(i)*ones(1, nPar);
    pm(i) = p(i) - h(i);
    P.(lsPar{i}) = [pp, pm];
    twoSteps(i) = pp(i) - pm(i);
end
this = assign(this, P);
this = solve(this);

% Simulate SRF for all parameterisations. Do not delog shock responses in
% `srf`; this will be done after differentiation.
opt0 = opt;
opt0.delog = false;
s = srf(this, time, opt0);

% For each simulation, divide the difference from baseline by the size of
% the step.
for i = find(ixy | ixx | ixe | ixg)
    name = this.Quantity.Name{i};
    x = s.(name).data;  
    c = s.(name).Comment;
    nShk = size(x, 2);
    dx = nan(size(x, 1), nShk, nPar);
    dc = cell(1, nShk, nPar);
    for j = 1 : nPar
        dx(:,:,j) = (x(:,:,j) - x(:,:,nPar+j)) / twoSteps(j);
        dc(1,:,j) = strcat(c(1, 1:nShk, j), '/', lsPar{j});
    end
    if opt.delog && this.Quantity.IxLog(i)
        dx = real(exp(dx));
    end
    s.(name).data = dx;
    s.(name).Comment = dc;
    s.(name) = trim(s.(name));
end

% All parameters are reported at the init point.
for i = find(ixp)
    name = this.Quantity.Name{i};
    s.(name) = repmat(asgn(i), 1, nShk, nPar);
end

end
