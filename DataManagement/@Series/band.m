%{
---
title: band
---

# `band`

{== Draw time series with uncerainty bands ==}

## Syntax

    [plotHandle, info] = band([mid, lower], ___)
    [plotHandle, info] = band([mid, lower, upper], ___)
    [plotHandle, info] = band(mid, lower, upper, ___)


%}


%---8<---


% >=R2019b
%{
function [plotHandle, info] = band(mid, lower, upper, opt)

arguments
    mid Series
    lower {locallyValidateBounds} = []
    upper {locallyValidateBounds} = []

    opt.Range {validate.mustBeDate} = [-Inf, Inf]
    opt.AxesHandle (1, 1) = @gca
    opt.PlotSettings (1, :) cell = cell.empty(1, 0)
    opt.Layer (1, 1) string = "top"

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
    addOptional(ip, "lower", []);
    addOptional(ip, "upper", []);

    addParameter(ip, "Range", [-Inf, Inf]);
    addParameter(ip, "AxesHandle", @gca);
    addParameter(ip, "PlotSettings", cell.empty(1, 0));
    addParameter(ip, "Layer", "top");

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

[plotHandle, dates, midData, axesHandle, xCoor] ...
    = Series.implementPlot(@plot, axesHandle, opt.Range, mid, '', opt.PlotSettings{:});

lowerData = getData(lower, dates);
upperData = getData(upper, dates);
bandHandles = series.band(axesHandle, plotHandle, midData, xCoor, lowerData, upperData, opt);

set(axesHandle, 'layer', opt.Layer);

info = struct();
info.BandHandles = bandHandles;
info.Dates = dates;
info.MidData = midData;
info.XCoor = xCoor;

end%

%
% Local validators
%

function locallyValidateBounds(x)
    %(
    if isa(x, 'Series') || isequal(x, [])
        return
    end
    error("Input value must be a time series.");
    %)
end%



