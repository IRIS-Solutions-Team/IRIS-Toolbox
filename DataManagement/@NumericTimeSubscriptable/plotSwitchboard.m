function [plotHandle, isTimeAxis] = plotSwitchboard( plotFunc, ...
                                                     axesHandle, ...
                                                     xData, ...
                                                     yData, ...
                                                     plotSpec,...
                                                     varargin )
% plotSwitchboard  Choose plot function
%
% Backend function
% No help provided

% -IRIS Macroeconomic Modeling Toolbox
% -Copyright (c) 2007-2018 IRIS Solutions Team

%--------------------------------------------------------------------------

plotFuncString = plotFunc;
if isa(plotFuncString, 'function_handle')
    plotFuncString = func2str(plotFuncString);
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
            numOfPlots = numel(plotHandle);
            for i = 1 : numOfPlots
                set(plotHandle(i), varargin{:});
            end
        end
end

return




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
        numOfYDataColumns = testNumOfYDataColumns([2, 3, 4]);
        if numOfYDataColumns==2
            tempData = { yData(:, 1), yData(:, 2) };
        elseif numOfYDataColumns==3
            tempData = { yData(:, 1), yData(:, 2), yData(:, 3) };
        elseif numOfYDataColumns==4
            tempData = { yData(:, 1), yData(:, 2), yData(:, 3), yData(:, 4) };
        end
        plotHandle = scatter(axesHandle, tempData{:}, plotSpec{:});
        if ~isempty(varargin)
            set(plotHandle, varargin{:});
        end
    end%




    function plotHandle = implementBands( )
        numOfPlots = ceil(size(yData, 2)/2);
        extendedXData = [xData(:); flipud(xData(:))];
        plotHandle = gobjects(numOfPlots, 1);
        holdStatus = ishold(axesHandle);
        hold(axesHandle, 'on');
        colorOrder = get(axesHandle, 'ColorOrder');
        for i = 1 : numOfPlots
            ithYData = [yData(:, i); flipud(yData(:, end+1-i))];
            if ~isempty(plotSpec)
                ithSpecString = plotSpec( min(i, end) );
                if isnumeric(ithSpecString{1}) && isscalar(ithSpecString{1})
                    ithSpecString{1} = ithSpecString{1}*[1, 1, 1];
                end
            else
                colorOrderIndex = get(axesHandle, 'ColorOrderIndex');
                mixColor = colorOrder(colorOrderIndex, :);
                mixColor = 0.5*mixColor + 0.5*[1, 1, 1];
                ithSpecString = { mixColor };
            end
            plotHandle(i) = fill( axesHandle, ...
                                  extendedXData, ...
                                  ithYData, ...
                                  ithSpecString{:}, ...
                                  'LineStyle', 'None', ...
                                  varargin{:} );
        end
        if holdStatus
            hold(axesHandle, 'on');
        else
            hold(axesHandle, 'off');
        end
    end%
end%

