function axesHandle = resolveAxesHandles(whichFromFigure, varargin)

if isgraphics(varargin{1})
    inputHandles = varargin{1};
    varargin(1) = [ ];
    inputHandles = inputHandles(:).';
    indexFigures = isgraphics(inputHandles, 'Figure');
    if any(indexFigures)
        axesHandle = inputHandles(~indexFigures);
        for i = find(indexFigures)
            if strcmpi(whichFromFigure, 'Current')
                currentAxes = get(inputHandles(i), 'CurrentAxes');
                if ~isempty(currentAxes)
                    axesHandle = [axesHandle, currentAxes(:).'];
                end
            elseif strcmpi(whichFromFigure, 'All')
                children = get(inputHandles(i), 'Children');
                childAxes = findobj(children, 'Flat', 'Type', 'Axes');
                if ~isempty(childAxes)
                    axesHandle = [axesHandle, childAxes(:).'];
                end
            end
        end
    else
        axesHandle = inputHandles;
    end
else
    axesHandle = @gca;
end

end%

