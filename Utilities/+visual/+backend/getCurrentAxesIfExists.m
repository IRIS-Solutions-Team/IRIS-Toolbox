% getCurrentAxesIfExists  Get handle to current axes or empty if no axes exists
%
% Backend [IrisToolbox] method
% No help provided

% -[IrisToolbox] for Macroeconomic Modeling
% -Copyright (c) 2007-2022 [IrisToolbox] Solutions Team

function handleCurrentAxes = getCurrentAxesIfExists( )

handleCurrentFigure = visual.backend.getCurrentFigureIfExists( );
if isempty(handleCurrentFigure)
    handleCurrentAxes = gobjects(0);
else
    handleCurrentAxes = get(handleCurrentFigure, 'CurrentAxes');
end

end%
