function [axesHandle, dates, inputSeries, plotSpec, unmatched] = preparePlot(varargin)
% preparePlot  Preprocess common input arguments into NumericTimeSubscriptable plot functions
%
% Backend function
% No help provided

% -IRIS Macroeconomic Modeling Toolbox
% -Copyright (c) 2007-2020 IRIS Solutions Team

persistent parser
if isempty(parser)
    parser = extend.InputParser('NumericTimeSubscriptable.preparePlot');
    parser.KeepUnmatched = true;
    parser.addRequired('InputSeries', @(x) isa(x, 'NumericTimeSubscriptable'));
    parser.addOptional('PlotSpec', cell.empty(1, 0), @validatePlotSpec);
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
    dates = DateWrapper(varargin{1});
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

% Always wrap PlotSpec up in a cell array
if ~iscell(plotSpec)
    plotSpec = { plotSpec };
end

if isa(axesHandle, 'function_handle')
    axesHandle = axesHandle( );
end

end%


%
% Local Functions
%


function flag = validatePlotSpec(x)
    if iscell(x)
        flag = true;
        return
    end
    if ~ischar(x) && ~isa(x, 'string')
        flag = false;
        return
    end
    x = char(x);
    % Bar graph specs
    if any(strcmpi(x, {'grouped', 'stacked', 'hist', 'histc'}))
        flag = true;
        return
    end
    % Line plot specs
    allowedLetters = 'bgrcmykwoxsdph';
    allowedNonletters = '.+*^<>-:';
    checkChars = @(x, allowed) all(any(bsxfun(@eq, x, allowed'), 1));
    inxOfLetters = isletter(x);
    letters = x(inxOfLetters);
    nonletters = x(~inxOfLetters);
    if ~isempty(letters) && ~isequal(letters, unique(letters, 'stable'))
        flag = false;
        return
    end
    if ~isempty(letters) && ~checkChars(letters, allowedLetters)
        flag = false;
        return
    end
    if ~isempty(nonletters) && ~checkChars(nonletters, allowedNonletters)
        flag = false;
        return
    end
    flag = true;
end%

    
    
