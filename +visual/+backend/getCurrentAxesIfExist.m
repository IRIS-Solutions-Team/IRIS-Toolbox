function h = getCurrentAxesIfExist( )

h = gobjects(0);
currentFigure = get(0, 'CurrentFigure');
if ~isempty(currentFigure)
    h = get(currentFigure, 'CurrentAxes');
end

end
