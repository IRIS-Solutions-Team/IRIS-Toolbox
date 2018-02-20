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
% [`!dtrends`](irislang/dtrends) equations.
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
% -Copyright (c) 2007-2018 IRIS Solutions Team.

EYE_TOLERANCE = this.Tolerance.Solve;
TYPE = @int8;

persistent INPUT_PARSER
if isempty(INPUT_PARSER)
    INPUT_PARSER = extend.InputParser('model/bn');
    INPUT_PARSER.addRequired('Model', @(x) isa(x, 'model') && length(x)>=1 && ~any(isnan(x, 'solution')));
    INPUT_PARSER.addRequired('InputDatabank', @isstruct);
    INPUT_PARSER.addRequired('Range', @DateWrapper.validateDateInput);
end
INPUT_PARSER.parse(this, inp, range);

opt = passvalopt('model.bn', varargin{:});

if ischar(range)
    range = textinp2dat(range);
end

%--------------------------------------------------------------------------

[~, ~, nb, nf, ne] = sizeOfSolution(this.Vector);
nv = length(this);
range = range(1) : range(end);
nPer = length(range);

% Alpha vector.
A = datarequest('alpha', this, inp, range);
numDataSets = size(A, 3);

% Exogenous variables including ttrend.
G = datarequest('g', this, inp, range);

% Total number of output data sets.
numRuns = max([numDataSets, nv]);

% Pre-allocate hdataobj for output data.
hd = hdataobj(this, range, numRuns, 'IncludeLag=', false);

indexSolutionAvailable = true(1, nv);
indexDiffStationary = true(1, nv);
testEye = @(x) all(all(abs(x - eye(size(x)))<=EYE_TOLERANCE));

for ithRun = 1 : numRuns
    g = G(:, :, min(ithRun, end));
    if ithRun<=nv
        [T, ~, K, Z, ~, D, U] = getIthFirstOrderSolution(this.Variant, ithRun);
        numUnitRoots = getNumOfUnitRoots(this.Variant, ithRun);

        Tf = T(1:nf, :);
        Ta = T(nf+1:end, :);
        
        % Continue immediate if solution is not available.
        indexSolutionAvailable(ithRun) = all(~isnan(T(:)));
        if ~indexSolutionAvailable(ithRun)
            continue
        end
        
        if ~testEye(Ta(1:numUnitRoots, 1:numUnitRoots))
            indexDiffStationary(ithRun) = false;
            continue
        end
        if ~opt.deviation
            Ka = K(nf+1:end, 1); 
            aBar = zeros(nb, 1);
            aBar(numUnitRoots+1:end) = ...
                (eye(nb-numUnitRoots) - Ta(numUnitRoots+1:end, numUnitRoots+1:end)) ...
                \ Ka(numUnitRoots+1:end);
            aBar = repmat(aBar, 1, nPer);
            Kf = K(1:nf, 1);
            Kf = repmat(Kf, 1, nPer);
            D = repmat(D, 1, nPer);
        end
        if opt.dtrends
            W = evalDtrends(this, [ ], g, ithRun);
        end
    end
    
    a = A(:, :, min(ithRun, end));
    if ~opt.deviation
        a = a - aBar;
    end
    
    % Forward cumsum of stable alpha.
    aCum = (eye(nb-numUnitRoots) - Ta(numUnitRoots+1:end, numUnitRoots+1:end)) ...
        \ a(numUnitRoots+1:end, :);
    
    % Beveridge Nelson for non-stationary variables.
    a(1:numUnitRoots, :) = a(1:numUnitRoots, :) + ...
        Ta(1:numUnitRoots, numUnitRoots+1:end)*aCum;
    
    if opt.deviation
        a(numUnitRoots+1:end, :) = 0;
    else
        a(numUnitRoots+1:end, :) = aBar(numUnitRoots+1:end, :);
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
    hdataassign(hd, ithRun, { y, x, e, [ ], g } );
end

% Report NaN solutions.
if ~all(indexSolutionAvailable)
    utils.warning('model:bn', ...
        'Solution(s) not available %s.', ...
        exception.Base.alt2str(~indexSolutionAvailable) );
end

% Parameterisations that are not difference-stationary.
if any(~indexDiffStationary)
    utils.warning('model:bn', ...
        ['Cannot run Beveridge-Nelson on models with ', ...
        'I(2) or higher processes %s.'], ...
        exception.Base.alt2str(~indexDiffStationary) );
end

% Create output database from hdataobj.
outp = hdata2tseries(hd);

end
