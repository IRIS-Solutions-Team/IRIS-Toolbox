classdef Dynamic < solver.block.Block
    properties
    end
    
    
    
    
    properties (Constant)
        STEADY_SHIFT = 0
        MAX_FROM_SHIFT = 0        
        MIN_TO_SHIFT = 0
    end
    
    
    
    
    methods
        function this = Dynamic(varargin)
            this = this@solver.block.Block(varargin{:});
        end
        
        
        
        
        function [x, exitStatus, error] = run(this, x, t, L, ixLog)
            exitStatus = true;
            error = struct( ...
                'EvaluatesToNan', [ ] ...
                );
            
            posx = this.PosQty;
            if isempty(posx)
                return
            end
            
            retGradient = this.RetGradient;
            fnEval = this.FnEval;
            ixLogZ = ixLog(posx);
            nRow = length(this.PosEqn);
            nCol = length(posx);
            
            if this.Type==solver.block.Type.SOLVE
                % SOLVE Block
                %-------------
                % Initialize endogenous quantities.
                z0 = x(posx, t);
                ixNan = isnan(z0);
                if any(ixNan) && t>1
                    z0(ixNan) = x(posx(ixNan), t-1);
                end
                ixNan = isnan(z0);
                if any(ixNan)
                    z0(ixNan) = 1;
                end
                % Transform initial conditions for log variables before we check bounds;
                % bounds are in logs for log variables.
                z0(ixLogZ) = log(abs( z0(ixLogZ) ));
                %* Make sure init conditions are within bounds.
                %* Empty bounds if all are Inf.
                %* Bounds are in logs for log variables.
                chkInitBounds( );
                % Test all equations in this block for NaNs and Infs.
                chk = objective(z0);
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
            
            x(posx, t) = z;
            exitStatus = all(isfinite(z)) && double(exitFlag)>0;
            
            return
            
            
            
            
            function z = assign( )
                % Assignment
                %------------
                % Vectors posl and posg are each either empty or scalar at this point.
                fnInv = this.Type.InvTransform;
                z = fnEval(x, t, L);
                if ~isempty(fnInv)
                    z = fnInv(z);
                end
                exitFlag = 1;
            end
            
            
            
            
            function chkInitBounds( )
                return
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
                % Delogarithmize log variables; variables in steady equations are expected
                % to be in original levels.
                z = real(z);
                if any(ixLogZ)
                    z(ixLogZ) = exp( z(ixLogZ) );
                end
                x(posx, t) = z;
                xt = x(:, t).';
                
                y = fnEval(x, t, L);
                
                if nargout>1 && retGradient
                    j = cellfun( ...
                        @(Gradient, XX2L, D) ...
                        Gradient(x, t, L) .* xt(XX2L) * D , ...
                        ...
                        this.Gradient(1, :), ...
                        this.XX2L, ...
                        this.D, ...
                        ...
                        'UniformOutput', false ...
                        );
                    j = reshape([j{:}], nCol, nRow).';
                    if any(any(isnan(j))), keyboard, end
                end                
            end
        end
    end
    
    
    
    
    methods       
        function prepareBlock(this, blz, opt)
            prepareBlock@solver.block.Block(this, blz, opt);
            
            % Prepare function handles and auxiliary matrices for gradients.
            this.RetGradient = opt.PrepareGradient && this.Type==solver.block.Type.SOLVE;
            if this.RetGradient
                [this.Gradient, this.XX2L, this.D] = ...
                    createFnGradient(this, blz, opt);
            end
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
