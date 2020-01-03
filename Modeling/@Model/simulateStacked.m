function [exitFlag, dcy] = simulateStacked(simulateFunc, rect, data, blazers)
% simulateStacked  Run stacked-time simulation on one time frame
%
% Backend IRIS function
% No help provided

% -[IrisToolbox] for Macroeconomic Modeling
% -Copyright (c) 2007-2020 IRIS Solutions Team

%--------------------------------------------------------------------------

dcy = double.empty(0);

%
% Run first-order simulation to create initial condition
%
if strcmpi(data.Initial, 'FirstOrder')
    simulateFunc(vthRect, vthData);
end

%
% Choose a blazer with no blocks for simulations with exogenized data
% points
%
if data.HasExogenizedPoints
    % No blocks
    blazer = blazers(1);
else
    % With blocks
    blazer = blazers(2);
end

% Set time frame of rect to terminal condition range
% Keep time frame of data set to simulation range
firstColumnTimeFrame = data.FirstColumnOfTimeFrame;
lastColumnTimeFrame = data.LastColumnOfTimeFrame;
columnsTimeFrame = firstColumnTimeFrame : lastColumnTimeFrame;

numBlocks = numel(blazer.Block);
for i = 1 : numBlocks
    ithBlock = blazer.Block{i};
    ithHeader = [rect.Header, sprintf('[Block:%g]', i)];
    herePrepareInxOfEndogenousPoints( );
    herePrepareTerminal( );
    [exitFlag, error] = run(ithBlock, data, ithHeader);
    if ~isempty(error.EvaluatesToNan)
        break
    end
    if ~hasSucceeded(exitFlag)
        break
    end
end 

if ~isempty(error.EvaluatesToNan)
    throw( ...
        exception.Base('Dynamic:EvaluatesToNan', 'error'), ...
        '', blazer.Model.Equation.Input{error.EvaluatesToNan} ...
    );
end

hereCleanup( );

return


    function herePrepareInxOfEndogenousPoints( )
        inx = false(size(data.YXEPG));
        inx(ithBlock.PosQty, columnsTimeFrame) = true;
        if data.HasExogenizedPoints
            inx(data.InxOfYX, :) = ...
                inx(data.InxOfYX, :) ...
                & ~data.InxOfExogenizedYX;
            inx(data.InxOfE, columnsTimeFrame) = data.InxOfEndogenizedE(:, columnsTimeFrame);
        end
        ithBlock.InxOfEndogenousPoints = inx;
    end%


    function herePrepareTerminal( )
        maxMaxLead = max(ithBlock.MaxLead);
        if ithBlock.Type~=solver.block.Type.SOLVE || maxMaxLead<=0
            ithBlock.Terminal = [ ];
        else
            fotcTimeFrame = [lastColumnTimeFrame+1, lastColumnTimeFrame+maxMaxLead];
            setTimeFrame(rect, fotcTimeFrame);
            ithBlock.Terminal = rect;
        end
    end%


    function hereCleanup( )
        setTimeFrame(rect, [firstColumnTimeFrame, lastColumnTimeFrame]);
    end%
end%

