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
    if ~strcmpi(get(axesHandle, 'Type'), 'Axes')
        axesHandle = get(axesHandle, 'Parent');
    end

    legendHandle = get(axesHandle, 'Legend');

    newFigureHandle = figure( );
    new = copyobj([legendHandle, axesHandle], newFigureHandle);
    newAxesHandle = new(end);

    set( ...
        newAxesHandle ...
        , 'Position', get(0, 'defaultAxesPosition') ...
        , 'Units', get(0, 'defaultAxesUnits') ...
        , 'ButtonDownFcn', '' ...
    );

    if isempty(legendHandle)
        figureHandle = get(axesHandle, 'Parent');
        outsideLegend = getappdata(figureHandle, 'IRIS_OutsideLegend');
        location = outsideLegend{1};
        outsideLegend(1) = [];
        visual.hlegend(location, newAxesHandle, outsideLegend{:});
    end
    %)
end%

