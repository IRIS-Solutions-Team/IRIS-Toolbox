% run  Run simulation of a stacked-time block

function [exitFlag, error, lastJacob, dimension] = run(this, data, exitFlagHeader)

exitFlag = solver.ExitFlag.IN_PROGRESS;
error = struct( );
error.EvaluatesToNan = [ ];

if isempty(this.PtrQuantities)
    exitFlag = solver.ExitFlag.NOTHING_TO_SOLVE;
    return
end
firstColumnToRun = data.FirstColumnFrame;
lastColumnToRun = data.LastColumnFrame;
columnsToRun = firstColumnToRun : lastColumnToRun;
numColumnsToRun = numel(columnsToRun);
inxLogWithinModel = this.ParentBlazer.Model.Quantity.InxLog;

if this.Type==solver.block.Type.SOLVE
    %
    % Solve
    %
    runTerminal = ~isempty(this.TerminalSimulator);

    % Initialize endogenous quantities
    linxZ = sub2ind(size(data.YXEPG), real(this.IdQuantities), imag(this.IdQuantities));
    inxLogZ = inxLogWithinModel(real(this.IdQuantities));
    z0 = data.YXEPG(linxZ);

    % Transform initial conditions for log variables before we check bounds;
    % bounds are in logs for log variables.
    if any(inxLogZ)
        z0(inxLogZ) = log(z0(inxLogZ));
    end

    inxLogWithinMap = this.StackedJacob_InxLogWithinMap;
    anyLogWithinMap = any(inxLogWithinMap);
    linxLhs = this.StackedJacob_GradientsMap(1, :);
    linxRhs = this.StackedJacob_GradientsMap(2, :);
    columnsJacob = this.StackedJacob_GradientsMap(3, :);
    columnsJacobLog = columnsJacob(inxLogWithinMap);

    needsUpdate = any(this.StackedJacob_InxNeedsUpdate);
    accelerateUpdate = ~isempty(this.StackedJacob_GradientsFunc_Update);
    if needsUpdate && accelerateUpdate 
        inxLogWithinMap_Update = this.StackedJacob_InxLogWithinMap_Update;
        anyLogWithinMap_Update = any(inxLogWithinMap_Update);
        linxLhs_Update = this.StackedJacob_GradientsMap_Update(1, :);
        linxRhs_Update = this.StackedJacob_GradientsMap_Update(2, :);
        columnsJacob_Update = this.StackedJacob_GradientsMap_Update(3, :);
        columnsJacobLog_Update = columnsJacob_Update(inxLogWithinMap_Update);
    end

    numRowsJacob = numel(this.IdEquations);
    numColumnsJacob = numel(this.IdQuantities);
    frameColumns = data.FirstColumnFrame:data.LastColumnFrame;
    inxEquationsUsingTerminal = this.InxEquationsUsingTerminal;
    inxQuantitiesDeterminingTerminal = this.StackedJacob_InxQuantitiesDeterminingTerminal;
    needsTerminalJacob = any(inxEquationsUsingTerminal) && any(inxQuantitiesDeterminingTerminal);

    %* Make sure init conditions are within bounds.
    %* Empty bounds if all are Inf.
    %* Bounds are in logs for log variables.
    % checkBoundsOnInitCond( );
    % Test all equations in this block for NaNs and Infs.
    hereCheckEquationsForCorrupt( );
    if exitFlag~=solver.ExitFlag.IN_PROGRESS
        return
    end

    [z, f, exitFlag, lastJacob] = solve(this, @objective, z0, exitFlagHeader);
    locallyWriteEndogenousToData(data, z, linxZ, inxLogZ);
    dimension = [numRowsJacob, numColumnsJacob];
else
    %
    % Assign LHS variable
    % 
    [z, exitFlag] = assign(this, data, exitFlagHeader);
    lastJacob = NaN;
    dimension = NaN;
end

exitFlag = this.checkFiniteSolution(z, exitFlag);

return
    
    function [y, j] = objective(z, jacobColumn, j)
        isJacobRequested = nargout>=2;
        isEvaluateEquationsRequested = nargout<2 || nargin<3 || (isJacobRequested && needsTerminalJacob);

        if nargin<2
            jacobColumn = [ ];
        end
        if nargin<3
            j = [ ];
        end

        %
        % Write current iteration data into the data matrix
        %
        locallyWriteEndogenousToData(data, z, linxZ, inxLogZ);

        %
        % Run first-order terminal condition
        %
        if runTerminal
            simulateStackedNoShocks(this.TerminalSimulator, data);
        end
        
        y = [ ];
        if isEvaluateEquationsRequested
            hereEvaluateEquations( );
        end
        
        if isJacobRequested
            %
            % Evaluate or update the common part of the Jacobian
            %
            if isempty(j) || (needsUpdate && ~accelerateUpdate)
                hereEvaluateCommonJacob( );
            elseif needsUpdate
                hereUpdateCommonJacob( );
            end

            %
            % Evaluate the terminal part of the Jacobian
            %
            if needsTerminalJacob
                hereUpdateTerminalJacob( );
            end
        end

    return

        function hereEvaluateEquations( )
            %(
            if isempty(jacobColumn)
                y = this.EquationsFunc(data.YXEPG, frameColumns, data.BarYX);
            else
                firstColumnJacob = firstColumnToRun + this.FirstTime(jacobColumn) - 1;
                lastColumnJacob = firstColumnToRun + this.LastTime(jacobColumn) - 1;
                columns__ = firstColumnJacob : lastColumnJacob;
                y = this.NumericalJacobFunc{jacobColumn}(data.YXEPG, columns__, data.BarYX);
            end
            y = reshape(y, [ ], 1);
            %)
        end%


        function hereEvaluateCommonJacob( )
            %(
            if isempty(j)
                j = sparse(numRowsJacob, numColumnsJacob);
            end

            %
            % Calculate an array of gradients (some of the may
            % not be used in the Jacobian) consisting of blocks
            % of numWrt-by-numColumns gradients for each
            % equation stacked vertically
            %
            % [eqtn2-column1-wrt1; eqtn2-column1-wrt2], [eqtn2-column2-wrt1; eqtn2-column2-wrt2]
            % [eqtn2-column1-wrt1; eqtn2-column1-wrt2], [eqtn2-column2-wrt1; eqtn2-column2-wrt2]
            % ...
            %
            gradients = this.StackedJacob_GradientsFunc(data.YXEPG, frameColumns, data.BarYX);

            %
            % Retrieve only the gradients that are actually needed for the
            % LHS Jacobian
            %
            gradients = reshape(gradients(linxRhs), 1, [ ]);

            %
            % Adjust the gradients calculated w.r.t. plain
            % variables to be w.r.t. the log of variables
            %
            if anyLogWithinMap
                gradients(inxLogWithinMap) ...
                    = gradients(inxLogWithinMap) ...
                    .* reshape(exp(z(columnsJacobLog)), 1, [ ]);
            end

            %
            % Map the values from the array of gradients (some
            % of them may not be used in the Jacobian) to the
            % Jacobian
            %
            j(linxLhs) = gradients;
            %)
        end%


        function hereUpdateCommonJacob( )
            %(
            % Same logic as hereEvaluateCommonJacob( ) except that only the
            % gradients that truly need to be update are evaluated
            %
            gradients_Update = this.StackedJacob_GradientsFunc_Update(data.YXEPG, frameColumns, data.BarYX);
            gradients_Update = reshape(gradients_Update(linxRhs_Update), 1, [ ]);
            if anyLogWithinMap_Update
                gradients_Update(inxLogWithinMap_Update) ...
                    = gradients_Update(inxLogWithinMap_Update) ...
                    .* reshape(exp(z(columnsJacobLog_Update)), 1, [ ]);
            end
            j(linxLhs_Update) = gradients_Update;
            %)
        end%


        function hereUpdateTerminalJacob( )
            %(
            absZ = abs(z);
            absZ(absZ<1) = 1;
            step = eps( )^(1/3);
            h = step*absZ;
            for i = find(inxQuantitiesDeterminingTerminal)
                zp = z;
                zp(i) = zp(i) + h(i);
                locallyWriteEndogenousToData(data, zp, linxZ, inxLogZ);
                if runTerminal
                    simulateStackedNoShocks(this.TerminalSimulator, data);
                end
                yp = this.StackedJacob_EquationsFuncUsingTerminal(data.YXEPG, [ ], data.BarYX);
                j(inxEquationsUsingTerminal, i) = (yp - y(inxEquationsUsingTerminal)) / h(i);
            end
            %)
        end%
    end%


    function hereCheckEquationsForCorrupt( )
        %(
        if runTerminal
            simulateStackedNoShocks(this.TerminalSimulator, data);
        end
        checkObjective = objective(z0);
        checkObjective = reshape(checkObjective, [ ], numColumnsToRun);
        inxValidData = ~(isnan(checkObjective) | isinf(checkObjective));
        if all(inxValidData(:))
            return
        end
        inxInvalidEquationsInBlock = any(~inxValidData, 2);
        error.EvaluatesToNan = this.PtrEquations(inxInvalidEquationsInBlock);
        exitFlag = solver.ExitFlag.NAN_INF_PREEVAL;
        %)
    end%
end%

%
% Local Functions
%

function locallyWriteEndogenousToData(data, z, linxZ, inxLogZ)
    %(
    z = real(z);
    if any(inxLogZ)
        z(inxLogZ) = exp(z(inxLogZ));
    end
    data.YXEPG(linxZ) = z;
    %)
end%
