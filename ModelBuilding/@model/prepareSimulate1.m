function s = prepareSimulate1(this, s, opt)
% prepareSimulate1  Prepare loop-independent data.
%
% Backend IRIS function.
% No help provided.

% -IRIS Macroeconomic Modeling Toolbox.
% -Copyright (c) 2007-2018 IRIS Solutions Team.

TYPE = @int8;

%--------------------------------------------------------------------------

[ny, nxx] = sizeOfSolution(this.Vector);
ixLog = this.Quantity.IxLog;
ixy = this.Quantity.Type==TYPE(1); 
ixe = this.Quantity.Type==TYPE(31) | this.Quantity.Type==TYPE(32);
ixp = this.Quantity.Type==TYPE(4);
ixg = this.Quantity.Type==TYPE(5); 
nEqtn = length(this.Equation);
ixu = any(this.Equation.Type==TYPE(5));
ixh = this.Equation.IxHash;

% Bkw compatibility.
if isfield(opt, 'nonlinear') && ~isempty(opt.nonlinear)
    % ##### Feb 2015 OBSOLETE and scheduled for removal.
    utils.warning('obsolete', ...
        ['Option nonlinear= is obsolete, and ', ...
        'will be removed from IRIS in a future release. ', ...
        'Use new options Method= and NonlinWindow= instead.']);
    opt.Method = 'selective';
    opt.NonlinWindow = opt.nonlinear;
end

s.Method = lower(opt.Method);
s.Solver = lower(opt.Solver);
s.Display = lower(opt.Display);
s.IsDeviation = opt.deviation;
s.IsAddSstate = opt.addsstate;
s.IsContributions = opt.contributions;
s.IsAnticipate = opt.anticipate;
s.IsDeterministicTrends = opt.dtrends;
if isequal(s.IsDeterministicTrends, @auto)
    s.IsDeterministicTrends = ~s.IsDeviation;
end
s.IsError = opt.error;
s.Eqtn = this.Equation.Input;
s.NameType = this.Quantity.Type;
s.IxYLog = ixLog(real(this.Vector.Solution{1})).';
s.IxXLog = ixLog(real(this.Vector.Solution{2})).';
s.IxObserved = ixy;
s.IxShocks = ixe;
s.IxParameters = ixp;
s.IxExogenous = ixg;

if s.IsDeterministicTrends
    ixd = this.Equation.Type==TYPE(3);
    s.DeterministicTrend = struct( );
    s.DeterministicTrend.Equations = cell(1, nEqtn);
    s.DeterministicTrend.Equations(ixd) = this.Equation.Dynamic(ixd);
    s.DeterministicTrend.Pairing = this.Pairing.Dtrend;
end

s.NPerNonlin = 0;
if isequal(s.Method, 'selective')
    if any(ixh)
        s.NPerNonlin = opt.NonlinWindow;
        if isequal(s.NPerNonlin, @all)
            s.NPerNonlin = s.NPer;
        end
        s.ZerothSegment = 0;
        if s.NPerNonlin==0
            s.Method = 'firstorder';
        end
    else
        utils.warning('model:prepareSimulate1', ...
            ['No nonlinear equations marked in the model file. ', ...
            'Switching to first-order simulation.']);
        s.Method = 'firstorder';
    end
end

s.RequiredForward = max([1, s.LastEa, s.LastEndgA, s.NPerNonlin]) - 1;

if isequal(s.Method, 'selective')
    s.Selective = struct( );
    s.Selective.IxHash = ixh;
    s.Selective.Tolerance = opt.tolerance;
    s.Selective.MaxIter = opt.MaxIter;
    s.Selective.Lambda = opt.lambda;
    s.Selective.UpperBnd = opt.upperbound;
    s.Selective.IsFillOut = opt.fillout;
    s.Selective.ReduceLmb = opt.reducelambda;
    s.Selective.MaxNumelJv = opt.maxnumeljv;
    label = getLabelOrInput(this.Equation);
    s.Selective.EqtnLabelN = label(ixh);
        
    prepareHashEquations( );
    
    if isequal(s.Solver, @auto) ...
            || ( ischar(s.Solver) && strcmpi(s.Solver, 'qad') )
        s.Solver = @qad;
    end
    s.Display = s.Display;
    if isequal(s.Solver, @qad)
        if isequal(s.Display, 'off') || isequal(s.Display, 'on')        
            s.Display = 0;
        elseif isequal(s.Display, @auto) || ~isnumericscalar(s.Display)
            s.Display = 100;
        end
    else
        if isequal(s.Display, @auto)
            s.Display = 'iter';
        end
    end
    s.Selective.Display = s.Display;
    % Positions of variables in [y;xx] vector that occur in nonlinear
    % equations. These will be combined with positions of exogenized variables
    % in each segment.
    ixXUpdN = false(nxx, 1);
    tkn = regexp(s.Selective.EqtnNI, '\<xi\>\((\d+), ', 'tokens');
    for i = 1 : numel(tkn)
        if isempty(tkn{i})
            continue
        end
        temp = [tkn{i}{:}];
        ix = eval(['[', sprintf('%s, ', temp{:}), ']']);
        ixXUpdN(ix) = true;
    end
    s.Selective.IxUpdN = [false(ny, 1); ixXUpdN];
    s.Selective.NOptimLambda = double(opt.noptimlambda);
    s.Selective.NShanks = opt.nshanks;
    
    for ii = find(ixh)
        s.Selective.EqtnNI{ii} = [ ...
            model.PREAMBLE_HASH, ...
            s.Selective.EqtnNI{ii} ...
            ];
        s.Selective.EqtnNI{ii} = str2func(s.Selective.EqtnNI{ii});
    end
end

% Steady-state revisions.
ptrRevision = this.Pairing.Revision;
s.IsRevision = opt.Revision && any(ixu) && any( ptrRevision(ixu)>0 );
if s.IsRevision
    % Initialize and preprocess sstate, chksstate, solve options.
    s.Revision = struct( );
    s.Revision.Steady = prepareSteady(this, 'silent', opt.Steady);
    s.Revision.ChkSstate = prepareChkSteady(this, 'silent', opt.ChkSstate);
    s.Revision.Solve = prepareSolve(this, 'silent', opt.Solve);
    ixRevision = ixu & ptrRevision>0;
    eqnRevision = createHashEquations(this, ixRevision);
    eqnRevision = [ model.PREAMBLE_HASH, '[', eqnRevision{:}, ']' ];
    eqnRevision = str2func(eqnRevision);
    s.Revision.EqtnN = eqnRevision;
    s.Revision.PtrRevision = ptrRevision(ixRevision);
end

if isequal(s.Solver, @lsqnonlin) || isequal(s.Solver, @fsolve)
    opt.Solver = s.Solver;
    opt.Display = s.Display;
    opt.TolFun = model.DEFAULT_STEADY_TOLERANCE;
    opt.TolX = model.DEFAULT_STEADY_TOLERANCE;
    [~, s.OptimSet] = irisoptim.myoptimopts(opt);
end

return



    function prepareHashEquations( )
        s.Selective.EqtnNI = cell(1, nEqtn);
        s.Selective.EqtnNI(ixh) = createHashEquations(this, ixh);
        s.Selective.EqtnN = [ ...
            model.PREAMBLE_HASH, ...
            '[', s.Selective.EqtnNI{ixh}, ']' ...
            ];
        s.Selective.EqtnN = str2func(s.Selective.EqtnN);
    end
end
