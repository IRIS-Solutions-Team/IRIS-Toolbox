function [plotHandle, isTimeAxis] = plotSwitchboard( plotFunc, ...
                                                     axesHandle, ...
                                                     xData, ...
                                                     yData, ...
                                                     plotSpec,...
                                                     smooth, ...
                                                     varargin )
% plotSwitchboard  Choose plot function
%
% Backend function
% No help provided

% -[IrisToolbox] for Macroeconomic Modeling
% -Copyright (c) 2007-2020 IRIS Solutions Team

%--------------------------------------------------------------------------

plotFuncString = plotFunc;
if isa(plotFuncString, 'function_handle')
    plotFuncString = func2str(plotFuncString);
end

if ~isequal(smooth, false) && numel(yData)>1
    hereSmoothData( );
end

switch plotFuncString
    case {'binscatter'}
        isTimeAxis = false;
        plotHandle = implementBinScatter( );
    case {'scatter'}
        isTimeAxis = false;
        plotHandle = implementScatter( );
    case {'histogram'}
        isTimeAxis = false;
        plotHandle = histogram(axesHandle, yData, plotSpec{:}, varargin{:});
    case {'barcon', 'numeric.barcon'}
        % Do not pass plotSpec but do pass user options
        isTimeAxis = true;
        plotHandle = numeric.barcon(axesHandle, xData, yData, varargin{:});
    case {'bands'}
        isTimeAxis = true;
        plotHandle = implementBands( );
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
if isTimeAxis && isa(xData, 'datetime')
    try % Works in R2019a+
        hereModifyDataTip(plotHandle, xData);
    end
end

return




    function hereSmoothData( )
        numData = numel(xData);
        dt = datetime(xData);
        newXData = reshape(linspace(dt(1), dt(end), 10*numData-1), [ ], 1);
        newYData = interp1(dt, yData, newXData, 'spline');
        xData = newXData;
        yData = newYData;
    end%




    function numOfYDataColumns = testNumOfYDataColumns(x)
        numOfYDataColumns = size(yData, 2);
        if any(numOfYDataColumns==x)
            return
        end
        THIS_ERROR = { 'TimeSubscriptable:PlotInvalidNumOfColumns'
                       'Invalid number of columns in input time series in %s(~)' };
        throw( exception.Base(THIS_ERROR, 'error'), ...
               plotFuncString );
    end%




    function plotHandle = implementBinScatter( )
        testNumOfYDataColumns(2);
        inxOfNaN = any(isnan(yData), 2);
        plotHandle = binscatter( axesHandle, ...
                                 yData(~inxOfNaN, 1), ...
                                 yData(~inxOfNaN, 2), ...
                                 varargin{:} );
    end%



        
    function plotHandle = implementScatter( )
        numYDataColumns = testNumOfYDataColumns([2, 3, 4]);
        if numYDataColumns==2
            tempData = { yData(:, 1), yData(:, 2) };
        elseif numYDataColumns==3
            tempData = { yData(:, 1), yData(:, 2), yData(:, 3) };
        elseif numYDataColumns==4
            tempData = { yData(:, 1), yData(:, 2), yData(:, 3), yData(:, 4) };
        end
        plotHandle = scatter(axesHandle, tempData{:}, plotSpec{:});
        if ~isempty(varargin)
            set(plotHandle, varargin{:});
        end
    end%




    function plotHandle = implementBands( )
        persistent parser
        if isempty(parser)
            parser = extend.InputParser('NumericTimeSubscriptable.plotSwitchboard.implementBands');
            parser.KeepUnmatched = true;
            parser.addParameter('BaseColor', @auto, @(x) isequaln(x, @auto) || (isnumeric(x) && (numel(x)==1 || numel(x)==3) && all(x>=0) && all(x<=1)));
            parser.addParameter('Whitening', @auto, @(x) isequaln(x, @auto) || (isnumeric(x) && all(x>=0) && all(x<=1)));
            parser.addParameter('WhiteningMethod', 'FaceAlpha', @(x) validate.anyString(x, 'FaceAlpha', 'FaceColor'));
            parser.addParameter('WhiteColor', 1, @(x) isnumeric(x) && (numel(x)==1 || numel(x)==3) && all(x>=0) && all(x<=1));
        end
        parse(parser, varargin{:});
        opt = parser.Options;
        unmatched= parser.UnmatchedInCell;

        numPlots = ceil(size(yData, 2)/2);
        extendedXData = [xData(:); flipud(xData(:))];
        plotHandle = gobjects(numPlots, 1);
        holdStatus = ishold(axesHandle);
        hold(axesHandle, 'on');
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
            ithYData = [yData(:, ii); flipud(yData(:, end+1-ii))];
            [ithColor, ithFaceAlpha] = getIthColor(ii);
            plotHandle(ii) = fill( axesHandle, ...
                                   extendedXData, ...
                                   ithYData, ...
                                   ithColor, ...
                                   'FaceAlpha', ithFaceAlpha, ...
                                   'LineStyle', 'None', ...
                                   unmatched{:} );
        end
        if holdStatus
            hold(axesHandle, 'on');
        else
            hold(axesHandle, 'off');
        end

        set(axesHandle, 'ColorOrderIndex', colorOrderIndex);

        return

            function [color, faceAlpha] = getIthColor(i)
                whitening = opt.Whitening(i);
                if ~isempty(plotSpec)
                    color = plotSpec{ min(i, end) };
                    if isnumeric(color) && isscalar(color)
                        color = color*[1, 1, 1];
                    end
                    faceAlpha = 1;
                else
                    if strcmpi(opt.WhiteningMethod, 'FaceAlpha')
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


function hereModifyDataTip(plotHandle, xData)
    r = dataTipTextRow('X', 'XData', xData.Format);
    for i = 1 : numel(plotHandle)
        plotHandle(i).DataTipTemplate.DataTipRows(1) = r;
    end
end%

