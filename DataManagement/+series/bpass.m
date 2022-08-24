% bpass  General band-pass filter for numeric data
%
% Backend IRIS function
% No help provided

% -IRIS Macroeconomic Modeling Toolbox.
% -Copyright (c) 2007-2022 IRIS Solutions Team.

function [x, trend] = bpass(x, band, varargin)

persistent ip
if isempty(ip)
    ip = extend.InputParser();
    ip.addRequired('InputData', @isnumeric);
    ip.addRequired('Band', @(x) isnumeric(x) && numel(x)==2);
    ip.addParameter('AddTrend', true, @(x) isequal(x, true) || isequal(x, false));
    ip.addParameter('Log', false, @(x) isequal(x, true) || isequal(x, false));
    ip.addParameter('Method', 'cf', @(x) (ischar(x) || isa(x, 'string'))  && any(strcmpi(x, {'cf', 'hwfsf'})));
    ip.addParameter('UnitRoot', true, @(x) isequal(x, true) || isequal(x, false));
    ip.addParameter('Window', 'hamming', @(x) (ischar(x) || isa(x, 'string')) && any(strcmpi(x, {'hamming', 'hanning', 'none'})));
    ip.addParameter('StartDate', [ ], @(x) isempty(x) || (validate.date(x) && isscalar(x)));
    ip.addParameter('Detrend', true, @(x) isequal(x, true) || isequal(x, false) || (iscell(x) && iscellstr(x(1:2:end))));
end
ip.parse(x, band, varargin{:});
opt = ip.Options;

%--------------------------------------------------------------------------

sizeX = size(x);
ndimsX = ndims(x);
x = x(:, :);

% Low and high periodicities and frequencies.
lowPer = max(2, min(band));
highPer = max(band);
lowFreq = 2*pi/highPer;
highFreq = 2*pi/lowPer;

% Set the window constant for HWFSF.
if strcmpi(opt.Method, 'hwfsf')
    switch opt.Window
        case 'hanning'
            a = 0.50;
        case 'hamming'
            a = 0.53;
        case 'none'
            a = 1;
    end
end

if opt.Log
    x = log(x);
end

detrend = ~isequal(opt.Detrend, false);
if detrend
    if isequal(opt.Detrend, true)
        opt.Detrend = cell.empty(1, 0);
    end
    if ~isempty(opt.StartDate)
        opt.Detrend = [ {'StartDate', opt.StartDate}, opt.Detrend ];
    end
    [trend, tt, ts, season] = series.trend(x, opt.Detrend{:});
else
    trend = zeros(size(x));
    tt = zeros(size(x));
    ts = zeros(size(x));
    season = [ ];
end

% Include time line in output trend
addTime = detrend && opt.AddTrend && isinf(highPer);

% Include seasonals in output trend
addSeason = detrend && opt.AddTrend && ~isempty(season) && season>=lowPer && season<=highPer;

A = [ ];
numObs0 = 0;
for i = 1 : size(x, 2)
    sample = getsample(x(:, i));
    numObs = sum(sample);
    if numObs==0
        continue
    end
    ithX = x(sample, i);
    
    % Remove time trend and seasonals
    if detrend
        ithX = ithX - trend(sample, i);
    end

    % Remove mean
    ithMean = mean(ithX);
    trend(sample, i) = trend(sample, i) + ithMean;
    tt(sample, i) = tt(sample, i) + ithMean;
    ithX = ithX - ithMean;
    
    if any(isnan(ithX))
        x(:, i) = NaN;
        continue
    end
    
    if strcmpi(opt.Method, 'cf')
        % Christiano-Fitzgerald.
        cf( );
    else
        % H-windowed frequency-selective filter.
        hwfsf( );
    end
    numObs0 = numObs;
end

% Include time line in the output trend.
if addTime
    x = x + tt;
end

% Include seasonals in the output trend.
if addSeason
    x = x + ts;
end

if opt.Log
    x = exp(x);
    trend = exp(trend);
end

if ndimsX>2
    x = reshape(x, sizeX);
    trend = reshape(trend, sizeX);
end

return


    function cf( )
        % Christiano-Fitzgerald filter
        if any(numObs~=numObs0)
            % Re-calculate C-F projection matrix only if needed
            A = series.christianofitzgerald( ...
                numObs, lowPer, highPer, double(opt.UnitRoot), 0 ...
            );
        end
        x(sample, i) = A*ithX;
        x(~sample, i) = NaN;
    end


    function hwfsf( )
        % H-windowed frequency selective filter
        if numObs~=numObs0
            freq = (2*pi*(0:numObs-1)/numObs).';
            H = (freq>=lowFreq & freq<=highFreq);
            % Impose symmetry.
            H(2:end) = H(2:end) | H(end:-1:2);
            W = toeplitz([a, (1-a)/2, zeros(1, numObs-2)]);
            W(1, end) = (1-a)/2;
            W(end, 1) = (1-a)/2;
            A = W*H;
        end
        x(sample, i) = ifft(A.*fft(ithX));
        x(~sample, i) = NaN;
    end 
end
