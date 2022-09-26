function outp = bn(this, inp, range, varargin)

EYE_TOLERANCE = this.Tolerance.Solve;

persistent pp
if isempty(pp)
    pp = extend.InputParser('model.bn');
    pp.addRequired('SolvedModel', @(x) isa(x, 'model') && length(x)>=1 && ~any(isnan(x, 'solution')));
    pp.addRequired('InputDatabank', @isstruct);
    pp.addRequired('Range', @validate.date);
    pp.addParameter('Deviation', false, @validate.logicaScalar);
    pp.addParameter('EvalTrends', logical.empty(1, 0));
end

opt = pp.parse(this, inp, range, varargin{:});

if isempty(opt.EvalTrends)
    opt.EvalTrends = ~opt.Deviation;
end

%--------------------------------------------------------------------------

[~, ~, nb, nf, ne] = sizeSolution(this.Vector);
nv = length(this);
range = range(1) : range(end);
numPeriods = length(range);

% Alpha vector.
A = datarequest('alpha', this, inp, range);
numDataSets = size(A, 3);

% Exogenous variables including ttrend.
G = datarequest('g', this, inp, range);

% Total number of output data sets.
numRuns = max([numDataSets, nv]);

% Pre-allocate hdataobj for output data.
hd = hdataobj(this, range, numRuns, 'includeLag', false);

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
        if ~opt.Deviation
            Ka = K(nf+1:end, 1); 
            aBar = zeros(nb, 1);
            aBar(numUnitRoots+1:end) = ...
                (eye(nb-numUnitRoots) - Ta(numUnitRoots+1:end, numUnitRoots+1:end)) ...
                \ Ka(numUnitRoots+1:end);
            aBar = repmat(aBar, 1, numPeriods);
            Kf = K(1:nf, 1);
            Kf = repmat(Kf, 1, numPeriods);
            D = repmat(D, 1, numPeriods);
        end
        if opt.EvalTrends
            W = evalTrendEquations(this, [ ], g, ithRun);
        end
    end
    
    a = A(:, :, min(ithRun, end));
    if ~opt.Deviation
        a = a - aBar;
    end
    
    % Forward cumsum of stable alpha.
    aCum = (eye(nb-numUnitRoots) - Ta(numUnitRoots+1:end, numUnitRoots+1:end)) ...
        \ a(numUnitRoots+1:end, :);
    
    % Beveridge Nelson for non-stationary variables.
    a(1:numUnitRoots, :) = a(1:numUnitRoots, :) + ...
        Ta(1:numUnitRoots, numUnitRoots+1:end)*aCum;
    
    if opt.Deviation
        a(numUnitRoots+1:end, :) = 0;
    else
        a(numUnitRoots+1:end, :) = aBar(numUnitRoots+1:end, :);
    end
    
    xf = Tf*a;
    xb = U*a;
    y = Z*a;
    
    if ~opt.Deviation
        xf = xf + Kf;
        y = y + D;
    end
    if opt.EvalTrends
        y = y + W;
    end
    
    % Store output data #iloop.
    x = [xf;xb];
    e = zeros(ne, numPeriods);
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

end%

