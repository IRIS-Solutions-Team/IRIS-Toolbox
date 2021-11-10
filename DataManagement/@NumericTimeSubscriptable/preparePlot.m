% preparePlot  Preprocess common input arguments into NumericTimeSubscriptable plot functions
%
% -[IrisToolbox] for Macroeconomic Modeling
% -Copyright (c) 2007-2021 [IrisToolbox] Solutions Team

function [axesHandle, dates, inputSeries, plotSpec, unmatched] = preparePlot(varargin)

persistent parser
if isempty(parser)
    parser = extend.InputParser('@Series/preparePlot');
    parser.KeepUnmatched = true;
    parser.addRequired('InputSeries', @(x) isa(x, 'NumericTimeSubscriptable'));
    parser.addOptional('PlotSpec', cell.empty(1, 0), @locallyValidatePlotSpec);
    parser.addParameter('Range', Inf);
    parser.addParameter('Transform', []);
end

%--------------------------------------------------------------------------

if ~isempty(varargin) && all(isgraphics(varargin{1}, 'Axes')) 
    axesHandle = varargin{1};
    varargin(1) = [ ];
else
    axesHandle = @gca;
end

if isa(varargin{1}, 'DateWrapper') || isequal(varargin{1}, Inf)
    dates = double(varargin{1});
    varargin(1) = [ ];
elseif isnumeric(varargin{1})
    dates = double(varargin{1});
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

options = parser.parse(inputSeries, varargin{:});
plotSpec = parser.Results.PlotSpec;
unmatched = parser.UnmatchedInCell;

if ~isequal(options.Range, Inf)
    dates = double(options.Range);
end

% Always wrap PlotSpec up in a cell array
if ~iscell(plotSpec)
    plotSpec = { plotSpec };
end

if isa(axesHandle, 'function_handle')
    axesHandle = axesHandle();
end

if isa(options.Transform, 'function_handle')
    inputSeries = options.Transform(inputSeries);
end

end%

%
% Local Functions
%

function flag = locallyValidatePlotSpec(x)
    %(
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
    %)
end%

