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
% -Copyright (c) 2007-2019 IRIS Solutions Team

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
        persistent parser
        if isempty(parser)
            parser = extend.InputParser('NumericTimeSubscriptable.plotSwitchboard.implementBands');
            parser.KeepUnmatched = true;
            parser.addParameter('BaseColor', @auto, @(x) isequaln(x, @auto) || (isnumeric(x) && (numel(x)==1 || numel(x)==3) && all(x>=0) && all(x<=1)));
            parser.addParameter('Whitening', @auto, @(x) isequaln(x, @auto) || (isnumeric(x) && all(x>=0) && all(x<=1)));
            parser.addParameter('WhiteColor', 1, @(x) isnumeric(x) && (numel(x)==1 || numel(x)==3) && all(x>=0) && all(x<=1));
        end
        parse(parser, varargin{:});
        opt = parser.Options;
        unmatched= parser.UnmatchedInCell;

        numOfPlots = ceil(size(yData, 2)/2);
        extendedXData = [xData(:); flipud(xData(:))];
        plotHandle = gobjects(numOfPlots, 1);
        holdStatus = ishold(axesHandle);
        hold(axesHandle, 'on');
        if isequal(opt.BaseColor, @auto)
            colorOrder = get(axesHandle, 'ColorOrder');
            colorOrderIndex = get(axesHandle, 'ColorOrderIndex');
            opt.BaseColor = colorOrder(colorOrderIndex, :);
        end
        if isequal(opt.Whitening, @auto)
            opt.Whitening = linspace(1, 0, numOfPlots+2);
            opt.Whitening = opt.Whitening(2:end-1);
        end
        if numel(opt.WhiteColor)==1
            opt.WhiteColor = opt.WhiteColor*[1, 1, 1];
        end
        for i = 1 : numOfPlots
            ithYData = [yData(:, i); flipud(yData(:, end+1-i))];
            ithColor = getIthColor(i);
            plotHandle(i) = fill( axesHandle, ...
                                  extendedXData, ...
                                  ithYData, ...
                                  ithColor, ...
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

            function color = getIthColor(i)
                ithWhitening = opt.Whitening(i);
                if ~isempty(plotSpec)
                    color = plotSpec{ min(i, end) };
                    if isnumeric(color) && isscalar(color)
                        color = color*[1, 1, 1];
                    end
                else
                    color = (1-ithWhitening)*opt.BaseColor + ithWhitening*opt.WhiteColor; 
                end
            end%
    end%
end%

