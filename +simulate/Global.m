% Global  Global simulation object.
%
% Backend IRIS class.
% No help provided.

% -IRIS Macroeconomic Modeling Toolbox.
% -Copyright (c) 2007-2017 IRIS Solutions Team.

classdef Global < handle
    properties
        Quantity
        Equation
        Pairing
        
        X % Data matrix including parameters.
        L % Steady level matrix.
        TTrend % Time trend for creating steady references.
        XRange % Simulation range including presample initial condition.
        RunTime % Columns in X to run.
        FnRevision % Functions with revision equations
        PtrRevision % LHS parameters in revision equations
        
        IsDeviation % Deviation from control or full level simulation.
        OptimSet % Optimization Tbx settings.
        WhenFailed = 'warning' % Throw error or warning when simulation fails.
    end
    
    
    
    
    methods
        function outp = run(this, m, opt)
            nAlt = size(this.X, 3);
            blz = prepareBlazer(m, 'Dynamic', opt);
            run(blz);
            nBlk = numel(blz.Block);
            state = struct( ...
                'IAlt', 0, ...
                'Time', 0, ...
                'StrTime', '', ...
                'IBlk', 0 ...
                );
            % Cycle over all parameter variants.
            for iAlt = 1 : nAlt
                state.IAlt = iAlt;
                state.StrAlt = sprintf('%g', iAlt);
                assignParametersUntilEnd(this, m, iAlt, 1);
                L0 = assignSteadyRef(this, m, iAlt);
                needsToBeAssigned = false;
                if this.IsDeviation
                    deviation2level(this, L0, iAlt);
                end
                % Cycle over all periods.
                for t = this.RunTime
                    if needsToBeAssigned
                        assignParametersUntilEnd(this, m, iAlt, t);
                        assignSteadyRef(this, m, iAlt);
                        needsToBeAssigned = false;
                    end
                    state.Time = t;
                    state.StrTime = dat2char(this.XRange(t));
                    % Cycle over all blocks.
                    for iBlk = 1 : nBlk
                        state.IBlk = iBlk;
                        blk = blz.Block{iBlk};
                        if blk.Type==solver.block.Type.SOLVE
                            solveBlock(this, blk, state);
                        else
                            assignBlock(this, blk, state);
                        end
                    end 
                end
                if this.IsDeviation
                    level2deviation(this, L0, iAlt);
                end
            end
            outp = createOutputDatabase(this, m);
        end
        
        
        
        
        function deviation2level(this, L0, iAlt)
            convertDeviation(this, L0, iAlt, @plus, @times);
        end
        

        
        
        function level2deviation(this, L0, iAlt)
            convertDeviation(this, L0, iAlt, @minus, @rdivide);
        end
        
        
        
        
        function convertDeviation(this, L0, iAlt, fnPlain, fnLog)
            TYPE = @int8;
            ixy = this.Quantity.Type==TYPE(1);
            ixx = this.Quantity.Type==TYPE(2);
            ixLog = this.Quantity.IxLog;
            ixPlain = (ixy | ixx) & ~ixLog; % Plain measurement and transition.
            ixLog = (ixy | ixx) & ixLog; % Log measurement and transition.
            this.X(ixPlain, :, iAlt) = fnPlain(this.X(ixPlain, :, iAlt), L0(ixPlain, :));
            this.X(ixLog, :, iAlt) = fnLog(this.X(ixLog, :, iAlt), L0(ixLog, :));
        end
        
        
        
        
        function assignParametersUntilEnd(this, m, iAlt, t)
            TYPE = @int8;
            ixp = this.Quantity.Type==TYPE(4);
            nXPer = size(this.X, 2);
            a = getp(m, 'Assign');
            a = a(1, ixp, min(end, iAlt)).';
            this.X(ixp, t:nXPer, iAlt) = repmat(a, 1, nXPer-t+1);            
        end
        
        
        
        
        function L = assignSteadyRef(this, m, iAlt)
            TYPE = @int8;
            nXPer = length(this.TTrend);
            nQuan = length(this.Quantity);
            ixy = this.Quantity.Type==TYPE(1);
            ixx = this.Quantity.Type==TYPE(2);
            ixe = this.Quantity.Type==TYPE(31) | this.Quantity.Type==TYPE(32);
            posyx = find(ixy | ixx);
            L = nan(nQuan, nXPer);
            L(posyx, :) = createTrendArray(m, iAlt, true, posyx, this.TTrend);            
            L(ixe, :) = 0;
            this.L = L;
        end
        
        
        
        
        function outp = createOutputDatabase(this, m)
            TYPE = @int8;
            ixy = this.Quantity.Type==TYPE(1);
            ixx = this.Quantity.Type==TYPE(2);
            ixe = this.Quantity.Type==TYPE(31) | this.Quantity.Type==TYPE(32);
            ixyxe = ixy | ixx | ixe;
            outp = array2db( ...
                permute(this.X(ixyxe, :, :), [2, 1, 3]), ...
                this.XRange, ...
                this.Quantity.Name(ixyxe) ...
                );
            outp = addparam(m, outp);
        end
        
        
        
        
        function assignBlock(this, blk, state)
            t = state.Time;
            alt = state.IAlt;
            pos = blk.PosQty;
            invTransform = blk.Type.InvTransform;
            xt = blk.FnEval(this.X(:,:,alt), t, this.L(:,:,alt));
            if ~isempty(invTransform)
                xt = invTransform(xt);
            end
            this.X(pos, t, alt) = xt;
        end
        
        
        
        
        function solveBlock(this, blk, state)
            t = state.Time;
            alt = state.IAlt;            
            pos = blk.PosQty;
            ixLog = blk.IxLog;
            X = this.X(:, 1:t, alt); %#ok<PROPLC>
            L = this.L(:, 1:t, alt); %#ok<PROPLC>
            
            fnEval = blk.FnEval;
            
            xt0 = setInitValues( );
            
            this.OptimSet = optimset(this.OptimSet, ...
                'Algorithm', 'levenberg-marquardt');

            [xt, res, exitFlag, outp] = fsolve(@objective, xt0, this.OptimSet);
            if exitFlag<=0
                reportFailure( );
            end
            yf = objective(xt); %#ok<NASGU>
            this.X(pos, t, alt) = X(pos, end); %#ok<PROPLC>
            
            return
            
            
            
            
            function xt0 = setInitValues( )
                xt0 = X(pos, t-1); %#ok<PROPLC>
                % Use steady levels for NaN initial values.
                ixNan = isnan(xt0);
                if any(ixNan)
                    if this.IsDeviation
                        xt0(ixNaN & ixLog) = 1;
                        xt0(ixNaN & ~ixLog) = 0;
                    else
                        xt0(ixNan) = L(pos(ixNan), end); %#ok<PROPLC>
                    end
                end
                xt0(ixLog) = log(xt0(ixLog));              
            end
            
            
            
            function y = objective(x)
                x(ixLog) = exp( x(ixLog) );
                X(pos, end) = x; %#ok<PROPLC>
                if nargout==0
                    return
                end
                y = 100*fnEval(X, t, L); %#ok<PROPLC>
                ixErr = ~isfinite(y) | imag(y)~=0;
                if any(ixErr)
                    lsEqtn = blk.EqtnInput;
                    lsEqtn = lsEqtn(ixErr);
                    reportEvalNaNInfImag(lsEqtn);
                end
            end
            
            
            
            
            function reportFailure( )
                if isequal(this.OptimSet.Display, 'none')
                    disp( outp.message );
                end
                [~, posFail] = max(abs(res));
                posFail = posFail(1);
                throw( ...
                    exception.Base('Global:SOLVE_BLOCK_FAILED', this.WhenFailed), ...
                    state.StrTime, alt, max(abs(res)), ...
                    this.Equation.Input{pos(posFail)} ...
                    ); %#ok<GTARG>
            end
            
            
            
            
            function reportEvalNaNInfImag(lsEqtn)
                throw( ...
                    exception.Base('Global:EVALUATES_TO_NAN_INF_IMAG', 'error'), ...
                    state.StrTime, state.StrAlt, ...
                    lsEqtn{:} ...
                    );
            end
        end
    end
end
