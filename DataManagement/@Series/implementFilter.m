% implementFilter  Implement n-th order high-pass filters
%
% -[IrisToolbox] for Macroeconomic Modeling
% -Copyright (c) 2007-2022 [IrisToolbox] Solutions Team

% >=R2019b
%{
function varargout = implementFilter(order, inputSeries, legacyRange, opt)

arguments
    order (1, 1) double {mustBeInteger, mustBePositive}
    inputSeries Series
    legacyRange (1, :) double {validate.mustBeRange} = Inf

    opt.Range {validate.mustBeRange} = Inf
    opt.Change Series = Series.empty(0, 1)
        opt.Growth__Change = []
    opt.Gamma = 1
    opt.Cutoff = []
    opt.CutoffYear = []
    opt.Drift (1, 1) double = 0
    opt.Gap = []
    opt.InfoSet {mustBeMember(opt.InfoSet, [1, 2])} = 2
    opt.Lambda (1, 1) = @auto
    opt.Level Series = Series.empty(0, 1)
    opt.Log (1, 1) logical = false
    opt.Swap (1, 1) logical = false
end
%}
% >=R2019b


% <=R2019a
%(
function varargout = implementFilter(order, inputSeries, varargin)

order = double(order);

persistent ip
if isempty(ip)
    ip = inputParser(); 
    addOptional(ip, "legacyRange", Inf, @isnumeric);

    addParameter(ip, "Range", Inf);
    addParameter(ip, "Change", Series.empty(0, 1));
        addParameter(ip, "Growth__Change", []);
    addParameter(ip, "Gamma", 1);
    addParameter(ip, "Cutoff", []);
    addParameter(ip, "CutoffYear", []);
    addParameter(ip, "Drift", 0);
    addParameter(ip, "Gap", []);
    addParameter(ip, "InfoSet", 2);
    addParameter(ip, "Lambda", @auto);
    addParameter(ip, "Level", Series.empty(0, 1));
    addParameter(ip, "Log", false);
    addParameter(ip, "Swap", false);
end
parse(ip, varargin{:});
legacyRange = ip.Results.legacyRange;
opt = ip.Results;
%)
% <=R2019a


opt = iris.utils.resolveOptionAliases(opt, [], true);


opt.Range = double(opt.Range);
if isequal(opt.Range, Inf) && ~isequal(legacyRange, Inf)
    opt.Range = double(legacyRange);
end

if isempty(opt.Range)
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

if ~isempty(opt.CutoffYear)
    cutoff = opt.CutoffYear * freq;
    lambda = lambdaFunc(cutoff, order);
elseif ~isempty(opt.Cutoff)
    cutoff = opt.Cutoff;
    lambda = lambdaFunc(cutoff, order);
else
    if isequal(opt.Lambda, @auto) ...
            || isempty(opt.Lambda) ...
            || all(strcmpi(opt.Lambda, 'auto'))
        if freq==Frequency.INTEGER || freq==Frequency.DAILY
            exception.error([
                "Series:implementFilter"
                "Option Lambda= must be used for time series "
                "with integer or daily date frequency."
            ]);
        else
            lambda = defaultLambdaFunc(freq, order);
        end
    else
        lambda = opt.Lambda;
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

[inputStart, inputEnd] = resolveRange(inputSeries, opt.Range);
inputSeries = clip(inputSeries, inputStart, inputEnd);

lambda = reshape(lambda, 1, [ ]);
drift = reshape(opt.Drift, 1, [ ]);

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
    levelData = getDataFromTo(opt.Level, filterStart, filterEnd);
end
if isGrowth
    changeData = getDataFromTo(opt.Change, filterStart, filterEnd);
end

% Log data and tunes if requested by the user.
if opt.Log
    data = log(data);
    fnLogReal = @(x) log(real(x)) + 1i*imag(x);
    if isLevel
        levelData = fnLogReal(levelData);
    end
    if isGrowth
        changeData = fnLogReal(changeData);
    end
end

[tnd, gap] = series.clpf( ...
    data, lambda, order, opt.InfoSet, levelData, changeData, gamma, drift ...
);

% Delog data back
if opt.Log
    tnd = exp(tnd);
    gap = exp(gap);
end

% Output arguments
varargout = cell(1, 4);

% The option `'swap='` swaps the first two output arguments, trend and gap.
if ~opt.Swap
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
        if ~isempty(opt.Level) && isa(opt.Level, 'Series')
            levelStart = opt.Level.Start;
            levelEnd = opt.Level.Start + size(opt.Level.Data, 1) - 1;
        else
            levelStart = [ ];
            levelEnd = [ ];
        end
        if ~isempty(opt.Change) && isa(opt.Change, 'Series')
            changeStart = opt.Change.Start - 1;
            changeEnd = opt.Change.Start + size(opt.Change.Data, 1) - 1;
        else
            changeStart = [ ];
            changeEnd = [ ];
        end
        filterStart = min([inputStart, levelStart, changeStart]);
        filterEnd = max([inputEnd, levelEnd, changeEnd]);
    end%

    
    function gamma = hereGetGamma( )
        if isa(opt.Gamma, 'Series')
            gamma = getDataFromTo(opt.Gamma, filterStart, filterEnd);
            gamma(isnan(gamma)) = 1;
            gamma = gamma(:, :);
        else
            gamma = reshape(opt.Gamma, 1, [ ]);
        end
    end% 
end%

