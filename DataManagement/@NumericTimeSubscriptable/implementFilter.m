function varargout = implementFilter(order, inp, range, opt)
% implementFilter  Low/high-pass filter with condition information
%
% Backend [IrisToolbox] method
% No help provided

% -[IrisToolbox] Macroeconomic Modeling Toolbox
% -Copyright (c) 2007-2020 [IrisToolbox] Solutions Team

% Function `implementFilter` is called from within `hpf`, `llf` and `bwf`.

if isempty(range)
    varargout{1} = inp.empty(inp);
    varargout{2} = inp.empty(inp);
    varargout{3} = NaN;
    varargout{4} = NaN;
    return
end

defaultLambdaFunc = @(freq, order) (10*freq)^order;
lambdaFunc = @(cutoff, order) (2*sin(pi./cutoff)).^(-2*order);
cutoffFunc = @(lambda, order) pi./asin(0.5*lambda.^(-1/(2*order)));
freq = DateWrapper.getFrequencyAsNumeric(inp.Start);

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
            thisError = [
                "NumericTimeSubscriptable:implementFilter"
                "Option Lambda= must be used for time series "
                "with integer or daily date frequency."
            ];
            throw(exception.Base(thisError, 'error'));
        else
            lambda = defaultLambdaFunc(freq, order);
        end
    else
        lambda = opt.Lambda;
    end
    cutoff = cutoffFunc(lambda, order);
end

if any(lambda<=0)
    thisError = [
        "Series:InvalidSmoothingParameter"
        "Smoothing parameter Lambda= must be a positive number. "
    ];
    throw(exception.Base(thisError, 'error'));
end

%--------------------------------------------------------------------------

lambda = reshape(lambda, 1, [ ]);
drift = reshape(opt.Drift, 1, [ ]);

% Get the input data range
range = specrange(inp, range);
inp = resize(inp, range);
xStart = range(1);
xEnd = range(end);

% Determine the filter range
[fStart, fEnd, lStart, lEnd, gStart, gEnd] = getFilterRange( );
isLevel = ~isempty(lStart);
isGrowth = ~isempty(gStart);

% Get time-varying gamma weights; default is 1
gamma = [ ];
getGamma( );

% Get input, level and growth data on the filtering range
xData = getDataFromTo(inp, fStart, fEnd);

% Separate soft and hard tunes
lData = [ ];
gData = [ ];
if isLevel
    lData = getDataFromTo(opt.Level, fStart, fEnd);
end
if isGrowth
    gData = getDataFromTo(opt.Change, fStart, fEnd);
end

% Log data and tunes if requested by the user.
if opt.Log
    xData = log(xData);
    fnLogReal = @(x) log(real(x)) + 1i*imag(x);
    if isLevel
        lData = fnLogReal(lData);
    end
    if isGrowth
        gData = fnLogReal(gData);
    end
end

[tnd, gap] = numeric.clpf( ...
    xData, lambda ...
    , 'Order=', order ...
    , 'InfoSet=', opt.InfoSet ...
    , 'Level=', lData ...
    , 'Growth=', gData ...
    , 'Gamma=', gamma ...
    , 'Drift=', drift ...
);

% De-log data back.
if opt.Log
    tnd = exp(tnd);
    gap = exp(gap);
end

% Output arguments.
varargout = cell(1, 4);

% The option `'swap='` swaps the first two output arguments, trend and gap.
if ~opt.Swap
    tndPos = 1;
    gapPos = 2;
else
    tndPos = 2;
    gapPos = 1;
end

varargout{tndPos} = inp;
varargout{tndPos}.Start = fStart;
varargout{tndPos}.data = tnd;
varargout{tndPos} = trim(varargout{tndPos});

varargout{gapPos} = inp;
varargout{gapPos}.Start = fStart;
varargout{gapPos}.data = gap;
varargout{gapPos} = trim(varargout{gapPos});

varargout{3} = cutoff;
varargout{4} = lambda;

return




    function [fStart, fEnd, lStart, lEnd, gStart, gEnd] = getFilterRange( )
        if ~isempty(opt.Level) && isa(opt.Level, 'NumericTimeSubscriptable')
            lStart = opt.Level.Start;
            lEnd = opt.Level.Start + size(opt.Level.Data, 1) - 1;
        else
            lStart = [ ];
            lEnd = [ ];
        end
        if ~isempty(opt.Change) && isa(opt.Change, 'NumericTimeSubscriptable')
            gStart = opt.Change.Start - 1;
            gEnd = opt.Change.Start + size(opt.Change.Data, 1) - 1;
        else
            gStart = [ ];
            gEnd = [ ];
        end
        fStart = min([xStart, lStart, gStart]);
        fEnd = max([xEnd, lEnd, gEnd]);
    end 



    
    function getGamma( )
        if isa(opt.Gamma, 'NumericTimeSubscriptable')
            gamma = getDataFromTo(opt.Gamma, fStart, fEnd);
            gamma(isnan(gamma)) = 1;
            gamma = gamma(:, :);
        else
            gamma = reshape(opt.Gamma, 1, [ ]);
        end
    end 
end

