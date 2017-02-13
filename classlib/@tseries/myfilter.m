function varargout = myfilter(order, inp, range, opt)
% myfilter  Low/high-pass filter with soft and hard tunes.
%
% Backend IRIS function.
% No help provided.

% -IRIS Macroeconomic Modeling Toolbox.
% -Copyright (c) 2007-2017 IRIS Solutions Team.

% The function `myfilter` is called from within `hpf`, `llf` and `bwf`.

if isempty(range)
    varargout{1} = empty(inp);
    varargout{2} = empty(inp);
    varargout{3} = NaN;
    varargout{4} = NaN;
    return
end

defaultLambdaFunc = @(freq, order) (10*freq)^order;
lambdaFunc = @(cutoff, order) (2*sin(pi./cutoff)).^(-2*order);
cutoffFunc = @(lambda, order) pi./asin(0.5*lambda.^(-1/(2*order)));
freq = datfreq(inp.Start);

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
        if freq == 0 || freq == 365
            utils.error('tseries:myfilter', ...
                ['Option ''lambda='' must be used for tseries objects ', ...
                'with unspecified or daily date frequency.']);
        else
            lambda = defaultLambdaFunc(freq, order);
        end
    else
        lambda = opt.Lambda;
    end
    cutoff = cutoffFunc(lambda, order);
end

if any(lambda <= 0)
    utils.error('tseries:myfilter', ...
        'Smoothing parameter must be a positive number.');
end

%--------------------------------------------------------------------------

lambda = lambda(:).';
drift = opt.Drift(:).';

% Get the input data range.
range = specrange(inp, range);
inp = resize(inp, range);
xStart = range(1);
xEnd = range(end);

% Determine the filter range.
lStart = [ ];
gStart = [ ];
lEnd = [ ];
gEnd = [ ];
fStart = [ ];
fEnd = [ ];
getFilterRange( );

% Get time-varying gamma weights; default is 1.
gamma = [ ];
getGamma( );

% Get input, level and growth data on the filtering range.
xData = rangedata(inp, [fStart, fEnd]);

% Separate soft and hard tunes.
lData = [ ];
gData = [ ];
if ~isempty(lStart)
    lData = rangedata(opt.Level, [fStart, fEnd]);
end
if ~isempty(gStart)
    gData = rangedata(opt.Change, [fStart, fEnd]);
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

[tnd, gap] = tseries.clpf( ...
    xData, lambda, ...
    'Order=', order, ...
    'InfoSet=', opt.InfoSet, ...
    'Level=', lData, ...
    'Growth=', gData, ...
    'Gamma=', gamma, ...
    'Drift=', drift ...
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




    function getFilterRange( )
        if ~isempty(opt.Level) && isa(opt.Level, 'tseries')
            lStart = opt.Level.Start;
            lEnd = opt.Level.Start + size(opt.Level.Data, 1) - 1;
        else
            lStart = [ ];
            lEnd = [ ];
        end
        if ~isempty(opt.Change) && isa(opt.Change, 'tseries')
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
        if isa(opt.Gamma, 'tseries')
            gamma = rangedata(opt.Gamma, [fStart, fEnd]);
            gamma(isnan(gamma)) = 1;
            gamma = gamma(:, :);
        else
            gamma = opt.Gamma(:).';
        end
    end 
end

