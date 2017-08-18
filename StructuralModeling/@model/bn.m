function outp = bn(this, inp, range, varargin)
% bn  Beveridge-Nelson trends.
%
% __Syntax__
%
%     Outp = bn(M, Inp, Range, ...)
%
%
% __Input Arguments__
%
% * `M` [ model ] - Solved model object.
%
% * `Inp` [ struct | cell ] - Input data on which the BN trends will be
% computed.
%
% * `Range` [ numeric | char ] - Date range on which the BN trends will be
% computed.
%
%
% __Output Arguments__
%
% * `Outp` [ struct | cell ] - Output data with the BN trends.
%
%
% __Options__
%
% * `'Deviations='` [ `true` | *`false`* ] - Input and output data are
% deviations from balanced-growth paths.
%
% * `'Dtrends='` [ *`@auto`* | `true` | `false` ] - Measurement variables
% in input and output data include deterministic trends specified in
% [`!dtrends`](modellang/dtrends) equations.
%
%
% __Description__
%
% The BN decomposition is accurate only if the input data have been
% generated using unanticipated shocks.
%
%
% __Example__
%

% -IRIS Macroeconomic Modeling Toolbox.
% -Copyright (c) 2007-2017 IRIS Solutions Team.

EYE_TOLERANCE = this.Tolerance.Solve;
TYPE = @int8;

% Parse required input arguments.
pp = inputParser( );
pp.addRequired('Inp', @(x) isstruct(x) || iscell(x));
pp.addRequired('Range', @DateWrapper.validateDateInput);
pp.parse(inp, range);

opt = passvalopt('model.bn', varargin{:});

if ischar(range)
    range = textinp2dat(range);
end

%--------------------------------------------------------------------------

[~, ~, nb, nf, ne] = sizeOfSolution(this.Vector);
nAlt = length(this);
range = range(1) : range(end);
nPer = length(range);

% Alpha vector.
A = datarequest('alpha', this, inp, range);
nData = size(A, 3);

% Exogenous variables including ttrend.
G = datarequest('g', this, inp, range);

% Total number of output data sets.
nLoop = max([nData, nAlt]);

% Pre-allocate hdataobj for output data.
hd = hdataobj(this, range, nLoop, 'IncludeLag=', false);

ixSolved = true(1, nAlt);
ixDiffStat = true(1, nAlt);
testEye = @(x) all(all(abs(x - eye(size(x)))<=EYE_TOLERANCE));

for iLoop = 1 : nLoop
    
    g = G(:, :, min(iLoop, end));
    if iLoop <= nAlt
        T = this.solution{1}(:, :, iLoop);
        Tf = T(1:nf, :);
        Ta = T(nf+1:end, :);
        
        % Continue immediate if solution is not available.
        ixSolved(iLoop) = all(~isnan(T(:)));
        if ~ixSolved(iLoop)
            continue
        end
        
        nUnit = sum(this.Variant{iLoop}.Stability==TYPE(1));
        if ~testEye(Ta(1:nUnit, 1:nUnit))
            ixDiffStat(iLoop) = false;
            continue
        end
        Z = this.solution{4}(:, :, iLoop);
        U = this.solution{7}(:, :, iLoop);
        if ~opt.deviation
            Ka = this.solution{3}(nf+1:end, 1, iLoop);
            aBar = zeros(nb, 1);
            aBar(nUnit+1:end) = ...
                (eye(nb-nUnit) - Ta(nUnit+1:end, nUnit+1:end)) ...
                \ Ka(nUnit+1:end);
            aBar = repmat(aBar, 1, nPer);
            Kf = this.solution{3}(1:nf, 1, iLoop);
            Kf = repmat(Kf, 1, nPer);
            D = this.solution{6}(:, 1, iLoop);
            D = repmat(D, 1, nPer);
        end
        if opt.dtrends
            W = evalDtrends(this, [ ], g, iLoop);
        end
    end
    
    a = A(:, :, min(iLoop, end));
    if ~opt.deviation
        a = a - aBar;
    end
    
    % Forward cumsum of stable alpha.
    aCum = (eye(nb-nUnit) - Ta(nUnit+1:end, nUnit+1:end)) ...
        \ a(nUnit+1:end, :);
    
    % Beveridge Nelson for non-stationary variables.
    a(1:nUnit, :) = a(1:nUnit, :) + ...
        Ta(1:nUnit, nUnit+1:end)*aCum;
    
    if opt.deviation
        a(nUnit+1:end, :) = 0;
    else
        a(nUnit+1:end, :) = aBar(nUnit+1:end, :);
    end
    
    xf = Tf*a;
    xb = U*a;
    y = Z*a;
    
    if ~opt.deviation
        xf = xf + Kf;
        y = y + D;
    end
    if opt.dtrends
        y = y + W;
    end
    
    % Store output data #iloop.
    x = [xf;xb];
    e = zeros(ne, nPer);
    hdataassign(hd, iLoop, { y, x, e, [ ], g } );
    
end

% Report NaN solutions.
if ~all(ixSolved)
    utils.warning('model:bn', ...
        'Solution(s) not available %s.', ...
        exception.Base.alt2str(~ixSolved) );
end

% Parameterisations that are not difference-stationary.
if any(~ixDiffStat)
    utils.warning('model:bn', ...
        ['Cannot run Beveridge-Nelson on models with ', ...
        'I(2) or higher processes %s.'], ...
        exception.Base.alt2str(~ixDiffStat) );
end

% Create output database from hdataobj.
outp = hdata2tseries(hd);

end
