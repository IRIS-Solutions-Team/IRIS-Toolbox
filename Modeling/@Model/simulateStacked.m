function exitFlag = simulateStacked(this, blazer, vthRect, vthData)
% simulateStacked  Run stacked-time simulation on one time frame
%
% Backend IRIS function
% No help provided

% -IRIS Macroeconomic Modeling Toolbox
% -Copyright (c) 2007-2019 IRIS Solutions Team

%--------------------------------------------------------------------------

% Set time frame of vthRect to terminal condition range
% Keep time frame of vthData set to simulation range
firstColumnOfTimeFrame = vthData.FirstColumnOfTimeFrame;
lastColumnOfTimeFrame = vthData.LastColumnOfTimeFrame;

numOfBlocks = numel(blazer.Block);
for i = 1 : numOfBlocks
    ithBlk = blazer.Block{i};
    herePrepareTerminal( );
    [exitFlag, error] = run(ithBlk, vthData);
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


    function herePrepareTerminal( )
        maxMaxLead = max(ithBlk.MaxLead);
        if ithBlk.Type~=solver.block.Type.SOLVE || maxMaxLead<=0
            ithBlk.Terminal = [ ];
        else
            fotcTimeFrame = [lastColumnOfTimeFrame+1, lastColumnOfTimeFrame+maxMaxLead];
            setTimeFrame(vthRect, fotcTimeFrame);
            ithBlk.Terminal = vthRect;
        end
    end%


    function hereCleanup( )
        setTimeFrame(vthRect, [firstColumnOfTimeFrame, lastColumnOfTimeFrame]);
    end%
end%

