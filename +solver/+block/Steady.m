classdef Steady < solver.block.Block
    properties (Constant)
        STEADY_SHIFT = 3
        VECTORIZE = false
        PREAMBLE = "@(x,t)"
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


        function s = printListUnknowns(this, names)
        %(
            [ptrLevel, ptrChange] = iris.utils.splitRealImag(this.PtrQuantities);

            if ~isempty(ptrLevel)
                listLevel = hereCreateMarkdownList(names(ptrLevel));
            else
                listLevel = " ";
            end
            level = "* level of {" + listLevel + "}" + sprintf("\n");

            if ~isempty(ptrChange)
                listChange = hereCreateMarkdownList(names(ptrChange));
            else
                listChange = " ";
            end
            change = "* change in {" + listChange + "}" + sprintf("\n");

            s = level + change;

            return

                function list = hereCreateMarkdownList(list)
                    list = strjoin("`"+string(list)+"`", ", ");
                end%
        %)
        end%


        function [lx, gx, exitFlag, error, lastJacob, dimension] = run(this, link, lx, gx, addStdCorr, exitFlagHeader)
            %(
            exitFlag = solver.ExitFlag.IN_PROGRESS;
            error = struct('EvaluatesToNan', [], 'LogAssignedNonpositive', []);
            inxLogWithinModel = this.ParentBlazer.Model.Quantity.InxLog;

            lastJacob = [ ];
            dimension = [0, 0];
            if isEmptyBlock(this.Type) || isempty(this.PtrQuantities)
                exitFlag = solver.ExitFlag.NOTHING_TO_SOLVE;
                return
            end

            [ptrLevel, ptrChange] = iris.utils.splitRealImag(this.PtrQuantities);

            needsRefresh = any(link);
            needsAddStdCorr = needsRefresh && nargin>=6 && ~isempty(addStdCorr);
            sh = this.Shift;
            nsh = this.NumberOfShifts;
            t0 = this.PositionOfZeroShift;
            numLevels = numel(ptrLevel);
            inxLogZ = [ inxLogWithinModel(ptrLevel), inxLogWithinModel(ptrChange) ];
            numRows = numel(this.PtrEquations);
            numColumns = numel(ptrLevel) + numel(ptrChange);

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

                [z, f, exitFlag, lastJacob] = solve(this, @objective, z0, exitFlagHeader);
                z(inxLogZ) = exp(z(inxLogZ));
                dimension = [numel(f), numColumns];
            else
                %
                % Assign
                %
                [z, exitFlag] = hereAssign();
            end

            lx(ptrLevel) = z(1:numLevels);
            gx(ptrChange) = z(numLevels+1:end);

            if any(isnan(z(:)) | isinf(z(:)))
                exitFlag = solver.ExitFlag.NAN_INF_SOLUTION;
            end

            return

                function hereCheckEquationsForCorrupt( )
                    XX = hereCreateTimeArray(0);
                    evalToCheck = this.EquationsFunc(XX, t0);
                    inxCorrupt = isnan(evalToCheck) | isinf(evalToCheck);
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
                    steadyShift = this.STEADY_SHIFT;
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
                            XX = hereCreateTimeArray(steadyShift);
                            yk = this.EquationsFunc(XX, t0);
                            if ~isempty(transformFunc)
                                yk = transformFunc(yk);
                            end
                            if inxLog__
                                z = [ z, (yk/y0)^(1/steadyShift) ];
                            else
                                z = [ z, (yk-y0)/steadyShift ];
                            end
                        end
                    end

                    if any(~isfinite(z))
                        exitFlag = solver.ExitFlag.NAN_INF_PREEVAL;
                        error.EvaluatesToNan = this.PtrEquations;
                        return
                    end

                    if any(inxLog__) && any(z<=0)
                        exitFlag = solver.ExitFlag.LOG_NEGATIVE_ASSIGNED;
                        error.LogAssignedNonpositive = ptrLevel;
                        return
                    end

                    exitFlag = solver.ExitFlag.ASSIGNED;
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


                function [y, j] = objective(z, jacobColumn, j)
                    isJacobRequested = nargout>=2;
                    isFunctionRequested = nargout<2 || nargin<3;
                    if nargin<2
                        jacobColumn = [ ];
                    end
                    if nargin<3
                        j = [ ];
                    end

                    % Delogarithmize log variables; variables in the equations are expected
                    % to be in original levels.
                    z = real(z);
                    if any(inxLogZ)
                        z(inxLogZ) = exp(z(inxLogZ));
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
                        gx(inxLogWithinModel & gx==0) = 1;
                    end

                    XX = hereCreateTimeArray(0);
                    y = [ ];
                    if isFunctionRequested
                        if isempty(jacobColumn)
                            y = this.EquationsFunc(XX, t0);
                        else
                            y = this.NumericalJacobFunc{jacobColumn}(XX, t0);
                        end
                    end

                    if isJacobRequested
                        XX(end+1, :) = 1; % Add an extra row of ones referred to in analytical Jacobian
                        j = cellfun( ...
                            @(Gradients, XX2L, DLevel, DChange0) ...
                            reshape(Gradients(XX, t0), 1, [ ]) .* XX(XX2L) * [DLevel, DChange0] , ...
                            ...
                            this.Gradients(1, :), ...
                            this.XX2L, ...
                            this.D.Level, ...
                            this.D.Change0, ...
                            ...
                            'UniformOutput', false ...
                            );
                        j = transpose(reshape([j{:}], numColumns, numRows));
                    end

                    if ~isempty(ptrChange)
                        % Some growth rates need to be calculated. Evaluate the model equations at
                        % time t and t+STEADY_SHIFT if at least one growth rate is needed.
                        XXk = hereCreateTimeArray(this.STEADY_SHIFT);

                        if isFunctionRequested
                            yk = this.EquationsFunc(XXk, t0);
                            y = [ y ; yk ];
                        end

                        if isJacobRequested
                            XXk(end+1, :) = 1; % Add an extra row of ones referred to in analytical Jacobian
                            jk = cellfun( ...
                                @(Gradients, XX2L, DLevel, DChangeK) ...
                                reshape(Gradients(XXk, t0), 1, [ ]) .* XXk(XX2L) * [DLevel, DChangeK] , ...
                                ...
                                this.Gradients(1, :), ...
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
                    XX(~inxLogWithinModel, :) = XX(~inxLogWithinModel, :)  + bsxfun(@times, gx(~inxLogWithinModel).', sh+k);
                    XX( inxLogWithinModel, :) = XX( inxLogWithinModel, :) .* bsxfun(@power, gx( inxLogWithinModel).', sh+k);
                end%
        %)
        end%
    end


    methods
        function prepareBlock(this, blazer)
            prepareBlock@solver.block.Block(this, blazer);

            [ptrLevelToExclude, ptrChangeToExclude] = iris.utils.splitRealImag(this.ParentBlazer.QuantitiesToExclude);
            ptrLevel = setdiff(double(this.PtrQuantities), double(ptrLevelToExclude), 'stable');
            ptrChange = setdiff(double(this.PtrQuantities), double(ptrChangeToExclude), 'stable');

            this.PtrQuantities = [ptrLevel, 1i*ptrChange];
        end%


        function prepareForSolver(this, solverOptions, varargin)
            if this.Type==solver.block.Type.SOLVE
                this.SolverOptions = solverOptions;
                prepareJacob(this, varargin{:});
            else
                this.SolverOptions = [ ];
            end
        end%


        function prepareJacob(this)
            %(
            %
            % Create the Jacob pattern for the union of levels and changes;
            % the exclusion will be done later
            %
            ptrUnion = iris.utils.unionRealImag(this.PtrQuantities);

            numQuantities = numel(ptrUnion);
            acrossShifts = across(this.ParentBlazer.Incidence, "Shifts");
            this.JacobPattern = acrossShifts(this.PtrEquations, ptrUnion);
            this.NumericalJacobFunc = cell(1, numQuantities);
            for i = 1 : numQuantities
                inxActiveEquations = this.JacobPattern(:, i);
                ptrActiveEquations = this.PtrEquations(inxActiveEquations);
                activeEquationsString = "[" + join(string(this.ParentBlazer.Equations(ptrActiveEquations)), "") + "]";
                if this.VECTORIZE
                    activeEquationsString = vectorize(activeEquationsString);
                end
                this.NumericalJacobFunc{i} = str2func(this.PREAMBLE + activeEquationsString);
            end

            if this.NeedsAnalyticalJacob
                %
                % Prepare the analytical gradient for the same set of
                % levels and changes, with the list of pointers being the
                % union of levels and changes. The exclusion is done in the
                % next step
                %
                [this.Gradients, this.XX2L, this.D.Level, this.D.Change0, this.D.ChangeK] ...
                    = prepareAnalyticalJacob(this);
            end

            excludeQuantitiesFromJacob(this);
            %)
        end%


        function [gr, XX2L, DLevel, DChange0, DChangeK] = prepareAnalyticalJacob(this)
            %(
            [~, numQuantities] = size(this.ParentBlazer.Incidence);
            numEquationsHere = numel(this.PtrEquations);
            gr = this.ParentBlazer.Gradients(:, this.PtrEquations);
            sh = this.Shift;
            numSh = numel(sh);
            sh0 = find(this.Shift==0);
            aux = sub2ind([numQuantities+1, numSh], numQuantities+1, sh0); % Linear index to 1 in last row.
            XX2L = cell(1, numEquationsHere);
            DLevel = cell(1, numEquationsHere);
            DChange0 = cell(1, numEquationsHere);
            DChangeK = cell(1, numEquationsHere);
            for i = 1 : numEquationsHere
                ptrQuantities = iris.utils.unionRealImag(this.PtrQuantities);
                gr(:, i) = getGradients(this, this.PtrEquations(i));
                vecWrt = gr{2, i};
                numWrt = numel(vecWrt);
                inxOutOfSh = imag(vecWrt)<sh(1) | imag(vecWrt)>sh(end);
                XX2L{i} = ones(1, numWrt)*aux;
                ixLog = this.ParentBlazer.Model.Quantity.IxLog(real(vecWrt));
                vecWrt(inxOutOfSh) = NaN;
                ixLog(inxOutOfSh) = false;
                XX2L{i}(ixLog) = sub2ind( ...
                    [numQuantities+1, numSh], ...
                    reshape(real(vecWrt(ixLog)), 1, [ ]), ...
                    sh0 + reshape(imag(vecWrt(ixLog)), 1, [ ]) ...
                );
                DLevel{i} = double(bsxfun(@eq, ptrQuantities, reshape(real(vecWrt), [ ], 1)));
                if nargout>3
                    DChange0{i} = bsxfun(@times, DLevel{i}, reshape(imag(vecWrt), [ ], 1));
                    DChangeK{i} = bsxfun(@times, DLevel{i}, reshape(imag(vecWrt), [ ], 1) + this.STEADY_SHIFT);
                end
            end
            %)
        end%


        function gr = getGradients(this, posEqn)
            %
            % Create the gradient for the union of levels and changes
            %
            ptrQuantities = iris.utils.unionRealImag(this.PtrQuantities);

            %
            % Fetch gradient of posEqn-th equation from Blazer object or differentiate
            % again if needed
            %
            vecWrtNeeded = find(this.ParentBlazer.Incidence, posEqn, ptrQuantities);
            vecWrtMissing = setdiff(vecWrtNeeded, this.ParentBlazer.Gradients{2, posEqn});
            if isa(this.ParentBlazer.Gradients{1, posEqn}, 'function_handle') && isempty(vecWrtMissing)
                %
                % vecWrtNeeded is a subset of vecWrt currently available,
                % use it here
                %
                gr = this.ParentBlazer.Gradients(:, posEqn);
            else
                %
                % Redifferentiate this equation wrt the quantities needed only
                %
                d = model.Gradient.diff(this.ParentBlazer.Equations{posEqn}, vecWrtNeeded, "array");
                d = str2func(this.PREAMBLE + string(d));
                gr = {d; vecWrtNeeded; [ ]};
            end
        end%


        function excludeQuantitiesFromJacob(this)
            % excludeQuantitiesFromJacob  Exclude rows and columns
            % corresponding to excluded Levels and Changes from
            % JacobPattern and NumericalJacobFunc

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

