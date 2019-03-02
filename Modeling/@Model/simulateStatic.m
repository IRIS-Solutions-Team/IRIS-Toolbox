function exitFlag = simulateStatic(this, blazer, vthRect, vthData)
% simulateStatic  Run static simulation on one time frame
%
% Backend IRIS function
% No help provided

% -IRIS Macroeconomic Modeling Toolbox
% -Copyright (c) 2007-2019 IRIS Solutions Team

%--------------------------------------------------------------------------

firstColumnOfTimeFrame = vthData.FirstColumnOfTimeFrame;
lastColumnOfTimeFrame = vthData.LastColumnOfTimeFrame;

initYXEPG = vthData.YXEPG;
finalYXEPG = vthData.YXEPG;

numOfBlocks = numel(blazer.Block);
for column = firstColumnOfTimeFrame : lastColumnOfTimeFrame
    % Reset initial data
    setTimeFrame(vthData, [column, column]);
    vthData.YXEPG = initYXEPG;

    for i = 1 : numOfBlocks
        ithBlk = blazer.Block{i};
        ithBlk.Terminal = [ ];
        [exitFlag, error] = run(ithBlk, vthData);
        if ~isempty(error.EvaluatesToNan)
            throw( exception.Base('Dynamic:EvaluatesToNan', 'error'), ...
                   '', this.Equation.Input{error.EvaluatesToNan} );
        end
        if ~hasSucceeded(exitFlag)
            break
        end
    end 

    % Store simulate data
    finalYXEPG(:, column) = vthData.YXEPG(:, column);
end

vthData.YXEPG = finalYXEPG;

end%

