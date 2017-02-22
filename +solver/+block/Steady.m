classdef Steady < solver.block.Block
    properties
        NeedsRefresh % Refresh dynamic links.
    end
    
    
    
    
    properties (Constant)
        STEADY_SHIFT = 10
        
        % Make sure the time array of quantities is a matrix (not a col vector),
        % so that XX(XX2L) is always a row vector, and reshape works.
        MAX_FROM_SHIFT = -1
        
        MIN_TO_SHIFT = 0
    end
    
    
    
    
    methods
        function this = Steady(varargin)
            this = this@solver.block.Block(varargin{:});
            this.D = struct( ...
                'Level', [ ], ...
                'Growth0', [ ], ...
                'GrowthK', [ ] ...
                );
        end
        
        
        
        
        function [lx, gx, exitStatus, error] = run(this, lx, gx, ixLog)
            exitStatus = true;
            error = struct( ...
                'EvaluatesToNan', [ ] ...
                );
            
            posl = this.PosQty.Level;
            posg = this.PosQty.Growth;
            if isempty(posl) && isempty(posg)
                return
            end
            
            needsRefresh = this.NeedsRefresh;
            retGradient = this.RetGradient;
            sh = this.Shift;
            nsh = length(sh);
            t0 = find(sh==0);
            fnEval = this.FnEval;
            nl = length(posl);
            ixLogZ = [ ixLog(posl), ixLog(posg) ];
            nRow = length(this.PosEqn);
            nCol = length(posl) + length(posg);
            
            if this.Type==solver.block.Type.SOLVE
                % SOLVE Block
                %-------------
                % Initialize endogenous level and growth unknowns.
                z0 = [ lx(posl), gx(posg) ];
                % Transform initial conditions for log variables before we check bounds;
                % bounds are in logs for log variables.
                z0(ixLogZ) = log(abs( z0(ixLogZ) ));
                %* Make sure init conditions are within bounds.
                %* Empty bounds if all are Inf.
                %* Bounds are in logs for log variables.
                chkInitBounds( );
                % Test all equations in this block for NaNs and Infs.
                XX = timeArray(0);
                chk = fnEval(XX, t0);
                ix = ~isfinite(chk);
                if any(ix)
                    error.EvaluatesToNan = this.PosEqn(ix);
                    return
                end
                [z, exitFlag] = solve(this, @objective, z0);
                z(ixLogZ) = exp( z(ixLogZ) );
            else
                % ASSIGN_* Block
                %----------------
                z = assign( );
                exitFlag = 1;
            end
            
            lx(posl) = z(1:nl);
            gx(posg) = z(nl+1:end);
            exitStatus = all(isfinite(z)) && double(exitFlag)>0;
            
            return
            
            
            
            
            function z = assign( )
                % Assignment
                %------------
                % Vectors posl and posg are each either empty or scalar at this point.
                fnInv = this.Type.InvTransform;
                z = [ ];
                XX = timeArray(0);
                y0 = fnEval(XX, t0);
                if ~isempty(fnInv)
                    y0 = fnInv(y0);
                end
                if ~isempty(posl)
                    z = [z, real(y0)];
                end
                if ~isempty(posg)
                    if imag(y0)~=0
                        z = [ z, imag(y0) ];
                    else
                        XX = timeArray(this.STEADY_SHIFT);
                        yk = fnEval(XX, t0);
                        if ~isempty(fnInv)
                            yk = fnInv(yk);
                        end
                        if ixLog(posg)
                            z = [ z, (yk/y0)^(1/this.STEADY_SHIFT) ];
                        else
                            z = [ z, (yk-y0)/this.STEADY_SHIFT ];
                        end
                    end
                end
                exitFlag = 1;
            end
            
            
            
            
            function chkInitBounds( )
                ixOutOfBnds = z0<this.Lower | z0>this.Upper;
                ixLowerInf = isinf(this.Lower);
                ixUpperInf = isinf(this.Upper);
                ix = ixOutOfBnds & ~ixLowerInf & ~ixUpperInf;
                z0(ix) = (this.Lower(ix) + this.Upper(ix))/2;
                ix = ixOutOfBnds & ~ixLowerInf;
                z0(ix) = this.Lower(ix);
                ix = ixOutOfBnds & ~ixUpperInf;
                z0(ix) = this.Upper(ix);
            end
            
            
            
            
            function [y, j] = objective(z)
                % Solver is requesting gradient but gradient was not
                % prepared; this never happens with IRIS or Optim Tbx
                % solvers as long as PrepareGradient=@auto.
                if nargout>1 && ~retGradient
                    throw( ...
                        exception.Base('Solver:SteadyGradientRequestedButNotPrepared', 'error') ...
                        ); 
                end
                % Delogarithmize log variables; variables in steady equations are expected
                % to be in original levels.
                z = real(z);
                if any(ixLogZ)
                    z(ixLogZ) = exp( z(ixLogZ) );
                end
                
                % Split the input vector of unknows into levels and growth rates; nlx is
                % the number of levels in the input vector.
                lx(posl) = z(1:nl);
                gx(posg) = z(nl+1:end);
                
                % Refresh all dynamic links in each iteration if needed.
                if needsRefresh
                    this.Variant{iAlt}.Quantity = lx + 1i*gx;
                    this = refresh(this, iAlt);
                    lx = real( this.Variant{iAlt}.Quantity );
                    gx = imag( this.Variant{iAlt}.Quantity );
                    gx(ixLog & gx==0) = 1;
                end
                
                XX = timeArray(0); % An extra row of ones is added as the last row.
                y = fnEval(XX, t0);
                
                if nargout>1 && retGradient
                    j = cellfun( ...
                        @(Gradient, XX2L, DLevel, DGrowth0) ...
                        Gradient(XX, t0) .* XX(XX2L) * [DLevel, DGrowth0] , ...
                        ...
                        this.Gradient(1, :), ...
                        this.XX2L, ...
                        this.D.Level, ...
                        this.D.Growth0, ...
                        ...
                        'UniformOutput', false ...
                        );
                    j = reshape([j{:}], nCol, nRow).';
                end
                
                if ~isempty(posg)
                    % Some growth rates need to be calculated. Evaluate the model equations at
                    % time t and t+STEADY_SHIFT if at least one growth rate is needed.
                    XXk = timeArray(this.STEADY_SHIFT);
                    yk = fnEval(XXk, t0);
                    y = [ y ; yk ];
                    if nargout>1 && retGradient
                        jk = cellfun( ...
                            @(Gradient, XX2L, DLevel, DGrowthK) ...
                            Gradient(XXk, t0) .* XXk(XX2L) * [DLevel, DGrowthK] , ...
                            ...
                            this.Gradient(1, :), ...
                            this.XX2L, ...
                            this.D.Level, ...
                            this.D.GrowthK, ...
                            ...
                            'UniformOutput', false ...
                            );
                        jk = reshape([jk{:}], nCol, nRow).';
                        j = [ j; jk ];
                    end
                end
            end
            
            
            
            
            function XX = timeArray(k)
                XX = repmat(lx.', 1, nsh);
                XX(~ixLog, :) = XX(~ixLog, :)  + bsxfun(@times, gx(~ixLog).', sh+k);
                XX( ixLog, :) = XX( ixLog, :) .* bsxfun(@power, gx( ixLog).', sh+k);
                XX(end+1, :) = 1;
            end
        end
    end
    
    
    
    
    methods       
        function prepareBlock(this, blz, opt)
            prepareBlock@solver.block.Block(this, blz, opt);
            
            % Prepare function handles and auxiliary matrices for gradients.
            this.RetGradient = opt.PrepareGradient && this.Type==solver.block.Type.SOLVE;
            if this.RetGradient
                [this.Gradient, this.XX2L, this.D.Level, this.D.Growth0, this.D.GrowthK] = ...
                    createFnGradient(this, blz, opt);
            end
            
            
            % Split PosQty into Level and Growth.
            this.PosQty = struct( ...
                'Level', this.PosQty, ...
                'Growth', this.PosQty ...
                );
        end
        
        
        
        
        function exclude(this, posExclude)
            % Exclude levels fixed by user.
            if ~isempty(posExclude.Level)
                [this.PosQty.Level, this.D.Level] = ...
                    do(this.PosQty.Level, posExclude.Level, this.D.Level);
            end
            % Exclude growth rates fixed by user.
            if ~isempty(posExclude.Growth) 
                [this.PosQty.Growth, this.D.Growth0, this.D.GrowthK] = ...
                    do(this.PosQty.Growth, posExclude.Growth, this.D.Growth0, this.D.GrowthK);
            end
            
            return
            
            function [pos, varargout] = do(pos, posExclude, varargin)
                varargout = varargin;
                [pos, keep] = setdiff(pos, posExclude, 'stable');
                for i = 1 : length(varargout)
                    if ~isempty(varargout{i})
                        D = varargout{i};
                        D = cellfun(@(x) x(:, keep), D, 'UniformOutput', false);
                        varargout{i} = D;
                    end
                end
            end
        end
    end
end
