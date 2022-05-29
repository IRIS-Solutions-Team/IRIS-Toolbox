function [v, dcy, exit] = segment(s, v0)
% segment  Nonlinear simulation of one segment
%
% Backend IRIS function
% No help provided

% -IRIS Macroeconomic Modeling Toolbox
% -Copyright (c) 2007-2022 IRIS Solutions Team

%--------------------------------------------------------------------------

dcy = [ ];
exit = 0;

ny = size(s.Z, 1);
nxx = size(s.T, 1);
nb = size(s.T, 2);
nf = nxx - nb;
ne = size(s.Ea, 1);
nEqtn = length(s.Eqtn);
eqtnNI = s.Selective.EqtnNI;
sgmStr = s.Selective.SegmentString;
ixNonl = s.Selective.IxHash;
nn = sum(ixNonl);
nPerNonl = s.Selective.NPerNonlin;
rangeNonl = 1 : nPerNonl; 
isAnch = ~isempty(s.Anch) && any(s.Anch(:));

% If `Jv` or `Je` is empty because there were too many data points to
% update, call recursive linear simulation instead.
isFastUpd = ~isempty(s.Selective.Jv) && ~isempty(s.Selective.Je);

% __Prepare Exogenized/Endogenized Update__
lastExg = 0;
if isAnch
    % `eaAnch`, `euAnch` do not include init cond.
    % `ixUpdN` does include init cond.
    Je = s.Selective.Je;
    yxxAnch = s.Anch(1:ny+nxx, :);
    eaAnch = s.Anch(ny+nxx+(1:ne), :);
    euAnch = s.Anch(ny+nxx+ne+(1:ne), :);
    lastExg = max([0, find(any(yxxAnch, 1), 1, 'last')]);
    lastEndgA = max([0, find(any(eaAnch, 1), 1, 'last')]);
    lastEndgU = max([0, find(any(euAnch, 1), 1, 'last')]);
    eaAnch = eaAnch(:, 1:lastEndgA);
    euAnch = euAnch(:, 1:lastEndgU);
    ixUpdN = [ false(ny+nxx, 1), repmat(s.Selective.IxUpdN, 1, nPerNonl) ];
end

% __Prepare Nonlinear Update__
nPerUpd = max(nPerNonl, lastExg);
[y, xx] = simulate.linear.plain(s, ...
    s.IsDeviation, s.Alp0, s.Ea, s.Eu, nPerUpd, [ ]);
% Add init condition
yxx = [ [ nan(ny, 1); nan(nf, 1); s.U*s.Alp0 ] , [y; xx] ];
if s.IsDeviation && s.IsAddSstate
    yxx = yxx + [ 
        s.YBar(:, 1+(0:nPerUpd))
        s.XBar(:, 1+(0:nPerUpd))
        ];
    if isAnch
        % Add steady-state lines to tunes because all yxx results here do include
        % the steady-state lines, too. It is easier to add them here than subtract
        % them in doEvalDcy( ).
        s.Tune = s.Tune + [s.YBar(:, 2:end);s.XBar(:, 2:end)];
    end
end
e = s.Ea;
e(:, 1) = e(:, 1) + s.Eu;
e = [ zeros(ne, 1), e ];

Jv = s.Selective.Jv( 1:nnz(s.Selective.IxUpd)*nPerUpd, : );
ixUpd = [ false(ny+nxx, 1), repmat(s.Selective.IxUpd, 1, nPerUpd) ];

% Delog only the variables that enter nonlinear equations.
ixLogUpdN = [s.IxYLog;s.IxXLog] & s.Selective.IxUpdN;
isLogUpdN = any(ixLogUpdN);

% Time vector for evaluating nonlinear equations; take into account
% pre-sample init condition.
tVec = 1 + rangeNonl;

% Current parameter values.
p = real( s.Update.Quantity(1, s.NameType==4) );

% Absolute time within the entire nonlinear simulation for sstate
% references.
tVecAbs = -s.MinT + s.First + rangeNonl - 1;
L = s.L;

solverName = s.Solver.SolverName;

if any(strcmpi(solverName, {'IRIS-qad', 'IRIS-newton', 'IRIS-qnsd'}))
    % IRIS Solver
    [v, dcy, flag] = solver.algorithm.qnsd(@doEvalDcy, v0, s.Solver);
elseif strcmpi(solverName, 'fsolve')
    % Optimization Tbx
    [v, dcy, flag] = fsolve(@doEvalDcy, v0, s.Solver);
elseif strcmpi(solverName, 'lsqnonlin')
    % Optimization Tbx
    [v, ~, dcy, flag] = lsqnonlin(@doEvalDcy, v0, [ ], [ ], s.Solver);
end
flag = double(flag);

v = reshape(v, nn, nPerNonl);
if flag>0
    exit = 1;
else
    exit = -1;
end

% __Failed to Converge__
if exit<0
    doRptFailure( );
end

return

    
    
    function Dcy = doEvalDcy(V)
        yxx1 = yxx;
        doUpdateNonl( );
        e1 = e;
        if isAnch
            doExogenize( );
        end
        
        % Delog variables that occur in nonlinear equations.
        if isLogUpdN
            yxx1(ixLogUpdN, :) = real(exp(yxx1(ixLogUpdN, :)));
        end
        
        % Evaluate discrepancies.
        y1 = yxx1(1:ny, :);
        xx1 = yxx1(ny+1:end, :);
        errMsg = { };
        Dcy = zeros(nEqtn, nPerNonl);
        ixNan = false(1, nEqtn);
        for j = find(ixNonl)
            try
                jDcy = eqtnNI{j}(y1, xx1, e1, p, tVec, L, tVecAbs);
                ixNan(j) = any(~isfinite(jDcy));
                Dcy(j, :) = jDcy;
            catch Err
                errMsg{end+1} = s.Eqtn{j}; %#ok<AGROW>
                errMsg{end+1} = Err.message; %#ok<AGROW>
            end
        end
        Dcy = Dcy(ixNonl, :);
        if any(ixNan) || ~isempty(errMsg)
            doErrors( );
        end
        
        return

        
        
        function doUpdateNonl( )
            if isFastUpd
                yxx1(ixUpd) = yxx1(ixUpd) + Jv*V(:);
            else
                % Incremental simulation of nonlinear addfactors.
                isDeviation = true;
                [addY, addXx] = simulate.linear.plain(s, ...
                    isDeviation, [ ], [ ], [ ], nPerUpd, V);
                yxx1(:, 2:end) = yxx1(:, 2:end) + [ addY; addXx ];
            end
        end 
        
        
        
        function doExogenize( )
            % `S.Ea` and ea1 can go beyond `S.NPerNonl` if there are endogenized
            % anticipated shocks in the future; the data points are only used to update
            % `yxx1` here, and not to evaluate nonlinear equations.
            %
            % `S.Tune` already includes steady-state line, so that the tunes are
            % compatible with the results in `yxx1`.
            [ea1, eu1, addEa, addEu] = ...
                simulate.linear.exogenize(s, s.M, yxx1(:, 2:end), s.Ea, s.Eu);
            if isFastUpd
                yxx1(ixUpdN) = yxx1(ixUpdN) ...
                    + Je*[ addEa(eaAnch); addEu(euAnch) ];
            else
                % Incremental simulation of endogenized shocks.
                isDeviation = true;
                [addY, addXx] = simulate.linear.plain(s, ...
                    isDeviation, [ ], addEa, addEu, nPerNonl, [ ]);
                yxx1(:, 1+(1:nPerNonl)) = yxx1(:, 1+(1:nPerNonl)) ...
                    + [ addY; addXx ];
            end
            e1 = ea1;
            e1(:, 1) = e1(:, 1) + eu1(:, 1);
            e1 = [ zeros(ne, 1), e1 ];
        end
       
        
        
        function doErrors( )
            if ~isempty(errMsg)
                utils.error('simulate:selective:segment', ...
                    ['Error evaluating this nonlinear equation: %s\n ', ...
                    '\tUncle says: %s'], ...
                    errMsg{:});
            end
            if any(ixNan)
                utils.error('simulate:selective:segment', ...
                    ['This nonlinear equation produces ', ...
                    'NaN or Inf: %s'], ...
                    s.Eqtn{ixNan});
            end
        end
    end



    function doRptFailure( )
        if s.IsError
            msgFunc = @(varargin) utils.error(varargin{:});
        else
            msgFunc = @(varargin) utils.warning(varargin{:});
        end
        switch exit
            case -1
                msgFunc('simulate:selective:segment', ...
                    ['Nonlinear simulation #%g, segment %s, ', ...
                    'reached max number of iterations without convergence.'], ...
                    s.ILoop, strtrim(sgmStr));
            case -2
                msgFunc('simulate:selective:segment', ...
                    ['Nonlinear simulation #%g, segment %s, ', ...
                    'crashed at Inf, -Inf, or NaN.'], ...
                    s.ILoop, strtrim(sgmStr));
        end
    end
end
