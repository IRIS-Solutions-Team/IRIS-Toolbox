% preparePlot  Preprocess common input arguments into Series plot functions
%
% -[IrisToolbox] for Macroeconomic Modeling
% -Copyright (c) 2007-2022 [IrisToolbox] Solutions Team

function [axesHandle, dates, inputSeries, plotSpec, unmatched] = preparePlot(varargin)

persistent ip
if isempty(ip)
    ip = extend.InputParser();
    ip.KeepUnmatched = true;
    ip.addRequired('inputSeries', @(x) isa(x, 'Series'));
    ip.addOptional('plotSpec', cell.empty(1, 0), @local_validatePlotSpec);

    ip.addParameter('Range', Inf);
    ip.addParameter('Transform', []);
    ip.addParameter('AxesHandle', []);
end

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

    opt = ip.parse(inputSeries, varargin{:});
    plotSpec = ip.Results.plotSpec;
    unmatched = ip.UnmatchedInCell;

    if ~isequal(opt.Range, Inf)
        dates = double(opt.Range);
    end

    % Always wrap PlotSpec up in a cell array
    if ~iscell(plotSpec)
        plotSpec = { plotSpec };
    end

    if ~isempty(opt.AxesHandle)
        axesHandle = opt.AxesHandle;
    end
    if isa(axesHandle, 'function_handle')
        axesHandle = axesHandle();
    end

    if isa(opt.Transform, 'function_handle')
        inputSeries = opt.Transform(inputSeries);
    end

end%

%
% Local functions
%

function flag = local_validatePlotSpec(x)
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

