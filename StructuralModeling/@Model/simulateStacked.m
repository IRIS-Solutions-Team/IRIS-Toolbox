function [exitFlag, dcy] = simulateStacked(~, rect, data, blazer, idFrame)

firstColumnFrame = data.FirstColumnFrame;
lastColumnFrame = data.LastColumnFrame;
columnsFrame = firstColumnFrame : lastColumnFrame;
dcy = double.empty(0);


%
% Run plain-vanilla first-order simulation to create initial condition,
% ignoring shocks (IgnoreShocks=true is set in simulateFrames)
%
if startsWith(blazer.StartIterationsFrom, "firstOrder", "ignoreCase", true)
    if idFrame==1
        % Simulate the entire frame range
        flat(rect, data);
    else
        % Simulate only missing data
        hereSimulateMissingData( );
    end
else
    hereFillMissingData( );
end


%
% Copy the values of exogenized variables from Target to YXEPG because
% these might have become overwrittend when running the plain vanilla
% first-order simulation
%
updateTargetsWithinFrame(data);


numBlocks = numel(blazer.Blocks);
for i = 1 : numBlocks
    block__ = blazer.Blocks{i};

    %
    % Set up first-order terminal simulator if needed
    %
    block__.TerminalSimulator = [ ];
    if block__.NeedsTerminal && startsWith(blazer.Terminal, "firstOrder", "ignoreCase", true)
        herePrepareTerminal( );
    end

    exitFlagHeader = string(rect.Header) + sprintf("[Block:%g]", i);
    [exitFlag, error] = run(block__, data, exitFlagHeader);
    if ~isempty(error.EvaluatesToNan) || ~hasSucceeded(exitFlag)
        if blazer.SuccessOnly
            if i<numBlocks
                fprintf( ...
                    "Leaving prematurely because SuccessOnly=true. Blocks %g:%g not executed.\n" ...
                    , i+1, numBlocks ...
                );
            end
            break
        end
    end
end 


hereReportEvaluatesToNaN( );
hereCleanupTerminal( );


return

    function hereSimulateMissingData( )
        %
        % Find the first column within the frame that has at least one
        % missing observation, and first-order simulate from that column to
        % the end of the frame
        %
        inxColumnsNaN = any(isnan(data.YXEPG(:, columnsFrame)), 1);
        if any(inxColumnsNaN)
            firstColumnMissing = columnsFrame(1) - 1 + find(inxColumnsNaN, 1);
            setFrame(rect, [firstColumnMissing, columnsFrame(end)]);
            flat(rect, data);
        end
    end%


    function hereFillMissingData( )
        inxRowsNaN = any(isnan(data.YXEPG(:, columnsFrame)), 2);
        if any(inxRowsNaN)
            alongDim = 2;
            data.YXEPG(inxRowsNaN, 1:columnsFrame(end)) ...
                = fillmissing(data.YXEPG(inxRowsNaN, 1:columnsFrame(end)), "previous", alongDim);
        end
        inxRowsNaN = any(isnan(data.YXEPG(:, columnsFrame)), 2);
        if any(inxRowsNaN)
            data.YXEPG(inxRowsNaN, 1:columnsFrame(end)) ...
                = fillmissing(data.YXEPG(inxRowsNaN, 1:columnsFrame(end)), "constant", 0);
        end
    end%


    function herePrepareTerminal( )
        %(
        %
        % Reset frame columns in rect; rect is only used as a terminal
        % simulator from now until the next frame in simulateFrames
        %
        lastTerminalColumn = block__.LastTerminalColumn;
        terminalFrame = [lastColumnFrame+1, lastTerminalColumn];
        setFrame(rect, terminalFrame);
        prepareStackedNoShocks(rect, block__.InxTerminalDataPoints);
        block__.TerminalSimulator = rect;
        %)
    end%


    function hereReportEvaluatesToNaN( )
        %(
        if ~isempty(error.EvaluatesToNan)
            exception.error([
                "Model:NonlinearSimulationEvaluatesToNaN"
                "This dynamic equation evaluates to NaN or Inf: %s"
            ], blazer.Model.Equation.Input{error.EvaluatesToNan});
        end
        %)
    end%


    function hereCleanupTerminal( )
        %(
        setFrame(rect, [firstColumnFrame, lastColumnFrame]);
        resetStackedNoShocks(rect);
        %)
    end%
end%

