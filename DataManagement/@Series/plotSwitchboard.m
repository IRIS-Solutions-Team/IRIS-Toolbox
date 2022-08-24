% plotSwitchboard  Choose plot function
%
% -[IrisToolbox] for Macroeconomic Modeling
% -Copyright (c) 2007-2022 [IrisToolbox] Solutions Team

function ...
    [plotHandle, isTimeAxis] ...
    = plotSwitchboard(plotFunc, axesHandle, xData, yData, plotSpec, smooth, varargin)

plotFuncString = plotFunc;
if isa(plotFuncString, 'function_handle')
    plotFuncString = func2str(plotFuncString);
end

if ~isequal(smooth, false) && numel(yData)>1
    here_smoothData( );
end

switch plotFuncString
    case {'histogram', 'scatter', 'binscatter', 'bubblechart'}
        isTimeAxis = false;
        plotHandle = local_implementNoTimeAxis(axesHandle, plotFunc, yData, plotSpec, varargin);
    case {'barcon', 'series.barcon'}
        % Do not pass plotSpec but do pass user options
        isTimeAxis = true;
        plotHandle = series.barcon(axesHandle, xData, yData, varargin{:});
    case {'bands'}
        isTimeAxis = true;
        plotHandle = implementBands( );
    case {'errorbar', 'series.errorbar'}
        isTimeAxis = true;
        [plotHandle, errorHandle, ~] = series.errorbar(xData, yData, "axesHandle", axesHandle, varargin{:});
        plotHandle = [reshape(plotHandle, 1, []), reshape(errorHandle, 1, [])];
    otherwise
        isTimeAxis = true;
        % DataInf = grfun.myreplacenancols(yData, Inf);
        plotHandle = feval(plotFunc, axesHandle, xData, yData, plotSpec{:});
        if ~isempty(varargin)
            numPlots = numel(plotHandle);
            for i = 1 : numPlots
                set(plotHandle(i), varargin{:});
            end
        end
end

% Modify how dates are displayed in data tips
% if isTimeAxis && isa(xData, 'datetime')
%     try % Works in R2019a+
%         local_modifyDataTip(plotHandle, xData);
%     end
% end

return

    function here_smoothData( )
        numData = numel(xData);
        dt = datetime(xData);
        newXData = reshape(linspace(dt(1), dt(end), 10*numData-1), [ ], 1);
        newYData = interp1(dt, yData, newXData, 'spline');
        xData = newXData;
        yData = newYData;
    end%


    function plotHandle = implementBands( )
        persistent parser
        if isempty(parser)
            parser = extend.InputParser('Series.plotSwitchboard.implementBands');
            parser.KeepUnmatched = true;
            parser.addParameter('BaseColor', @auto, @(x) isequaln(x, @auto) || (isnumeric(x) && (numel(x)==1 || numel(x)==3) && all(x>=0) && all(x<=1)));
            parser.addParameter('Whitening', @auto, @(x) isequaln(x, @auto) || (isnumeric(x) && all(x>=0) && all(x<=1)));
            parser.addParameter('WhiteningMethod', 'FaceAlpha', @(x) validate.anyString(x, 'FaceAlpha', 'FaceColor'));
            parser.addParameter('WhiteColor', 1, @(x) isnumeric(x) && (numel(x)==1 || numel(x)==3) && all(x>=0) && all(x<=1));
            parser.addParameter('PlotSettings', cell.empty(1, 0));
            parser.addParameter('FillSettings', cell.empty(1, 0));
        end
        parse(parser, varargin{:});
        opt = parser.Options;
        unmatched = parser.UnmatchedInCell;

        numPlots = ceil(size(yData, 2)/2);
        extendedXData = [xData(:); flipud(xData(:))];
        plotHandle = gobjects(numPlots, 1);
        holdStatus = ishold(axesHandle);
        colorOrder = get(axesHandle, 'ColorOrder');
        colorOrderIndex = get(axesHandle, 'ColorOrderIndex');
        if isequal(opt.BaseColor, @auto)
            opt.BaseColor = colorOrder(colorOrderIndex, :);
        end
        if isequal(opt.Whitening, @auto)
            opt.Whitening = linspace(1, 0, numPlots+2);
            opt.Whitening = opt.Whitening(2:end-1);
        end
        if numel(opt.WhiteColor)==1
            opt.WhiteColor = opt.WhiteColor*[1, 1, 1];
        end
        for ii = 1 : numPlots
            if ii==2
                hold(axesHandle, 'on');
            end
            left = ii;
            right = size(yData, 2) + 1 - ii;
            yData__ = [yData(:, left); flipud(yData(:, right))];
            if left<right
                [color__, faceAlpha__] = getIthColor(ii, opt.WhiteningMethod);
                plotHandle(ii) = fill( ...
                    axesHandle, extendedXData, yData__, color__ ...
                    , 'faceAlpha', faceAlpha__ ...
                    , 'lineStyle', 'None' ...
                    , unmatched{:} ...
                    , opt.FillSettings{:} ...
                );
            else
                plotHandle(ii) = plot( ...
                    axesHandle, extendedXData, yData__ ...
                    , 'color', opt.BaseColor ...
                    , opt.PlotSettings{:} ...
                );
            end
        end
        if holdStatus
            hold(axesHandle, 'on');
        else
            hold(axesHandle, 'off');
        end

        set(axesHandle, 'ColorOrderIndex', colorOrderIndex);

        return

            function [color, faceAlpha] = getIthColor(i, whiteningMethod)
                whitening = opt.Whitening(i);
                if ~isempty(plotSpec)
                    color = plotSpec{ min(i, end) };
                    if isnumeric(color) && isscalar(color)
                        color = color*[1, 1, 1];
                    end
                    faceAlpha = 1;
                else
                    if strcmpi(whiteningMethod, 'FaceAlpha')
                        color = opt.BaseColor;
                        faceAlpha = 1 - whitening;
                    else
                        color = (1-whitening)*opt.BaseColor + whitening*opt.WhiteColor;
                        faceAlpha = 1;
                    end
                end
            end%
    end%
end%

%
% Local Functions
%

function local_modifyDataTip(plotHandle, xData)
    r = dataTipTextRow('X', 'XData', xData.Format);
    for i = 1 : numel(plotHandle)
        plotHandle(i).DataTipTemplate.DataTipRows(1) = r;
    end
end%


function plotHandle = local_implementNoTimeAxis(axesHandle, plotFunc, yData, plotSpec, settings)
    yData = yData(:, :);
    numColumns = size(yData, 2);
    temp = cell(1, numColumns);
    for i = 1 : numColumns
        temp{i} = yData(:, i);
    end
    plotHandle = plotFunc(axesHandle, temp{:}, plotSpec{:});
    if ~isempty(settings)
        set(plotHandle, settings{:});
    end
end%

