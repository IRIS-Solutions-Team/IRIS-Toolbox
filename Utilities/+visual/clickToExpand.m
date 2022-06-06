% clickToExpand  Axes will open in a figure window when clicked on
%
% __Syntax__
%
%     visual.clickToExpand(AxesHandles)
%
%
% __Input Arguments__
%
% * `AxesHandles` [ numeric ] - Handle to axes objects that will be added a
% Button Down callback opening them in a newAxesHandle window on mouse click.
%
%
% __Description__
%
%
% __Example__
%

% -[IrisToolbox] for Macroeconomic Modeling
% -Copyright (c) 2007-2022 [IrisToolbox] Solutions Team

function clickToExpand(axesHandles)

    if nargin<1
        axesHandles = gca();
    end

    set(axesHandles, 'ButtonDownFcn', @local_copyAxes);

end%

%
% Local functions
%

function local_copyAxes(axesHandle, varargin)
    %(
    if ~strcmpi(get(axesHandle, 'type'), 'axes')
        axesHandle = get(axesHandle, 'parent');
    end

    legendHandle = get(axesHandle, 'legend');

    newFigureHandle = figure( );
    new = copyobj([legendHandle, axesHandle], newFigureHandle);
    newAxesHandle = new(end);

    set( ...
        newAxesHandle ...
        , 'position', get(0, 'defaultAxesPosition') ...
        , 'units', get(0, 'defaultAxesUnits') ...
        , 'buttonDownFcn', '' ...
    );

    if isempty(legendHandle)
        figureHandle = get(axesHandle, 'parent');
        outsideLegend = getappdata(figureHandle, 'IRIS_OutsideLegend');
        if ~isempty(outsideLegend)
            location = outsideLegend{1};
            outsideLegend(1) = [];
            visual.hlegend(location, newAxesHandle, outsideLegend{:});
        end
    end
    %)
end%

