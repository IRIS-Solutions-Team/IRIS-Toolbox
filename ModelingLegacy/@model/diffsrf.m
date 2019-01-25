function [s, this] = diffsrf(this, time, lsPar, varargin)
% diffsrf  Differentiate shock response functions w.r.t. specified parameters.
%
% __Syntax__
%
%     S = diffsrf(M, Range, PList, ...)
%     S = diffsrf(M, NPer, PList, ...)
%
%
% __Input Arguments__
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
% __Output Arguments__
%
% * `S` [ struct ] - Database with shock reponse derivatives stowed in
% multivariate time series.
%
%
% __Options__
%
% See [`model/srf`](model/srf) for options available.
%
%
% __Description__
%
%
% __Example__
%

% -IRIS Macroeconomic Modeling Toolbox.
% -Copyright (c) 2007-2019 IRIS Solutions Team.

TYPE = @int8;

% Parse options.
opt = passvalopt('model.srf', varargin{:});

% Convert char list to cellstr.
if ischar(lsPar)
    lsPar = regexp(lsPar, '\w+', 'match');
end

%--------------------------------------------------------------------------

nv = length(this);
ixy = this.Quantity.Type==TYPE(1);
ixx = this.Quantity.Type==TYPE(2);
ixe = this.Quantity.Type==TYPE(31) | this.Quantity.Type==TYPE(32);
ixp = this.Quantity.Type==TYPE(4);
ixg = this.Quantity.Type==TYPE(5);

if nv>1
    utils.error('model:diffsrf', ...
        ['Cannot run diffsrf( ) on ', ...
        'model objects with multiple parameter variants.']);
end

ell = lookup(this.Quantity, lsPar, TYPE(4));
posPar = ell.PosName;
indexOfValidNames = ~isnan(posPar);
if any(~indexOfValidNames)
    throw( ...
        exception.Base('Model:INVALID_NAME', 'error'), ...
        'parameter ', lsPar{indexOfValidNames} ...
        ); %#ok<GTARG>
end

% Find optimal step for two-sided derivatives.
asgn = this.Variant.Values;
p = asgn(1, posPar);
numOfParams = length(posPar);
h = eps^(1/3) * max([p; ones(size(p))], [ ], 1);

% Assign alternative parameterisations p(i)+h(i) and p(i)-h(i).
thisWithSteps = alter(this, 2*numOfParams);
P = struct( );
twoSteps = nan(1, numOfParams);
for i = 1 : numOfParams
    pp = p(i)*ones(1, numOfParams);
    pp(i) = p(i) + h(i);
    pm = p(i)*ones(1, numOfParams);
    pm(i) = p(i) - h(i);
    P.(lsPar{i}) = [pp, pm];
    twoSteps(i) = pp(i) - pm(i);
end
thisWithSteps = assign(thisWithSteps, P);
thisWithSteps = solve(thisWithSteps);

% Simulate SRF for all parameterisations. Do not delog shock responses in
% `srf`; this will be done after differentiation.
opt0 = opt;
opt0.delog = false;
s = srf(thisWithSteps, time, opt0);

% For each simulation, divide the difference from baseline by the size of
% the step.
for i = find(ixy | ixx | ixe | ixg)
    name = this.Quantity.Name{i};
    x = s.(name).Data;  
    c = s.(name).Comment;
    numOfShocks = size(x, 2);
    dx = nan(size(x, 1), numOfShocks, numOfParams);
    dc = cell(1, numOfShocks, numOfParams);
    for j = 1 : numOfParams
        dx(:, :, j) = (x(:, :, j) - x(:, :, numOfParams+j)) / twoSteps(j);
        dc(1, :, j) = strcat(c(1, 1:numOfShocks, j), '/', lsPar{j});
    end
    if opt.delog && this.Quantity.IxLog(i)
        dx = real(exp(dx));
    end
    s.(name).Data = dx;
    s.(name).Comment = dc;
    s.(name) = trim(s.(name));
end

s = addToDatabank({'Parameters', 'Std', 'NonzeroCorr'}, this, s);

end%

