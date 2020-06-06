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
            this.D = struct( ...
                'Level', [ ], ...
                'Change0', [ ], ...
                'ChangeK', [ ] ...
            );
        end%


        
        
        function s = printListUknowns(this, names)
        %(
            [ptrLevel, ptrChange] = iris.utils.splitRealImag(this.PtrQuantities);

            if ~isempty(ptrLevel)
                listLevel = strjoin(names(ptrLevel), ", ");
            else
                listLevel = " ";
            end
            level = "% " + solver.block.Block.SAVEAS_INDENT ...
                + "Level(" + listLevel + ")" ...
                + sprintf("\n");

            if ~isempty(ptrChange)
                listChange = strjoin(names(ptrChange), ", ");
            else
                listChange = " ";
            end
            change = "% " + solver.block.Block.SAVEAS_INDENT ...
                + "Change(" + listChange + ")" ...
                + sprintf("\n");

            s = level + change;
        %)
        end%




        function [lx, gx, exitFlag, error] = run(this, link, lx, gx, addStdCorr, exitFlagHeader)
            %(
            exitFlag = solver.ExitFlag.IN_PROGRESS;
            error = struct( 'EvaluatesToNan', [ ] );
            inxLog = this.InxLog;
                
            if isEmptyBlock(this.Type) || isempty(this.PtrQuantities)
                exitFlag = solver.ExitFlag.NOTHING_TO_SOLVE;
                return
            end
            
            [ptrLevel, ptrChange] = iris.utils.splitRealImag(this.PtrQuantities);

            needsRefresh = any(link);
            needsAddStdCorr = needsRefresh && nargin>=6 && ~isempty(addStdCorr);
            retGradient = this.RetGradient;
            sh = this.Shift;
            nsh = this.NumberOfShifts;
            t0 = this.PositionOfZeroShift;
            numLevels = numel(ptrLevel);
            inxLogZ = [ inxLog(ptrLevel), inxLog(ptrChange) ];
            numRows = length(this.PtrEquations);
            numColumns = length(ptrLevel) + length(ptrChange);
            
            if this.Type==solver.block.Type.SOLVE
                % 
                % Solve
                %
                % Initialize endogenous level and growth unknowns.
                z0 = [ lx(ptrLevel), gx(ptrChange) ];
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

                [z, exitFlag] = solve(this, @objective, z0, exitFlagHeader);
                z(inxLogZ) = exp( z(inxLogZ) );
            else
                %
                % Assign
                %
                [z, exitFlag] = hereAssign( );
            end
            
            lx(ptrLevel) = z(1:numLevels);
            gx(ptrChange) = z(numLevels+1:end);
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
                    error.EvaluatesToNan = this.PtrEquations(inxCorrupt);
                end%




                function [z, exitFlag] = hereAssign( )
                    % Vectors ptrLevel and ptrChange are each either empty or scalar at this point.
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
                    if ~isempty(ptrLevel)
                        z = [z, realY0];
                    end
                    if ~isempty(ptrChange)
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
                    % try
                    %     print(exitFlag, exitFlagHeader, this.Solver.DisplayLevel);
                    % end
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
                    lx(ptrLevel) = z(1:numLevels);
                    gx(ptrChange) = z(numLevels+1:end);

                    % Refresh all dynamic links in each iteration if needed
                    if needsRefresh
                        temp = lx + 1i*gx;
                        if needsAddStdCorr
                            temp = [temp, addStdCorr];
                        end
                        temp = temp(:);
                        temp = refresh(link, temp);
                        if needsAddStdCorr
                            temp = temp(1:numel(lx));
                        end
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
                            @(Gradient, XX2L, DLevel, DChange0) ...
                            Gradient(XX, t0) .* XX(XX2L) * [DLevel, DChange0] , ...
                            ...
                            this.Gradient(1, :), ...
                            this.XX2L, ...
                            this.D.Level, ...
                            this.D.Change0, ...
                            ...
                            'UniformOutput', false ...
                            );
                        j = reshape([j{:}], numColumns, numRows).';
                    end
                    
                    if ~isempty(ptrChange)
                        % Some growth rates need to be calculated. Evaluate the model equations at
                        % time t and t+SteadyShift if at least one growth rate is needed.
                        XXk = hereCreateTimeArray(this.SteadyShift); 
                        yk = this.EquationsFunc(XXk, t0);
                        y = [ y ; yk ];
                        if analyticalGradientRequest && retGradient
                            XXk(end+1, :) = 1; % Add an extra row of ones referred to in analytical Jacobian
                            jk = cellfun( ...
                                @(Gradient, XX2L, DLevel, DChangeK) ...
                                Gradient(XXk, t0) .* XXk(XX2L) * [DLevel, DChangeK] , ...
                                ...
                                this.Gradient(1, :), ...
                                this.XX2L, ...
                                this.D.Level, ...
                                this.D.ChangeK, ...
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

            [ptrLevelToExclude, ptrChangeToExclude] = iris.utils.splitRealImag(blz.QuantitiesToExclude);
            ptrLevel = setdiff(double(this.PtrQuantities), double(ptrLevelToExclude), 'stable');
            ptrChange = setdiff(double(this.PtrQuantities), double(ptrChangeToExclude), 'stable');

            this.PtrQuantities = [ptrLevel, 1i*ptrChange];
        end%




        function prepareForSolver(this, blz, opt)

            prepareForSolver@solver.block.Block(this, blz, opt);

            %
            % Prepare function handles and auxiliary matrices for gradients
            %
            this.RetGradient = opt.PrepareGradient && this.Type==solver.block.Type.SOLVE;
            this.SteadyShift = opt.SteadyShift;

            if this.RetGradient
                %
                % Prepare the analytical gradient for the same set of
                % levels and changes, with the list of pointers being the
                % union of levels and changes. The exclusion is done in the
                % next step
                %
                [this.Gradient, this.XX2L, this.D.Level, this.D.Change0, this.D.ChangeK] = ...
                    createAnalyticalJacob(this, blz, opt);
            end

            excludeQuantitiesFromJacob(this, blz);
        end%
        


        
        function createJacobPattern(this, blz)
            %
            % Create the Jacob pattern for the union of levels and changes;
            % the exclusion will be done later
            %
            ptrUnion = iris.utils.unionRealImag(this.PtrQuantities);

            numEquations = numel(this.Equations);
            numQuantities = numel(ptrUnion);
            acrossShifts = across(blz.Incidence, 'Shifts');
            this.JacobPattern = acrossShifts(this.PtrEquations, ptrUnion);
            this.NumericalJacobFunc = cell(1, numQuantities);
            for i = 1 : numQuantities
                inxActiveEquations = this.JacobPattern(:, i);
                activeEquationsString = ['[', this.Equations{inxActiveEquations}, ']'];
                if this.VECTORIZE
                    activeEquationsString = vectorize(activeEquationsString);
                end
                this.NumericalJacobFunc{i} = str2func([blz.PREAMBLE, activeEquationsString]);
            end
        end%
            
        


        function excludeQuantitiesFromJacob(this, blz)
            % excludeQuantitiesFromJacob  Exclude rows and columns
            % corresponding to excluded Levels and Changes from
            % JacobPatterna and NumericalJacobFunc

            if this.Type~=solver.block.Type.SOLVE
                return
            end

            %
            % Union of Levels and Changes for which JacobPattern and
            % NumericalJacobFunc were prepared
            %
            ptrUnion = iris.utils.unionRealImag(this.PtrQuantities);

            %
            % Actual Levels and Changes with some of them excluded for
            % which JacobPattern and NumericalJacobFunc need to be prepared
            %
            [ptrLevel, ptrChange] = iris.utils.splitRealImag(this.PtrQuantities);

            %
            % Exclude Levels
            %
            if isequal(ptrLevel, ptrUnion)
                posKeepLevel = ':';
            else
                [posKeepLevel, this.D.Level] = ...
                    hereExclude(ptrUnion, ptrLevel, this.D.Level);
            end

            %
            % Exclude Changes
            %
            if isequal(ptrChange, ptrUnion)
                posKeepChange = ':';
            else
                [posKeepChange, this.D.Change0, this.D.ChangeK] = ...
                    hereExclude(ptrUnion, ptrChange, this.D.Change0, this.D.ChangeK);
            end

            this.JacobPattern = [ ...
                this.JacobPattern(:, posKeepLevel), ...
                this.JacobPattern(:, posKeepChange), ...
            ];

            this.NumericalJacobFunc = [ ...
                this.NumericalJacobFunc(1, posKeepLevel), ...
                this.NumericalJacobFunc(1, posKeepChange), ...
            ];

            return

                function [posKeep, varargout] = hereExclude(union, keep, varargin)
                    varargout = varargin;

                    % Positions of keep in union
                    posKeep = arrayfun(@(x) find(x==union), keep);

                    for i = 1 : numel(varargout)
                        if ~isempty(varargout{i})
                            varargout{i} = cellfun( ...
                                @(x) x(:, posKeep), varargout{i}, ...
                                'UniformOutput', false ...
                            );
                        end
                    end
                end%
        end%
    end
end
