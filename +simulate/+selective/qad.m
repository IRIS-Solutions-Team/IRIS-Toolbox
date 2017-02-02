function [V, Dcy, Exit] = qad(EvalFn, V0, Opt)
% simulate.selective.qad  Quick-and-dirty equation-selective nonlinear simulation algorithm.
%
% Backed IRIS function.
% No help provided.

% -IRIS Macroeconomic Modeling Toolbox.
% -Copyright (c) 2007-2017 IRIS Solutions Team.

N_OPTIM_LAMBDA = 10;
MIN_ITER_SHANKS = 10;

%--------------------------------------------------------------------------

lmb = Opt.Lambda;
reduceLmb = Opt.ReduceLmb;
upperBnd = Opt.UpperBnd;
tol = Opt.Tolerance;
maxIter = Opt.MaxIter;
isFillOut = Opt.IsFillOut;
eqtnLabelN = Opt.EqtnLabelN;
nShanks = Opt.NShanks;
isShanks = isnumericscalar(nShanks) && isfinite(nShanks) && nShanks>0;
sgmStr = Opt.SegmentString;

curr = struct( );
curr.Dcy = [ ];
curr.MaxDcy = [ ];
curr.V = V0;
curr.VHist = [ ];
curr.Iter = NaN;

best = curr;
best.MaxDcy = Inf;

Exit = 0;
iter = 0;

while true
    % Simulate and compute discrepancies
    curr.Dcy = EvalFn(curr.V);

    % Try Shanks acceleration.
    if isShanks && mod(iter,nShanks)==0 ...
            && size(curr.VHist,2)>MIN_ITER_SHANKS
        act = doShanks( );
        if strcmp(act,'acceleration')
            doRptAcceleration( );
        end
    end
    
    % Calculate max abs discrepancy and set exit flag.
    doMaxDcy( );
    
    % Report discrepancies in this iteration if requested or if
    % this is the final iteration.
    if Exit~=0
        doExit( );
        break
    elseif Opt.Display>0 && mod(iter,Opt.Display)==0
        doRptIter( );
    end
    
    % Grid search to optimize lambda between iterations 0 and 1.
    if iter<Opt.NOptimLambda
        doOptimLmb( );
        doRptOptimLmb( );
    end
    
    % Update lambda.
    act = doUpdLmb( );
    if strcmp(act,'reduction')
        doRptReduction( );
    end        
    
    iter = iter + 1;
end

return



    function doOptimLmb( )
        lmbVec = linspace(0,Opt.Lambda,N_OPTIM_LAMBDA+1);
        lmbVec = lmbVec(2:end);
        dVec = zeros(1,N_OPTIM_LAMBDA);
        for i = 1 : N_OPTIM_LAMBDA
            v = curr.V - lmbVec(i)*curr.Dcy;
            d = EvalFn(v);
            dVec(i) = maxabs(d(:));
        end
        [~,ixMin] = min(dVec);
        lmb = lmbVec(ixMin);        
    end % doOptimLmb



    function doMaxDcy( )
        % Maximum discrepancy; transpose `Dcy` so that `PosMaxDcy` can be used to
        % determine the equation in which `MaxDcy` occurs.
        absDcy = abs(curr.Dcy).';
        [curr.MaxDcy,curr.PosMaxDcy] = max(absDcy(:));
        if curr.MaxDcy<best.MaxDcy
            best = curr;
            best.Iter = iter;
        end
        if ~isfinite(curr.MaxDcy)
            Exit = -2;
        elseif curr.MaxDcy<=tol
            Exit = 1;
        elseif iter>=maxIter
            Exit = -1;
        end
    end % doMaxDcy( )



    function doExit( )
        if curr.MaxDcy>best.MaxDcy
            curr = best;
            doRptReversion( );
        end
        doRptIter( );
        V = curr.V;
        Dcy = curr.Dcy;        
    end % doExit( )



    function Act = doShanks( )
        v1 = curr.VHist(:,end);
        v2 = curr.VHist(:,end-1);
        v3 = curr.VHist(:,end-2);
        ixV = (abs(v1)+abs(v2)+abs(v3))/3>tol;
        v1 = v1(ixV);
        v2 = v2(ixV);
        v3 = v3(ixV);
        % One number in Shanks sequence built from last three points.
        sh = v3 - (v3-v2).^2 ./ (v1-2*v2+v3);
        ixFinite = isfinite(sh);
        sh(~ixFinite) = v1(~ixFinite);
        vv = curr.V(:);
        vv(ixV) = sh;
        vv = reshape(vv,size(curr.V));
        % Update to Shanks sequence now if it outperforms current V.
        Act = 'none';
        try %#ok<TRYNC>
            dcy = EvalFn(vv);
            if max(abs(dcy(:)))<max(abs(curr.Dcy(:)))
                curr.V(:) = vv;
                curr.Dcy = dcy;
                Act = 'acceleration';
            end
        end
    end % doShanks( )



    function Act = doUpdLmb( )
        ixBounded = curr.MaxDcy<best.MaxDcy*upperBnd;
        if all(ixBounded)
            addV = curr.Dcy;
            if ~isFillOut
                addV(abs(addV)<=tol) = 0;
            end
            curr.V = curr.V - lmb * addV;
            if isShanks
                curr.VHist = [curr.VHist,curr.V(:)];
            end
            Act = 'update';
        else
            % If the current discrepancy is `upperBound` times the historical minimum
            % (or more), reverse the process to the historical minimum, and reduce
            % `lambda`.
            curr = best;
            lmb = lmb * reduceLmb;
            Act = 'reduction';
        end        
    end % doUpdLmb( )



    function doRptIter( )
        if Opt.Display==0
            return
        end
        if iter==0
            % Print header in zeroth iteration.
            fprintf('%16s %6.6s %8.8s %12.12s %-20.20s\n',...
                'Segment#NPer','Iter','Lambda','Max.discrep','Equation');
        end
        countStr = sprintf(' %5g',iter);
        if Exit~=0
            countStr = strrep(countStr,' ','=');
        end
        lmbStr = sprintf('%8g',lmb);
        maxDcyStr = sprintf('%12g',curr.MaxDcy);
        maxDcyEqtn = ceil(curr.PosMaxDcy/size(curr.Dcy,2));
        maxDcyLbl = eqtnLabelN{maxDcyEqtn};
        maxDcyLbl = textfun.ellipsis(maxDcyLbl,20);
        % Print current report line.
        fprintf('%s %s %s %s %s\n',...
            sgmStr,countStr,lmbStr,maxDcyStr,maxDcyLbl);
        if Exit~=0
            fprintf('\n');
        end
    end % doRptIter( )    



    function doRptReduction( )
        if Opt.Display==0
            return
        end
        doRptReversion( );
        fprintf('  Reducing lambda to %g.\n',lmb);
    end % doRptReduction( )



    function doRptReversion( )
        if Opt.Display==0
            return
        end
        fprintf('  Reversing to iteration %g.\n',best.Iter);
    end



    function doRptAcceleration( )
        if Opt.Display==0
            return
        end
        fprintf('  Shanks acceleration.\n');
    end % doRptAcceleration( )



    function doRptOptimLmb( )
        if Opt.Display==0
            return
        end
        fprintf('  Optimal lambda %g.\n',lmb);
    end % doRptAcceleration( )
end
