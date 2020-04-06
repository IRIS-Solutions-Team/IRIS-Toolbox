classdef Steady < solver.block.Block
    properties 
        SteadyShift
    end


    properties (Constant)
        VECTORIZE = false
    end
    
    
    methods
        function this = Steady(varargin)
            this = this@solver.block.Block(varargin{:});
            this.D = struct( 'Level', [ ], ...
                             'Growth0', [ ], ...
                             'GrowthK', [ ] );
        end%


        
        
        function c = printListOfUknowns(this, name)
        %(
            if isstruct(this.PosQty)
                posLevel = this.PosQty.Level;
                posChange = this.PosQty.Change;
            else
                posLevel = this.PosQty;
                posChange = double.empty(1, 0);
            end

            listLevel = ' ';
            if ~isempty(posLevel)
                listLevel = strjoin(name(posLevel), ', ');
            end
            level = ['Level(', listLevel, ')'];

            listChange = ' ';
            if ~isempty(posChange)
                listChange = strjoin(name(posChange), ', ');
            end
            change = ['Change(', listChange, ')'];
            c = [level, ' ', change];
        %)
        end%




        function [lx, gx, exitFlag, error] = run(this, lnk, lx, gx, header)
            %(
            exitFlag = solver.ExitFlag.IN_PROGRESS;
            error = struct( 'EvaluatesToNan', [ ] );
            inxLog = this.InxOfLog;
            
            posl = this.PosQty.Level;
            posg = this.PosQty.Growth;
            if isempty(posl) && isempty(posg)
                exitFlag = solver.ExitFlag.NOTHING_TO_SOLVE;
                return
            end
            
            needsRefresh = any(lnk);
            retGradient = this.RetGradient;
            sh = this.Shift;
            nsh = this.NumberOfShifts;
            t0 = this.PositionOfZeroShift;
            nl = length(posl);
            inxLogZ = [ inxLog(posl), inxLog(posg) ];
            numRows = length(this.PosEqn);
            numColumns = length(posl) + length(posg);
            
            if this.Type==solver.block.Type.SOLVE
                % 
                % Solve
                %
                % Initialize endogenous level and growth unknowns.
                z0 = [ lx(posl), gx(posg) ];
                % Transform initial conditions for log variables before we check bounds;
                % bounds are in logs for log variables.
                z0(inxLogZ) = log(abs( z0(inxLogZ) ));
                %* Make sure init conditions are within bounds
                %* Empty bounds if all are Inf
                %* Bounds are in logs for log variables
                hereCheckInitBounds( );

                % Test all equations in this block for NaNs and Infs
                hereCheckEquationsForCorrupt( );
                if exitFlag~=solver.ExitFlag.IN_PROGRESS
                    return
                end

                [z, exitFlag] = solve(this, @objective, z0, header);
                z(inxLogZ) = exp( z(inxLogZ) );
            else
                %
                % Assign
                %
                [z, exitFlag] = assign( );
            end
            
            lx(posl) = z(1:nl);
            gx(posg) = z(nl+1:end);
            if any(~isfinite(z(:)))
                exitFlag = solver.ExitFlag.NAN_INF_SOLUTION;
            end
            
            return
            
           
                function hereCheckEquationsForCorrupt( )
                    XX = hereCreateTimeArray(0);
                    evalToCheck = this.EquationsFunc(XX, t0);
                    inxCorrupt = ~isfinite(evalToCheck);
                    if ~any(inxCorrupt)
                        return
                    end
                    exitFlag = solver.ExitFlag.NAN_INF_PREEVAL;
                    error.EvaluatesToNan = this.PosEqn(inxCorrupt);
                end%




                function [z, exitFlag] = assign( )
                    % Vectors posl and posg are each either empty or scalar at this point.
                    inxLog__ = any(inxLogZ);
                    transformFunc = this.Type.InvTransform;
                    z = double.empty(1, 0);
                    XX = hereCreateTimeArray(0);
                    y0 = this.EquationsFunc(XX, t0);
                    if ~isempty(transformFunc)
                        y0 = transformFunc(y0);
                    end
                    realY0 = real(y0);
                    imagY0 = imag(y0);
                    if ~isempty(posl)
                        z = [z, realY0];
                    end
                    if ~isempty(posg)
                        if imagY0~=0
                            z = [z, imagY0];
                        else
                            XX = hereCreateTimeArray(this.SteadyShift);
                            yk = this.EquationsFunc(XX, t0);
                            if ~isempty(transformFunc)
                                yk = transformFunc(yk);
                            end
                            if inxLog__
                                z = [ z, (yk/y0)^(1/this.SteadyShift) ];
                            else
                                z = [ z, (yk-y0)/this.SteadyShift ];
                            end
                        end
                    end
                    if any(inxLog__) && any(z<=0)
                        exitFlag = solver.ExitFlag.LOG_NEGATIVE_ASSIGNED;
                    else
                        exitFlag = solver.ExitFlag.ASSIGNED;
                    end
                end%
                


                
                function hereCheckInitBounds( )
                    ixOutOfBnds = z0<this.Lower | z0>this.Upper;
                    ixLowerInf = isinf(this.Lower);
                    ixUpperInf = isinf(this.Upper);
                    ix = ixOutOfBnds & ~ixLowerInf & ~ixUpperInf;
                    z0(ix) = (this.Lower(ix) + this.Upper(ix))/2;
                    ix = ixOutOfBnds & ~ixLowerInf;
                    z0(ix) = this.Lower(ix);
                    ix = ixOutOfBnds & ~ixUpperInf;
                    z0(ix) = this.Upper(ix);
                end%
                
                


                function [y, j] = objective(z, positionJacob)
                    j = [ ];
                    if nargin<2
                        positionJacob = [ ];
                    end
                    analyticalGradientRequest = nargout==2;
                    % Solver is requesting gradient but gradient was not
                    % prepared; this never happens with IRIS or Optim Tbx
                    % solvers as long as PrepareGradient=@auto.
                    if analyticalGradientRequest && ~retGradient
                        throw( exception.Base('Solver:GradientRequestedButNotPrepared', 'error') )
                    end

                    % Delogarithmize log variables; variables in steady equations are expected
                    % to be in original levels.
                    z = real(z);
                    if any(inxLogZ)
                        z(inxLogZ) = exp( z(inxLogZ) );
                    end
                    
                    % Split the input vector of unknows into levels and growth rates; nlx is
                    % the number of levels in the input vector
                    lx(posl) = z(1:nl);
                    gx(posg) = z(nl+1:end);

                    % Refresh all dynamic links in each iteration if needed
                    if needsRefresh
                        temp = lx + 1i*gx;
                        temp = temp(:);
                        temp = refresh(lnk, temp);
                        temp = transpose(temp);
                        lx = real(temp);
                        gx = imag(temp);
                        gx(inxLog & gx==0) = 1;
                    end
                    
                    XX = hereCreateTimeArray(0); 
                    if isempty(positionJacob)
                        y = this.EquationsFunc(XX, t0);
                    else
                        y = this.NumericalJacobFunc{positionJacob}(XX, t0);
                    end

                    if analyticalGradientRequest && retGradient
                        XX(end+1, :) = 1; % Add an extra row of ones referred to in analytical Jacobian
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
                        j = reshape([j{:}], numColumns, numRows).';
                    end
                    
                    if ~isempty(posg)
                        % Some growth rates need to be calculated. Evaluate the model equations at
                        % time t and t+SteadyShift if at least one growth rate is needed.
                        XXk = hereCreateTimeArray(this.SteadyShift); 
                        yk = this.EquationsFunc(XXk, t0);
                        y = [ y ; yk ];
                        if analyticalGradientRequest && retGradient
                            XXk(end+1, :) = 1; % Add an extra row of ones referred to in analytical Jacobian
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
                            jk = reshape([jk{:}], numColumns, numRows).';
                            j = [ j; jk ];
                        end
                    end
                end%
                
                
                function XX = hereCreateTimeArray(k)
                    XX = repmat(transpose(lx), 1, nsh);
                    XX(~inxLog, :) = XX(~inxLog, :)  + bsxfun(@times, gx(~inxLog).', sh+k);
                    XX( inxLog, :) = XX( inxLog, :) .* bsxfun(@power, gx( inxLog).', sh+k);
                end%
        %)
        end%
    end
    
    
    
    
    methods       
        function prepareBlock(this, blz, opt)
            prepareBlock@solver.block.Block(this, blz, opt);
            % Prepare function handles and auxiliary matrices for gradients.
            this.RetGradient = opt.PrepareGradient && this.Type==solver.block.Type.SOLVE;
            this.SteadyShift = opt.SteadyShift;
            if this.RetGradient
                [this.Gradient, this.XX2L, this.D.Level, this.D.Growth0, this.D.GrowthK] = ...
                    createAnalyticalJacob(this, blz, opt);
            end
            % Split PosQty and NumGradient into Level and Growth.
            this.PosQty = struct( 'Level', this.PosQty, ...
                                  'Growth', this.PosQty );
            exclude(this, blz);
        end%
        
        
        function createJacobPattern(this, blz)
            numEquations = length(this.Equations);
            numQuantities = length(this.PosQty);
            acrossShifts = across(blz.Incidence, 'Shifts');
            this.JacobPattern = acrossShifts(this.PosEqn, this.PosQty);
            this.NumericalJacobFunc = cell(1, numQuantities);
            for i = 1 : numQuantities
                indexActiveEquations = this.JacobPattern(:, i);
                activeEquationsString = ['[', this.Equations{indexActiveEquations}, ']'];
                if this.VECTORIZE
                    activeEquationsString = vectorize(activeEquationsString);
                end
                this.NumericalJacobFunc{i} = str2func([blz.PREAMBLE, activeEquationsString]);
            end
        end%
            
        
        function exclude(this, blz)
            % Exclude levels fixed by user.
            if isempty(blz.IdToExclude.Level)
                indexKeepLevel = ':';
            else
                [indexKeepLevel, this.PosQty.Level, this.D.Level] = ...
                    do(this.PosQty.Level, blz.IdToExclude.Level, this.D.Level);
            end
            % Exclude growth rates fixed by user.
            if isempty(blz.IdToExclude.Growth) 
                indexKeepGrowth = ':';
            else
                [indexKeepGrowth, this.PosQty.Growth, this.D.Growth0, this.D.GrowthK] = ...
                    do(this.PosQty.Growth, blz.IdToExclude.Growth, this.D.Growth0, this.D.GrowthK);
            end
            if this.Type==solver.block.Type.SOLVE
                this.JacobPattern = [ ...
                    this.JacobPattern(:, indexKeepLevel), ...
                    this.JacobPattern(:, indexKeepGrowth), ...
                ];
                this.NumericalJacobFunc = [ ...
                    this.NumericalJacobFunc(1, indexKeepLevel), ...
                    this.NumericalJacobFunc(1, indexKeepGrowth), ...
                ];
            end
            return

            
            function [indexToKeep, id, varargout] = do(id, idToExclude, varargin)
                varargout = varargin;
                indexToKeep = false(1, numel(id));
                [id, posToKeep] = setdiff(id, idToExclude, 'stable');
                indexToKeep(posToKeep) = true;
                for i = 1 : length(varargout)
                    if ~isempty(varargout{i})
                        D = varargout{i};
                        D = cellfun(@(x) x(:, posToKeep), D, 'UniformOutput', false);
                        varargout{i} = D;
                    end
                end
            end%
        end%
    end
end
