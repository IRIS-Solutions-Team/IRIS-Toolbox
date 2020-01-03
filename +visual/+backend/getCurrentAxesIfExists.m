function handleCurrentAxes = getCurrentAxesIfExists( )
% getCurrentAxesIfExists  Get handle to current axes or empty if no axes exists
%
% Backend IRIS function
% No help provided

% -IRIS Macroeconomic Modeling Toolbox
% -Copyright (c) 2007-2020 IRIS Solutions Team

%--------------------------------------------------------------------------

handleCurrentFigure = visual.backend.getCurrentFigureIfExists( );
if isempty(handleCurrentFigure)
    handleCurrentAxes = gobjects(0);
else
    handleCurrentAxes = get(handleCurrentFigure, 'CurrentAxes');
end

end%
