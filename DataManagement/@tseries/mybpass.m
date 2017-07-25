function [X,T] = mybpass(X,Start,Band,Opt,TrendOpt)
% mybpass  [Not a public function] General band-pass filter.
%
% Backend IRIS function.
% No help provided.

% -IRIS Macroeconomic Modeling Toolbox.
% -Copyright (c) 2007-2017 IRIS Solutions Team.

%--------------------------------------------------------------------------

% Low and high periodicities and frequencies.
lowPer = max(2,min(Band));
highPer = max(Band);
lowFreq = 2*pi/highPer;
highFreq = 2*pi/lowPer;

% Set the window constant for HWFSF.
if strcmpi(Opt.method,'hwfsf')
    switch Opt.window
        case 'hanning'
            a = 0.50;
        case 'hamming'
            a = 0.53;
        case 'none'
            a = 1;
    end
end

if Opt.log
    X = log(X);
end

if Opt.detrend
    [T,tt,ts,s] = tseries.mytrend(X,Start,TrendOpt);
else
    T = zeros(size(X));
    tt = zeros(size(X));
    ts = zeros(size(X));
    s = [ ];
end

% Include time line in the output trend.
addtime = Opt.detrend ...
    && Opt.addtrend && isinf(highPer);

% Include seasonals in the output trend.
addseason = Opt.detrend ...
    && Opt.addtrend && ~isempty(s) ...
    && s >= lowPer && s <= highPer;

A = [ ];
nobs0 = 0;
for i = 1 : size(X,2)
    sample = getsample(X(:,i));
    nobs = sum(sample);
    if nobs == 0
        continue
    end
    
    % Remove time trend and seasonals, or mean.
    xi = X(sample,i);
    if Opt.detrend
        ti = T(sample,i);
    else
        ti = mean(xi);
        tt(sample,i) = ti;
    end
    xi = xi - ti;
    
    if any(isnan(xi))
        X(:,i) = NaN;
        continue
    end
    
    if strcmpi(Opt.method,'cf')
        % Christiano-Fitzgerald.
        cf( );
    else
        % H-windowed frequency-selective filter.
        hwfsf( );
    end
    
    nobs0 = nobs;
end

% Include time line in the output trend.
if addtime
    X = X + tt;
end

% Include seasonals in the output trend.
if addseason
    X = X + ts;
end

% De-logarithmise back.
if Opt.log
    X = exp(X);
    T = exp(T);
end

% Nested functions.

%***********************************************************************
    function cf( )
        % Christiano-Fitzgerald filter.
        if any(nobs ~= nobs0)
            % Re-calculate C-F projection matrix only if needed.
            A = tseries.mychristianofitzgerald( ...
                nobs,lowPer,highPer,double(Opt.unitroot),0);
        end
        X(sample,i) = A*xi;
        X(~sample,i) = NaN;
    end % cf( ).

%***********************************************************************
    function hwfsf( )
        if nobs ~= nobs0
            freq = (2*pi*(0:nobs-1)/nobs).';
            H = (freq >= lowFreq & freq <= highFreq);
            % Impose symmetry.
            H(2:end) = H(2:end) | H(end:-1:2);
            W = toeplitz([a,(1-a)/2,zeros(1,nobs-2)]);
            W(1,end) = (1-a)/2;
            W(end,1) = (1-a)/2;
            A = W*H;
        end
        X(sample,i) = ifft(A.*fft(xi));
        X(~sample,i) = NaN;
    end % hwfsf( ).

end