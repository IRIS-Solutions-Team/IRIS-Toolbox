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

% -IRIS Macroeconomic Modeling Toolbox
% -Copyright (c) 2007-2022 IRIS Solutions Team

function clickToExpand(axesHandles)

if nargin<1
    axesHandles = gca();
end

persistent parser
if isempty(parser)
    parser = extend.InputParser('visual.clickToExpand');
    parser.addRequired('AxesHandles', @(x) all(isgraphics(x, 'Axes')));
end
parser.parse(axesHandles);

%--------------------------------------------------------------------------

set(axesHandles, 'ButtonDownFcn', @copyAxes);
h = findobj(axesHandles, 'Tag', 'highlight');
set(h, 'ButtonDownFcn', @copyAxes);
h = findobj(axesHandles, 'Tag', 'vline');
set(h, 'ButtonDownFcn', @copyAxes);

end%


%
% Local Production
%


function copyAxes(axesHandle, varargin)
    POSITION = [0.1300, 0.1100, 0.7750, 0.8150];
    LEGEND_PROPERTIES_NOT_TO_REASSIGN = { 'Parent'
                                          'Children' 
                                          'UIContextMenu'
                                          'BeingDeleted'
                                          'BusyAction'
                                          'CreateFcn'
                                          'DeleteFcn'
                                          'ItemHitFcn'
                                          'Type'            };

    if ~strcmpi(get(axesHandle, 'Type'), 'Axes')
        axesHandle = get(axesHandle, 'Parent');
    end
    newFigureHandle = figure( );
    newAxesHandle = copyobj(axesHandle, newFigureHandle);
    set( newAxesHandle, ...
         'Position', POSITION, ...
         'Units', 'normalized', ...
         'ButtonDownFcn', '' );
    legendHandle = getappdata(axesHandle, 'IRIS_OutsideLegend');
    if ~isempty(legendHandle)
        newLegendHandle = legend(newAxesHandle);
        temp = get(legendHandle);
        temp = rmfield(temp, LEGEND_PROPERTIES_NOT_TO_REASSIGN);
        list = fieldnames(temp);
        for i = 1 : numel(list)
            try
                set(newLegendHandle, list{i}, temp.(list{i}));
            end
        end
    end
end%

