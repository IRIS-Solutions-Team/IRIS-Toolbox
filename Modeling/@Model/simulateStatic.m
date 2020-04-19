function [exitFlag, dcy] = simulateStatic(~, rect, data, blazers)
% simulateStatic  Run static simulation on one time frame
%
% Backend IRIS function
% No help provided

% -[IrisToolbox] for Macroeconomic Modeling
% -Copyright (c) 2007-2020 IRIS Solutions Team

%--------------------------------------------------------------------------

dcy = double.empty(0);

firstColumnOfFrame = data.FirstColumnOfFrame;
lastColumnOfFrame = data.LastColumnOfFrame;

initYXEPG = data.YXEPG;
finalYXEPG = data.YXEPG;

blazerWithBlocks = blazers(2);

numBlocks = numel(blazerWithBlocks.Blocks);
for column = firstColumnOfFrame : lastColumnOfFrame
    % Reset initial data
    setFrame(data, [column, column]);
    data.YXEPG = initYXEPG;

    for i = 1 : numBlocks
        block__ = blazerWithBlocks.Blocksk{i};
        ithHeader = [rect.Header, sprintf('[Block %g]', i)];
        block__.Terminal = [ ];
        [exitFlag, error] = run(block__, data, ithHeader);
        if ~isempty(error.EvaluatesToNan)
        end
        if ~hasSucceeded(exitFlag)
            break
        end
    end 

    % Store simulate data
    finalYXEPG(:, column) = data.YXEPG(:, column);
end

if ~isempty(error.EvaluatesToNan)
    throw( ...
        exception.Base('Dynamic:EvaluatesToNan', 'error'), ...
        '', blazer.Model.Equation.Input{error.EvaluatesToNan} ...
    );
end

data.YXEPG = finalYXEPG;

end%

