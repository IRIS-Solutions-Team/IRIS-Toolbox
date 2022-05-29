% fanchart  Add fanchart to graph.
%
% Syntax
% =======
%
%     P.fanchart(Cap,X,Std,Prob,...)
%
% Input arguments
% ================
%
% * `P` [ struct ] - Report object created by the
% [`report.new`](report/new) function.
%
% * `Cap` [ char ] - Caption used as a legend entry for the line (mean of
% fanchart)
%
% * `X` [ tseries ] - Tseries object with input data to be displayed.
%
% * `Std` [ tseries ] - Tseries object with standard deviations of input
% data.
%
% * `Prob` [ numeric ] - Confidence porbabilities of intervals to be
% displayed.
%
% Options for fancharts
% ======================
%
% * `'asym='` [ numeric | tseries | *`1`* ] - Ratio of asymmetry (area of
% upper part to one of lower part).
%
% * `'exclude='` [ numeric | true | *`false`* ] - Exclude some of the
% confidence intervals.
%
% * `'factor='` [ numeric | *`1`* ] - factor to increase or decrease input
% standard deviations
%
% * `'fanLegend='` [ cell | `NaN` | *`Inf`* ] -  Legend entries used
% instead of confidence interval values; Inf means all confidence intervals
% values will be used to construct legend entries; NaN means the intervals
% will be exluded from legend; `NaN` in cellstr means the intervals of
% respective fancharts will be exluded from legend.
%
% See help on [`report/series`](report/series) for other options available.
%
% Description
% ============
%
% The confidence intervals are based on normal distributions with standard
% deviations supplied by the user. Optionally, the user can also specify
% assumptions about asymmetry and/or common correction factors.
%
% Example
% ========
%

% -IRIS Macroeconomic Modeling Toolbox.
% -Copyright (c) 2007-2022 IRIS Solutions Team & Sergey Plotnikov.
