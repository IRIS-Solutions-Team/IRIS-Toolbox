function handleCurrentFigure = getCurrentFigureIfExists( )
% getCurrentFigureIfExists  Get handle to current figure or empty if no figure exists
%
% Backend IRIS function
% No help provided

% -IRIS Macroeconomic Modeling Toolbox
% -Copyright (c) 2007-2022 IRIS Solutions Team

%--------------------------------------------------------------------------

root = groot( );
handleCurrentFigure = root.CurrentFigure;

end
