% implementFilter  Implement n-th order high-pass filters
%
% -[IrisToolbox] for Macroeconomic Modeling
% -Copyright (c) 2007-2021 [IrisToolbox] Solutions Team

% >=R2019b
%(
function varargout = implementFilter(order, inputSeries, range__, options)

arguments
    order (1, 1) double {mustBeInteger, mustBePositive}
    inputSeries NumericTimeSubscriptable
    range__ (1, :) double {validate.mustBeRange} = Inf

    options.Range {validate.mustBeRange} = Inf
    options.Change Series = Series.empty(0, 1)
    options.Growth Series = Series.empty(0, 1)
    options.Gamma = 1
    options.Cutoff = []
    options.CutoffYear = []
    options.Drift (1, 1) double = 0
    options.Gap = []
    options.InfoSet {mustBeMember(options.InfoSet, [1, 2])} = 2
    options.Lambda (1, 1) = @auto
    options.Level Series = Series.empty(0, 1)
    options.Log (1, 1) logical = false
    options.Swap (1, 1) logical = false
end

if isempty(options.Change) && ~isempty(options.Growth)
    options.Change = options.Growth;
end
%)
% >=R2019b


% <=R2019a
%{
function varargout = implementFilter(order, inputSeries, varargin)

persistent pp
if isempty(pp)
    pp = extend.InputParser('@NumericTimeSubscriptable/implementFilter');
    addRequired(pp, 'order', @(x) validate.roundScalar(x, 0, Inf));
    addRequired(pp, 'inputSeries', @(x) isa(x, 'NumericTimeSubscriptable'));
    addOptional(pp, 'range__', Inf, @validate.range);

    addParameter(pp, 'Range', Inf, @validate.range);
    addParameter(pp, {'Change', 'Growth'}, [ ], @(x) isempty(x) || isa(x, 'NumericTimeSubscriptable'));
    addParameter(pp, 'Gamma', 1, @(x) isa(x, 'NumericTimeSubscriptable') || validate.numericScalar(x, 0, Inf));
    addParameter(pp, 'Cutoff', [ ], @(x) isempty(x) || (isnumeric(x) && all(x(:)>0)));
    addParameter(pp, 'CutoffYear', [ ], @(x) isempty(x) || (isnumeric(x) && all(x(:)>0)));
    addParameter(pp, 'Drift', 0, @validate.numericScalar);
    addParameter(pp, 'Gap', [ ], @(x) isempty(x) || isa(x, 'NumericTimeSubscriptable'));
    addParameter(pp, 'InfoSet', 2, @(x) isequal(x, 1) || isequal(x, 2));
    addParameter(pp, 'Lambda', @auto, @(x) isequal(x, @auto) || isempty(x) || (isnumeric(x) && all(x(:)>0)));
    addParameter(pp, 'Level', [ ], @(x) isempty(x) || isa(x, 'NumericTimeSubscriptable'));
    addParameter(pp, 'Log', false, @validate.logicalScalar);
    addParameter(pp, 'Swap', false, @validate.logicalScalar);
end
options = parse(pp, order, inputSeries, varargin{:});
range__ = pp.Results.range__;
%}
% <=R2019a


range = double(options.Range);
if isequal(range, Inf) && ~isequal(range__, Inf)
    range = double(range__);
end

if isempty(range)
    varargout{1} = inputSeries.empty(inputSeries);
    varargout{2} = inputSeries.empty(inputSeries);
    varargout{3} = NaN;
    varargout{4} = NaN;
    return
end

defaultLambdaFunc = @(freq, order) (10*freq)^order;
lambdaFunc = @(cutoff, order) (2*sin(pi./cutoff)).^(-2*order);
cutoffFunc = @(lambda, order) pi./asin(0.5*lambda.^(-1/(2*order)));
freq = dater.getFrequency(inputSeries.Start);

if ~isempty(options.CutoffYear)
    cutoff = options.CutoffYear * freq;
    lambda = lambdaFunc(cutoff, order);
elseif ~isempty(options.Cutoff)
    cutoff = options.Cutoff;
    lambda = lambdaFunc(cutoff, order);
else
    if isequal(options.Lambda, @auto) ...
            || isempty(options.Lambda) ...
            || isequal(options.Lambda, 'auto')
        if freq==Frequency.INTEGER || freq==Frequency.DAILY
            exception.error([
                "NumericTimeSubscriptable:implementFilter"
                "Option Lambda= must be used for time series "
                "with integer or daily date frequency."
            ]);
        else
            lambda = defaultLambdaFunc(freq, order);
        end
    else
        lambda = options.Lambda;
    end
    cutoff = cutoffFunc(lambda, order);
end

if any(lambda<=0)
    exception.error([
        "Series:InvalidSmoothingParameter"
        "Smoothing parameter Lambda= must be a positive number. "
    ]);
end

%--------------------------------------------------------------------------

[inputStart, inputEnd] = resolveRange(inputSeries, range);
inputSeries = clip(inputSeries, inputStart, inputEnd);

lambda = reshape(lambda, 1, [ ]);
drift = reshape(options.Drift, 1, [ ]);

% Determine the filter range
[filterStart, filterEnd, levelStart, levelEnd, changeStart, changeEnd] = hereGetFilterRange( );
isLevel = ~isempty(levelStart);
isGrowth = ~isempty(changeStart);

% Get time-varying gamma weights; default is 1
gamma = hereGetGamma( );

% Get input, level and growth data on the filtering range
data = getDataFromTo(inputSeries, filterStart, filterEnd);

% Separate soft and hard tunes
levelData = [ ];
changeData = [ ];
if isLevel
    levelData = getDataFromTo(options.Level, filterStart, filterEnd);
end
if isGrowth
    changeData = getDataFromTo(options.Change, filterStart, filterEnd);
end

% Log data and tunes if requested by the user.
if options.Log
    data = log(data);
    fnLogReal = @(x) log(real(x)) + 1i*imag(x);
    if isLevel
        levelData = fnLogReal(levelData);
    end
    if isGrowth
        changeData = fnLogReal(changeData);
    end
end

[tnd, gap] = numeric.clpf( ...
    data, lambda, order, options.InfoSet, levelData, changeData, gamma, drift ...
);

% Delog data back
if options.Log
    tnd = exp(tnd);
    gap = exp(gap);
end

% Output arguments
varargout = cell(1, 4);

% The option `'swap='` swaps the first two output arguments, trend and gap.
if ~options.Swap
    posLow = 1;
    posHigh = 2;
else
    posLow = 2;
    posHigh = 1;
end

varargout{posLow} = inputSeries;
varargout{posLow}.Start = filterStart;
varargout{posLow}.Data = tnd;
varargout{posLow} = trim(varargout{posLow});

varargout{posHigh} = inputSeries;
varargout{posHigh}.Start = filterStart;
varargout{posHigh}.Data = gap;
varargout{posHigh} = trim(varargout{posHigh});

varargout{3} = cutoff;
varargout{4} = lambda;

return

    function [filterStart, filterEnd, levelStart, levelEnd, changeStart, changeEnd] = hereGetFilterRange( )
        if ~isempty(options.Level) && isa(options.Level, 'NumericTimeSubscriptable')
            levelStart = options.Level.Start;
            levelEnd = options.Level.Start + size(options.Level.Data, 1) - 1;
        else
            levelStart = [ ];
            levelEnd = [ ];
        end
        if ~isempty(options.Change) && isa(options.Change, 'NumericTimeSubscriptable')
            changeStart = options.Change.Start - 1;
            changeEnd = options.Change.Start + size(options.Change.Data, 1) - 1;
        else
            changeStart = [ ];
            changeEnd = [ ];
        end
        filterStart = min([inputStart, levelStart, changeStart]);
        filterEnd = max([inputEnd, levelEnd, changeEnd]);
    end%

    
    function gamma = hereGetGamma( )
        if isa(options.Gamma, 'NumericTimeSubscriptable')
            gamma = getDataFromTo(options.Gamma, filterStart, filterEnd);
            gamma(isnan(gamma)) = 1;
            gamma = gamma(:, :);
        else
            gamma = reshape(options.Gamma, 1, [ ]);
        end
    end% 
end%

