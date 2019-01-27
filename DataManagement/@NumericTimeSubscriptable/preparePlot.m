function [axesHandle, dates, inputSeries, plotSpec, unmatched] = preparePlot(varargin)
% preparePlot  Preprocess common input arguments into NumericTimeSubscriptable plot functions
%
% Backend function
% No help provided

% -IRIS Macroeconomic Modeling Toolbox
% -Copyright (c) 2007-2019 IRIS Solutions Team

persistent parser
if isempty(parser)
    parser = extend.InputParser('NumericTimeSubscriptable.preparePlot');
    parser.KeepUnmatched = true;
    parser.addRequired('InputSeries', @(x) isa(x, 'NumericTimeSubscriptable'));
    parser.addOptional('PlotSpec', cell.empty(1, 0), @iscell);
end

%--------------------------------------------------------------------------

if ~isempty(varargin) && all(isgraphics(varargin{1}, 'Axes')) 
    axesHandle = varargin{1};
    varargin(1) = [ ];
else
    axesHandle = @gca;
end

if isa(varargin{1}, 'DateWrapper') || isequal(varargin{1}, Inf)
    dates = varargin{1};
    varargin(1) = [ ];
elseif isnumeric(varargin{1})
    dates = DateWrapper.fromDouble(varargin{1});
    varargin(1) = [ ];
else
    dates = Inf;
end

if ~isempty(varargin)
    inputSeries = varargin{1};
    varargin(1) = [ ];
else
    inputSeries = [ ];
end

parser.parse(inputSeries, varargin{:});
plotSpec = parser.Results.PlotSpec;
unmatched = parser.UnmatchedInCell;

if isa(axesHandle, 'function_handle')
    axesHandle = axesHandle( );
end

end%

