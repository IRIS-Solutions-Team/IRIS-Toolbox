function exitFlag = simulateStatic(this, blazers, vthRect, vthData, header)
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

numOfBlocks = numel(blazerWithBlocks.Block);
for column = firstColumnOfTimeFrame : lastColumnOfTimeFrame
    % Reset initial data
    setTimeFrame(vthData, [column, column]);
    vthData.YXEPG = initYXEPG;

    for i = 1 : numOfBlocks
        ithBlk = blazerWithBlocks.Block{i};
        ithHeader = [header, sprintf('[Block %g]', i)];
        ithBlk.Terminal = [ ];
        [exitFlag, error] = run(ithBlk, vthData, ithHeader);
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

