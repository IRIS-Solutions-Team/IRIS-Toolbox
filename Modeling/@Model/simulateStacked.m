function exitFlag = simulateStacked(this, blazers, vthRect, vthData, header)
% simulateStacked  Run stacked-time simulation on one time frame
%
% Backend IRIS function
% No help provided

% -IRIS Macroeconomic Modeling Toolbox
% -Copyright (c) 2007-2019 IRIS Solutions Team

%--------------------------------------------------------------------------

if vthData.HasExogenizedPoints
    % No blocks
    blazer = blazers(1);
else
    % With blocks
    blazer = blazers(2);
end

% Set time frame of vthRect to terminal condition range
% Keep time frame of vthData set to simulation range
firstColumnOfTimeFrame = vthData.FirstColumnOfTimeFrame;
lastColumnOfTimeFrame = vthData.LastColumnOfTimeFrame;
columnsOfTimeFrame = firstColumnOfTimeFrame : lastColumnOfTimeFrame;

numOfBlocks = numel(blazer.Block);
for i = 1 : numOfBlocks
    ithBlock = blazer.Block{i};
    ithHeader = [header, sprintf('[Block %g]', i)];
    herePrepareInxOfEndogenousPoints( );
    herePrepareTerminal( );
    [exitFlag, error] = run(ithBlock, vthData, ithHeader);
    if ~isempty(error.EvaluatesToNan)
        throw( exception.Base('Dynamic:EvaluatesToNan', 'error'), ...
               '', this.Equation.Input{error.EvaluatesToNan} );
    end
    if ~hasSucceeded(exitFlag)
        break
    end
end 

hereCleanup( );

return


    function herePrepareInxOfEndogenousPoints( )
        inx = false(size(vthData.YXEPG));
        if vthData.HasExogenizedPoints
            inx(ithBlock.PosQty, columnsOfTimeFrame) = true;
            inx(vthData.InxOfYX, :) = inx(vthData.InxOfYX, :) ...
                                    & ~vthData.InxOfExogenizedYX;
            inx(vthData.InxOfE, columnsOfTimeFrame) = vthData.InxOfEndogenizedE(:, columnsOfTimeFrame);
        else
            inx(ithBlock.PosQty, columnsOfTimeFrame) = true;
        end
        ithBlock.InxOfEndogenousPoints = inx;
    end%


    function herePrepareTerminal( )
        maxMaxLead = max(ithBlock.MaxLead);
        if ithBlock.Type~=solver.block.Type.SOLVE || maxMaxLead<=0
            ithBlock.Terminal = [ ];
        else
            fotcTimeFrame = [lastColumnOfTimeFrame+1, lastColumnOfTimeFrame+maxMaxLead];
            setTimeFrame(vthRect, fotcTimeFrame);
            ithBlock.Terminal = vthRect;
        end
    end%


    function hereCleanup( )
        setTimeFrame(vthRect, [firstColumnOfTimeFrame, lastColumnOfTimeFrame]);
    end%
end%

