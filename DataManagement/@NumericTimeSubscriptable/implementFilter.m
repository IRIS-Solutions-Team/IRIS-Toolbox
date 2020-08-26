function varargout = implementFilter(order, this, varargin)
% implementFilter  Low/high-pass filter with condition information
%
% Backend [IrisToolbox] method
% No help provided

% -[IrisToolbox] for Macroeconomic Modeling
% -Copyright (c) 2007-2020 [IrisToolbox] Solutions Team

% Function `implementFilter` is called from within `hpf`, `llf` and `bwf`.

%( Input parser
persistent pp
if isempty(pp)
    pp = extend.InputParser('@NumericTimeSubscriptable/implementFilter');
    addRequired(pp, 'order', @(x) validate.roundScalar(x, 0, Inf));
    addRequired(pp, 'inputSeries', @(x) isa(x, 'NumericTimeSubscriptable'));
    addOptional(pp, 'range', Inf, @DateWrapper.validateRangeInput);

    addParameter(pp, {'Change', 'Growth'}, [ ], @(x) isempty(x) || isa(x, 'NumericTimeSubscriptable'));
    addParameter(pp, 'Gamma', 1, @(x) isa(x, 'NumericTimeSubscriptable') || validate.numericScalar(x, 0, Inf));
    addParameter(pp, 'CutOff', [ ], @(x) isempty(x) || (isnumeric(x) && all(x(:)>0)));
    addParameter(pp, 'CutOffYear', [ ], @(x) isempty(x) || (isnumeric(x) && all(x(:)>0)));
    addParameter(pp, 'Drift', 0, @validate.numericScalar);
    addParameter(pp, 'Gap', [ ], @(x) isempty(x) || isa(x, 'NumericTimeSubscriptable'));
    addParameter(pp, 'InfoSet', 2, @(x) isequal(x, 1) || isequal(x, 2));
    addParameter(pp, 'Lambda', @auto, @(x) isequal(x, @auto) || isempty(x) || (isnumeric(x) && all(x(:)>0)));
    addParameter(pp, 'Level', [ ], @(x) isempty(x) || isa(x, 'NumericTimeSubscriptable'));
    addParameter(pp, 'Log', false, @validate.logicalScalar);
    addParameter(pp, 'Swap', false, @validate.logicalScalar);
end
%)
opt = parse(pp, order, this, varargin{:});
range = double(pp.Results.range);

if isempty(range)
    varargout{1} = this.empty(this);
    varargout{2} = this.empty(this);
    varargout{3} = NaN;
    varargout{4} = NaN;
    return
end

defaultLambdaFunc = @(freq, order) (10*freq)^order;
lambdaFunc = @(cutoff, order) (2*sin(pi./cutoff)).^(-2*order);
cutoffFunc = @(lambda, order) pi./asin(0.5*lambda.^(-1/(2*order)));
freq = dater.getFrequency(this.Start);

if ~isempty(opt.CutOffYear)
    cutoff = opt.CutOffYear * freq;
    lambda = lambdaFunc(cutoff, order);
elseif ~isempty(opt.CutOff)
    cutoff = opt.CutOff;
    lambda = lambdaFunc(cutoff, order);
else
    if isequal(opt.Lambda, @auto) ...
            || isempty(opt.Lambda) ...
            || isequal(opt.Lambda, 'auto')
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

[inputStart, inputEnd] = resolveRange(this, range);
this = clip(this, inputStart, inputEnd);

lambda = reshape(lambda, 1, [ ]);
drift = reshape(opt.Drift, 1, [ ]);

% Determine the filter range
[filterStart, filterEnd, levelStart, levelEnd, changeStart, changeEnd] = hereGetFilterRange( );
isLevel = ~isempty(levelStart);
isGrowth = ~isempty(changeStart);

% Get time-varying gamma weights; default is 1
gamma = hereGetGamma( );

% Get input, level and growth data on the filtering range
data = getDataFromTo(this, filterStart, filterEnd);

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

[tnd, gap] = numeric.clpf( ...
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

varargout{posLow} = this;
varargout{posLow}.Start = filterStart;
varargout{posLow}.data = tnd;
varargout{posLow} = trim(varargout{posLow});

varargout{posHigh} = this;
varargout{posHigh}.Start = filterStart;
varargout{posHigh}.data = gap;
varargout{posHigh} = trim(varargout{posHigh});

varargout{3} = cutoff;
varargout{4} = lambda;

return

    function [filterStart, filterEnd, levelStart, levelEnd, changeStart, changeEnd] = hereGetFilterRange( )
        if ~isempty(opt.Level) && isa(opt.Level, 'NumericTimeSubscriptable')
            levelStart = opt.Level.Start;
            levelEnd = opt.Level.Start + size(opt.Level.Data, 1) - 1;
        else
            levelStart = [ ];
            levelEnd = [ ];
        end
        if ~isempty(opt.Change) && isa(opt.Change, 'NumericTimeSubscriptable')
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
        if isa(opt.Gamma, 'NumericTimeSubscriptable')
            gamma = getDataFromTo(opt.Gamma, filterStart, filterEnd);
            gamma(isnan(gamma)) = 1;
            gamma = gamma(:, :);
        else
            gamma = reshape(opt.Gamma, 1, [ ]);
        end
    end% 
end%

