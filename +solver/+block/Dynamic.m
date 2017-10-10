classdef Dynamic < solver.block.Block
    properties (Constant)
        VECTORIZE = false
    end


    methods
        function this = Dynamic(varargin)
            this = this@solver.block.Block(varargin{:});
        end
        
        
        function [X, exitStatus, error] = run(this, X, t, L, ixLog)
            exitStatus = true;
            error = struct( ...
                'EvaluatesToNan', [ ] ...
                );
            
            posx = this.PosQty;
            if isempty(posx)
                return
            end
            
            retGradient = this.RetGradient;
            ixLogZ = ixLog(posx);
            numOfRows = length(this.PosEqn);
            numOfColumns = length(posx);
            
            if this.Type==solver.block.Type.SOLVE
                % __Solve__
                % Initialize endogenous quantities.
                z0 = X(posx, t);
                ixNan = isnan(z0);
                if any(ixNan) && t>1
                    z0(ixNan) = X(posx(ixNan), t-1);
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
                checkBoundsOnInitCond( );
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
                % __Assign__
                z = assign( );
                exitFlag = 1;
            end
            
            X(posx, t) = z;
            exitStatus = all(isfinite(z)) && double(exitFlag)>0;
            
            return
            
            
            function z = assign( )
                % __Assignment__
                % Vectors posl and posg are each either empty or scalar at this point.
                fnInv = this.Type.InvTransform;
                z = this.EquationsFunc(X, t, L);
                if ~isempty(fnInv)
                    z = fnInv(z);
                end
                exitFlag = 1;
            end
            
            
            function checkBoundsOnInitCond( )
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
                X(posx, t) = z;
                
                y = this.EquationsFunc(X, t, L);
                
                if nargout>1 && retGradient
                    X_t = X(:, t).';
                    j = cellfun( ...
                        @(Gradient, XX2L, D) ...
                        Gradient(X, t, L) .* X_t(XX2L) * D , ...
                        ...
                        this.Gradient(1, :), ...
                        this.XX2L, ...
                        this.D, ...
                        ...
                        'UniformOutput', false ...
                        );
                    j = reshape([j{:}], numOfColumns, numOfRows).';
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
                [this.Gradient, this.XX2L, this.D] = createAnalyticalJacob(this, blz, opt);
            end
            exclude(this, blz);
        end
        
        
        function exclude(this, posExclude)
            % Exclude levels fixed by user.
            if isempty(posExclude)
                indexKeep = ':';
            else
                [indexKeep, this.PosQty, this.D] = do(this.PosQty, posExclude, this.D);
            end
            return
            
            
            function [indexKeep, pos, varargout] = do(pos, posExclude, varargin)
                varargout = varargin;
                indexKeep = false(1, numel(pos));
                [pos, positionsKeep] = setdiff(pos, posExclude, 'stable');
                indexKeep(positionsKeep) = true;
                numericalGradient = numericalGradient(positionsKeep);
                for i = 1 : length(varargout)
                    if ~isempty(varargout{i})
                        D = varargout{i};
                        D = cellfun(@(x) x(:, positionsKeep), D, 'UniformOutput', false);
                        varargout{i} = D;
                    end
                end
            end
        end
    end
end
