
% >=R2019b
%{
function varargout = band(mid, lower, upper, opt)

arguments
    mid Series
    lower {local_validateBounds} = []
    upper {local_validateBounds} = []

    opt.Range {validate.mustBeDate} = [-Inf, Inf]
    opt.AxesHandle (1, 1) = @gca
    opt.PlotSettings (1, :) cell = cell.empty(1, 0)
    opt.Layer (1, 1) string = "top"
    opt.ZData (1, 1) double = 1

    opt.White (1, 1) double {mustBeInRange(opt.White, 0, 1)} = 0.85
    opt.Relative (1, 1) logical = true
    opt.ExcludeFromLegend (1, 1) logical = true
end
%}
% >=R2019b


% <=R2019a
%(
function [plotHandle, info] = band(mid, varargin)

persistent ip
if isempty(ip)
    ip = inputParser(); 
    addOptional(ip, "lower", [], @local_validateBounds);
    addOptional(ip, "upper", [], @local_validateBounds);

    addParameter(ip, "Range", [-Inf, Inf]);
    addParameter(ip, "AxesHandle", @gca);
    addParameter(ip, "PlotSettings", cell.empty(1, 0));
    addParameter(ip, "Layer", "top");
    addParameter(ip, "ZData", 1);

    addParameter(ip, "White", 0.85);
    addParameter(ip, "Relative", true);
    addParameter(ip, "ExcludeFromLegend", true);
end
parse(ip, varargin{:});
lower = ip.Results.lower;
upper = ip.Results.upper;
opt = ip.Results;
%)
% <=R2019a


if isequal(lower, []) && isequal(upper, [])
    lower = retrieveColumns(mid, 2);
    if size(mid.Data, 2)>2
        upper = retrieveColumns(mid, 3);
    end
    mid = retrieveColumns(mid, 1);
end

if isequal(upper, [])
    upper = lower;
end


axesHandle = opt.AxesHandle;
if isa(axesHandle, 'function_handle')
    axesHandle = axesHandle();
end

[plotHandle, dates, midData, xCoor, axesHandle] ...
    = Series.implementPlot(@plot, axesHandle, opt.Range, mid, '', opt.PlotSettings{:});

lowerData = getData(lower, dates);
upperData = getData(upper, dates);
bandHandles = series.band(axesHandle, plotHandle, midData, xCoor, lowerData, upperData, opt);

set(plotHandle, "zData", opt.ZData*ones(size(get(plotHandle, "yData"))));
set(axesHandle, 'layer', opt.Layer);

if nargout==0
    return
end

if nargout==1
    varargout = {plotHandle};
    return
end

info = struct();
info.BandHandles = bandHandles;
info.Dates = dates;
info.MidData = midData;
info.LowerData = lowerData;
info.UpperData = upperData;
info.XCoor = xCoor;

varargout = {plotHandle, info};

end%

%
% Local validators
%

function local_validateBounds(x)
    %(
    if isa(x, 'Series') || isequal(x, [])
        return
    end
    error("Input value must be a time series.");
    %)
end%

