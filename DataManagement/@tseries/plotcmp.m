function [Ax,Lhs,Rhs,varargout] = plotcmp(varargin)
% plotcmp  Comparison graph for two time series.
%
% Syntax
% =======
%
%     [Ax,Lhs,Rhs] = plotcmp(X,...)
%     [Ax,Lhs,Rhs] = plotcmp(Range,X,...)
%
% Input arguments
% ================
%
% * `Range` [ numeric ] - Date range; if not specified the entire range of
% the input tseries object will be plotted.
%
% * `X` [ tseries ] - Tseries object with two or more columns; the
% difference (between the second and the first column (or any other linear
% combination of its columns specified through the option `'compare='`)
% will be displayed as an RHS area or bar graph.
%
% Output arguments
% =================
%
% * `Ax` [ handle | numeric ] - Handles to the LHS and RHS axes.
%
% * `Lhs` [ handle | numeric ] - Handles to the two original lines.
%
% * `Rhs` [ handle | numeric ] - Handles to the area or bar difference
% graph.
%
% Options
% ========
%
% * `'baseLine='` [ *`true`* | `false` ] - Draw a baseline in the bar/area
% difference graph.
%
% * `'compare='` [ numeric | *`[-1;1]`* ] - Linear combination of the
% observations that will be plotted in the RHS graph; `[-1;1]` means a
% difference between the second series and the first series,
% `X{:,2}-X{:,1}`.
%
% * `'cmpColor='` [ numeric | *`[1,0.75,0.75]`* ] - Color that will be used
% to plot the area or bar difference (comparison) graph.
%
% * `'cmpPlotFunc='` [ `@area` | *`@bar`* ] - Function that will be used
% to plot the difference (comparision) data on the RHS.
%
% See help on [`tseries/plotyy`](tseries/plotyy) for other options
% available.
%
% Description
% ============
%
% Example
% ========

% -IRIS Macroeconomic Modeling Toolbox.
% -Copyright (c) 2007-2021 IRIS Solutions Team.

% AREA, BAND, BAR, BARCON, PLOT, PLOTCMP, PLOTYY, SCATTER, STEM

if isnumeric(varargin{1})
   Range = varargin{1};
   varargin(1) = [ ];
else
   Range = Inf;
end

X = varargin{1};
varargin(1) = [ ];
X.data = X.data(:,:);
if size(X.data,2) < 2
   utils.error('tseries:plotcmp', ...
      'The function plotcmp( ) requires multicolumn input time series.');
end

[opt,varargin] = passvalopt('tseries.plotcmp',varargin{:});

if ~isempty(opt.rhsplotfunc)
    opt.compareplotfunc = opt.rhsplotfunc;
end

%--------------------------------------------------------------------------

X.data = X.data(:,:);
nx = size(X.data,2);
opt.compare = opt.compare(:);
nCmp = length(opt.compare);
if nx > nCmp
    opt.compare(end+1:nx,1) = 0;
elseif nx < nCmp
    opt.compare(nx+1:end,1) = [ ];
end
d = replace(X,X.data * opt.compare,X.start);

[Ax,Lhs,Rhs,varargout{1:nargout-3}] = ...
   plotyy(Range,X,Range,d,varargin{:},'rhsPlotFunc=',opt.cmpplotfunc);

set(Rhs,'faceColor',opt.cmpcolor,'edgeColor',opt.cmpcolor);

if ~opt.baseline
    h = get(Rhs,'BaseLine');
    delete(h);
end

set(Ax(1),'tag','plotcmpLhs');
set(Ax(2),'tag','plotcmpRhs');

end
