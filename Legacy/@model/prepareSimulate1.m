function s = prepareSimulate1(this, s, opt, displayMode, varargin)
% prepareSimulate1  Prepare loop-independent data
%
% Backend IRIS function
% No help provided

% -IRIS Macroeconomic Modeling Toolbox
% -Copyright (c) 2007-2022 IRIS Solutions Team

[ny, nxx] = sizeSolution(this.Vector);
ixLog = this.Quantity.IxLog;
ixy = this.Quantity.Type==1; 
ixe = this.Quantity.Type==31 | this.Quantity.Type==32;
ixp = this.Quantity.Type==4;
ixg = this.Quantity.Type==5; 
nEqtn = length(this.Equation);
ixu = any(this.Equation.Type==5);
ixh = this.Equation.IxHash;

s.Method = opt.Method;
s.IsDeviation = opt.Deviation;
s.IsAddSstate = opt.AddSteady;
s.IsContributions = opt.Contributions;
s.IsAnticipate = opt.Anticipate;
s.IsDeterministicTrends = opt.EvalTrends;
if isequal(s.IsDeterministicTrends, @auto)
    s.IsDeterministicTrends = ~s.IsDeviation;
end
s.IsError = opt.Error;
s.Eqtn = this.Equation.Input;
s.NameType = this.Quantity.Type;
s.IxYLog = ixLog(real(this.Vector.Solution{1})).';
s.IxXLog = ixLog(real(this.Vector.Solution{2})).';
s.IxObserved = ixy;
s.IxShocks = ixe;
s.IxParameters = ixp;
s.IxExogenous = ixg;

if s.IsDeterministicTrends
    ixd = this.Equation.Type==3;
    s.DeterministicTrend = struct( );
    s.DeterministicTrend.Equations = cell(1, nEqtn);
    s.DeterministicTrend.Equations(ixd) = this.Equation.Dynamic(ixd);
    s.DeterministicTrend.Pairing = this.Pairing.Dtrends;
end

s.NPerNonlin = 0;
if strcmpi(s.Method, 'Selective')
    if any(ixh)
        s.NPerNonlin = opt.NonlinWindow;
        if isequal(s.NPerNonlin, @all)
            s.NPerNonlin = s.NPer;
        end
        s.ZerothSegment = 0;
        if s.NPerNonlin==0
            s.Method = 'FirstOrder';
        end
    else
        utils.warning('model:prepareSimulate1', ...
            ['No nonlinear equations marked in the model file. ', ...
            'Switching to first-order simulation.']);
        s.Method = 'FirstOrder';
    end
end

s.RequiredForward = max([1, s.LastEa, s.LastEndgA, s.NPerNonlin]) - 1;

if strcmpi(s.Method, 'Selective')
    s.Selective = struct( );
    s.Selective.IxHash = ixh;
    s.Selective.UpperBnd = opt.UpperBound;
    s.Selective.IsFillOut = opt.FillOut;
    s.Selective.ReduceLmb = opt.ReduceLambda;
    s.Selective.MaxNumelJv = opt.MaxNumelJv;
    label = getLabelOrInput(this.Equation);
    s.Selective.EqtnLabelN = label(ixh);
        
    herePrepareHashEquations( );

    defaultSolver = 'IRIS-QaD';
    silent = lower(string(displayMode))=="silent";
    s.Solver = solver.Options.parseOptions(opt.Solver, defaultSolver, silent, varargin{:});

    % Positions of variables in [y;xx] vector that occur in nonlinear
    % equations. These will be combined with positions of exogenized variables
    % in each segment.
    ixXUpdN = false(nxx, 1);
    tkn = regexp(s.Selective.EqtnNI, '\<xi\>\((\d+)', 'tokens');
    for i = 1 : numel(tkn)
        if isempty(tkn{i})
            continue
        end
        temp = [tkn{i}{:}];
        ix = eval(['[', sprintf('%s, ', temp{:}), ']']);
        ixXUpdN(ix) = true;
    end
    s.Selective.IxUpdN = [false(ny, 1); ixXUpdN];
    s.Selective.NOptimLambda = double(opt.NOptimLambda);
    s.Selective.NShanks = opt.NShanks;
    
    for ii = find(ixh)
        s.Selective.EqtnNI{ii} = [ model.PREAMBLE_HASH, s.Selective.EqtnNI{ii} ];
        s.Selective.EqtnNI{ii} = str2func(s.Selective.EqtnNI{ii});
    end
end

return


    function herePrepareHashEquations( )
        s.Selective.EqtnNI = cell(1, nEqtn);
        s.Selective.EqtnNI(ixh) = createHashEquations(this, ixh);
        s.Selective.EqtnN = [ model.PREAMBLE_HASH, '[', s.Selective.EqtnNI{ixh}, ']' ];
        s.Selective.EqtnN = str2func(s.Selective.EqtnN);
    end%
end%

