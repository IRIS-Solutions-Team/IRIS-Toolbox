function [Y, Xx, Ea, Eu, P] = mysimulateper(this, s)
% mysimulateper  Simulate period by period.
%
% Backend IRIS function.
% No help provided.

% -IRIS Macroeconomic Modeling Toolbox.
% -Copyright (c) 2007-2017 IRIS Solutions Team.

%--------------------------------------------------------------------------

ny = size(s.Z, 1);
nx = size(s.T, 1);
nb = size(s.T, 2);
nf = nx - nb;
ne = size(s.Ea, 1);
numOfPeriods = s.NPer;
v = min(s.ILoop, length(this));

% Main loop
%-----------
% Set time for nonlinear equation evaluation. We do period by period, hence
% the period being evaluated is always tt=2 (after init cond included).
tt = 2;

% Preallocate output data.
Y = nan(ny, numOfPeriods);
Xx = nan(nx, numOfPeriods);
Ea = s.Ea;
Eu = s.Eu;

if s.IsRevision
    eqtnN = s.Revision.EqtnN;
    ptrRevision = s.Revision.PtrRevision;
    nPtrRevision = length(ptrRevision);
    P = nan(nPtrRevision, numOfPeriods);
end

testFn = @(x) ~any(strcmp(x, {'off', 'none'}));
isDisplay = ...
    (s.IsRevision && testFn(s.Revision.Steady.OptimSet.Display)) ...
    || ...
    (isequal(s.Method, 'global') && testFn(s.OptimSet.Display));

if isDisplay
    numOfDecimals = floor(log10(numOfPeriods)) + 1;
    textfun.loosespace( );
end

for t = 1 : numOfPeriods
    if isDisplay
        rptSolving( );
    end
    
    s.y = [ ];
    s.w = [ ];
    s.x = [ ];
    
    % First-order approx simulation first.
    s.Alp0 = s.U \ s.x0;
    
    ixPer = false(1, numOfPeriods);
    ixPer(t) = true;
    
    s.M = simulate.linear.multipliers(s);
    switch lower(s.Method)
        case 'firstorder'
            [s.y, s.x, s.Ea, s.Eu] = simulate.linear.run(s, 1);
        case 'global'
            [s.y, s.x, s.Ea, s.Eu] = simulate.global.run(s, ixPer);
        otherwise
            utils.error('model:mysimulateper', ...
                ['Function simulate( ) with Revision=true ', ...
                'not implemented yet for method=%s.'], ...
                s.Method);
    end
    
    Y(:, t) = s.y(:, 1);
    Xx(:, t) = s.x(:, 1);
    Ea(:, t) = s.Ea(:, 1);
    Eu(:, t) = s.Eu(:, 1);
    
    % Store current parameters, revisions, solution.
    if s.IsRevision
        P(:, t) = this.Variant.Values(:, ptrRevision, v).';
        if t < numOfPeriods
            runRevisions( );
        end
    end
    
    % Prepare next period.
    s.x0 = s.x(nf+1:end, 1);
    s.Ea(:, 1) = [ ];
    s.Eu(:, 1) = [ ];
    s.G(:, 1) = [ ];
    if ~isempty(s.Anch)
        s.Anch(:, 1) = [ ];
        s.Wght(:, 1) = [ ];
        s.Tune(:, 1) = [ ];
    end
end

return

    
    
    function runRevisions( )
        % Evaluate !revisions and revise parameter values.
        if isDisplay
            rptRevisionParam( );
        end
        
        xx = [ [nan(nf, 1);s.x0], s.x(:, 1) ];
        xx(s.IxXLog, :) = real(exp(xx(s.IxXLog, :)));
        ee = [ nan(ne, 1), s.Ea(:, 1)+s.Eu(:, 1) ];
        yy = [ nan(ny, 1), s.y(:, 1) ];
        pp = real(s.Update.Quantity(1, s.NameType==4));
        LL = s.L;
        % Absolute time within the entire nonlinear simulation for sstate
        % references.
        ttAbs = -s.MinT + t;
        
        % Evaluate steady-state revision equations
        %------------------------------------------
        try
            D = eqtnN(yy, xx, ee, pp, tt, LL, ttAbs);
        catch Err
            utils.error('simulate:mysimulateper', ...
                ['Error evaluating steady-state revision equations at t=%g.\n ', ...
                '\tUncle says: %s'], ...
                t, Err.message);
        end
        
        % Revise steady state
        %---------------------
        D = D(:).';
        ixNonzero = this.Variant.Values(:, ptrRevision, v)~=D;
        if any(ixNonzero)
            if isDisplay
                name = this.Quantity.Name(ptrRevision);
                rptChange( name(ixNonzero) );
                rptRevisionModel( );
            end
            
            s.Update.PosQty = ptrRevision;
            s.Update.PosStdCorr = nan( size(s.PosQty) );
            % Revise steady state and solution.
            isError = true;
            this = update(this, D, s.Update, v, s.Revision, isError);
            % Update this model variant in s.
            s = prepareSimulate2(this, s, v);
        else
            if isDisplay
                rptNoChange( );
            end
        end
    end

    
    
    function rptSolving( )
        fprintf('=====Period %*g/%*g. Solving equations.\n', numOfDecimals, t, numOfDecimals, numOfPeriods);
    end

    
    
    function rptRevisionParam( )
        fprintf('=====Period %*g/%*g. Revising parameters.', ...
            numOfDecimals, t, numOfDecimals, numOfPeriods);
    end

    
    
    function rptChange(List)
        fprintf(' Change in');
        fprintf(' %s', List{:});
        fprintf('.\n');
    end

    
    
    function rptNoChange( )
        fprintf(' No change.\n');
    end

    
    
    function rptRevisionModel( )
        fprintf('=====Period %*g/%*g. Revising steady state and solution.\n', ...
            numOfDecimals, t, numOfDecimals, numOfPeriods);
    end
end
