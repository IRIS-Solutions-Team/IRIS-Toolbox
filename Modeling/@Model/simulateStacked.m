function [exitFlag, dcy] = simulateStacked(simulateFunc, rect, data, blazers)
% simulateStacked  Run stacked-time simulation on one time frame
%
% Backend [IrisToolbox] method
% No help provided

% -[IrisToolbox] for Macroeconomic Modeling
% -Copyright (c) 2007-2020 [IrisToolbox] Solutions Team

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
    % No Blocks
    blazer = blazers(1);
else
    % Block recursive
    blazer = blazers(2);
end

% Set time frame of rect to terminal condition range
% Keep time frame of data set to simulation range
firstColumnFrame = data.FirstColumnOfFrame;
lastColumnFrame = data.LastColumnOfFrame;
columnsFrame = firstColumnFrame : lastColumnFrame;

numBlocks = numel(blazer.Blocks);
for i = 1 : numBlocks
    block__ = blazer.Blocks{i};
    exitFlagHeader = string(rect.Header) + sprintf("[Block:%g]", i);
    herePrepareInxEndogenousPoints( );
    herePrepareTerminal( );
    [exitFlag, error] = run(block__, data, exitFlagHeader);
    if ~isempty(error.EvaluatesToNan) || ~hasSucceeded(exitFlag)
        if blazer.SuccessOnly
            break
        end
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

    function herePrepareInxEndogenousPoints( )
        inx = false(size(data.YXEPG));
        inx(block__.PtrQuantities, columnsFrame) = true;
        if data.HasExogenizedPoints
            inx(data.InxOfYX, :) = ...
                inx(data.InxOfYX, :) ...
                & ~data.InxOfExogenizedYX;
            inx(data.InxOfE, columnsFrame) = data.InxOfEndogenizedE(:, columnsFrame);
        end
        block__.InxOfEndogenousPoints = inx;
    end%


    function herePrepareTerminal( )
        maxMaxLead = max(block__.MaxLead);
        if block__.Type~=solver.block.Type.SOLVE ...
            || isempty(maxMaxLead) || maxMaxLead<=0
            block__.Terminal = [ ];
        else
            fotcFrame = [lastColumnFrame+1, lastColumnFrame+maxMaxLead];
            setFrame(rect, fotcFrame);
            block__.Terminal = rect;
        end
    end%


    function hereCleanup( )
        setFrame(rect, [firstColumnFrame, lastColumnFrame]);
    end%
end%

