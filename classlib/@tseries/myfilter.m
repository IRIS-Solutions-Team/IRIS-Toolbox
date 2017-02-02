function varargout = myfilter(Order,Inp,Range,Opt)
% myfilter  [Not a public function] Low/high-pass filter with soft and hard tunes.
%
% Backend IRIS function.
% No help provided.

% -IRIS Macroeconomic Modeling Toolbox.
% -Copyright (c) 2007-2017 IRIS Solutions Team.

% The function `myfilter` is called from within `hpf`, `llf` and `bwf`.

if isempty(Range)
    varargout{1} = empty(Inp);
    varargout{2} = empty(Inp);
    varargout{3} = NaN;
    varargout{4} = NaN;
    return
end

defaultLambdaFunc = @(freq,order) (10*freq)^order;
lambdaFunc = @(cutoff,order) (2*sin(pi./cutoff)).^(-2*order);
cutoffFunc = @(lambda,order) pi./asin(0.5*lambda.^(-1/(2*order)));
freq = datfreq(Inp.start);

if ~isempty(Opt.cutoffyear)
    cutoff = Opt.cutoffyear * freq;
    lambda = lambdaFunc(cutoff,Order);
elseif ~isempty(Opt.cutoff)
    cutoff = Opt.cutoff;
    lambda = lambdaFunc(cutoff,Order);
else
    if isequal(Opt.lambda,@auto) ...
            || isempty(Opt.lambda) ...
            || isequal(Opt.lambda,'auto')
        if freq == 0 || freq == 365
            utils.error('tseries:myfilter', ...
                ['Option ''lambda='' must be used for tseries objects ', ...
                'with unspecified or daily date frequency.']);
        else
            lambda = defaultLambdaFunc(freq,Order);
        end
    else
        lambda = Opt.lambda;
    end
    cutoff = cutoffFunc(lambda,Order);
end

if any(lambda <= 0)
    utils.error('tseries:myfilter', ...
        'Smoothing parameter must be a positive number.');
end

%--------------------------------------------------------------------------

lambda = lambda(:).';
Opt.drift = Opt.drift(:).';

% Get the input data range.
Range = specrange(Inp,Range);
Inp = resize(Inp,Range);
xStart = Range(1);
xEnd = Range(end);

% Determine the filter range.
lStart = [ ];
gStart = [ ];
lEnd = [ ];
gEnd = [ ];
nPer = [ ];
fStart = [ ];
fEnd = [ ];
doFilterRange( );

% Get time-varying gamma weights; default is 1.
gamma = [ ];
doGamma( );

% Get input, level and growth data on the filtering range.
xData = rangedata(Inp,[fStart,fEnd]);
xSize = size(xData);
xData = xData(:,:);

% Separate soft and hard tunes.
lData = [ ];
lDataSoft = [ ];
lWeight = [ ];
gData = [ ];
gDataSoft = [ ];
gWeight = [ ];
doSeparateSoftHard( );

% Log data and tunes if requested by the user.
if Opt.log
    xData = log(xData);
    if ~isempty(lStart)
        lData = log(lData);
        lDataSoft = log(lDataSoft);
    end
    if ~isempty(gStart)
        gData = log(gData);
        gDataSoft = log(gDataSoft);
    end
end

nLambda = length(lambda);
nDrift = length(Opt.drift);
nx = size(xData,2);
nGamma = size(gamma,2);
if ~isempty(lStart)
    nl = size(lData,2);
else
    nl = [ ];
end
if ~isempty(gStart)
    ng = size(gData,2);
else
    ng = [ ];
end
nLoop = max([nLambda,nDrift,nx,nl,ng,nGamma]);

tnd = nan(nPer,nLoop);
gap = nan(nPer,nLoop);

% Main loop.
for iLoop = 1 : nLoop
    if Opt.infoset == 2
        % Two-sided filter.
        T = nPer;
        doOneColumn( );
        tnd(:,iLoop) = XX(1:nPer);
        gap(:,iLoop) = xi - tnd(:,iLoop);
    else
        % One-sided filter.
        for T = 1 : nPer
            doOneColumn( );
            tnd(T,iLoop) = XX(T);
            gap(T,iLoop) = xi(T) - tnd(T,iLoop);
        end
    end
end

% De-log data back.
if Opt.log
    tnd = exp(tnd);
    gap = exp(gap);
end

% Output arguments.
varargout = cell(1,4);

% The option `'swap='` swaps the first two output arguments, trend and gap.
if ~Opt.swap
    tndPos = 1;
    gapPos = 2;
else
    tndPos = 2;
    gapPos = 1;
end

varargout{tndPos} = Inp;
varargout{tndPos}.start = fStart;
varargout{tndPos}.data = reshape(tnd,[nPer,xSize(2:end)]);
varargout{tndPos} = trim(varargout{tndPos});

varargout{gapPos} = Inp;
varargout{gapPos}.start = fStart;
varargout{gapPos}.data = reshape(gap,[nPer,xSize(2:end)]);
varargout{gapPos} = trim(varargout{gapPos});

varargout{3} = cutoff;
varargout{4} = lambda;


% Nested functions...


%**************************************************************************

    
    function doSeparateSoftHard( )
        % Separate soft and hard level tunes.
        if ~isempty(lStart)
            lData = rangedata(Opt.level,[fStart,fEnd]);
            lData = lData(:,:);
            remove = isinf(imag(lData)) | isnan(imag(lData));
            lData(remove) = NaN;
            lDataSoft = nan(size(lData));
            lWeight = nan(size(lData));
            softindex = imag(lData) ~= 0 & ~isnan(real(lData));
            lDataSoft(softindex) = real(lData(softindex));
            lWeight(softindex) = imag(lData(softindex));
            lWeight = 1./lWeight;
            lData(softindex) = NaN;
        end
        % Separate soft and hard growth tunes.
        if ~isempty(gStart)
            gData = rangedata(Opt.change,[fStart,fEnd]);
            gData = gData(:,:);
            remove = isinf(imag(gData)) | isnan(imag(gData));
            gData(remove) = NaN;
            gDataSoft = nan(size(gData));
            gWeight = nan(size(gData));
            softindex = imag(gData) ~= 0 & ~isnan(real(gData));
            gDataSoft(softindex) = real(gData(softindex));
            gWeight(softindex) = imag(gData(softindex));
            gWeight = 1./gWeight;            
            gData(softindex) = NaN;
        end
    end % doSeparateSoftHard( )


%**************************************************************************

    
    function doFilterRange( )
        if ~isempty(Opt.level) && isa(Opt.level,'tseries')
            lStart = Opt.level.start;
            lEnd = Opt.level.start + size(Opt.level.data,1) - 1;
        else
            lStart = [ ];
            lEnd = [ ];
        end
        if ~isempty(Opt.change) && isa(Opt.change,'tseries')
            gStart = Opt.change.start - 1;
            gEnd = Opt.change.start + size(Opt.change.data,1) - 1;
        else
            gStart = [ ];
            gEnd = [ ];
        end
        fStart = min([xStart,lStart,gStart]);
        fEnd = max([xEnd,lEnd,gEnd]);
        nPer = round(fEnd - fStart + 1);
    end % doFilterRange( )


%**************************************************************************

    
    function doGamma( )
        if isa(Opt.gamma,'tseries')
            gamma = rangedata(Opt.gamma,[fStart,fEnd]);
            gamma(isnan(gamma)) = 1;
            gamma = gamma(:,:);
        else
            gamma = Opt.gamma(:).';
            gamma = gamma(ones(nPer,1),:);
        end
    end % doGamma( )


%**************************************************************************

    
    function doOneColumn( )    
        xi = xData(1:T,min(iLoop,end));
        lambdai = lambda(min(iLoop,end));
        drifti = Opt.drift(min(iLoop,end));
        gammai = gamma(1:T,min(iLoop,end));
        
        % Get current level constraints.
        if ~isempty(lStart)
            li = lData(1:T,min(iLoop,end));
            lsofti = lDataSoft(1:T,min(iLoop,end));
            lweighti = lWeight(1:T,min(iLoop,end));
        end
        
        % Get current growth constraints.
        if ~isempty(gStart)
            gi = gData(1:T,min(iLoop,end));
            gsofti = gDataSoft(1:T,min(iLoop,end));
            gweighti = gWeight(1:T,min(iLoop,end));
        end

        % Multiply observations by gamma weights.
        xi = gammai.*xi;

        % System matrix for filter with no tunes.
        [X,B] = xxPlainSystem(xi,lambdai,gammai,drifti,Order);
        
        % Do soft tunes first because we assume that the coefficient matrix is
        % T-by-T in `xxaddlevelsoft` and `xxaddgrowthsoft`. Hard tunes then expand
        % the system matrix in both dimensions.
        
        % Soft level tunes.
        if ~isempty(lStart) && any(~isnan(lsofti))
            [X,B] = xxAddLevelSoft(X,B,lsofti,lweighti);
        end
        
        % Soft growth tunes.
        if ~isempty(gStart) && any(~isnan(gsofti))
            [X,B] = xxAddGrowthSoft(X,B,gsofti,gweighti);
        end
        
        % Hard level tunes.
        if ~isempty(lStart) && any(~isnan(li))
            [X,B] = xxAddLevel(X,B,li);
        end
        
        % Hard growth tunes.
        if ~isempty(gStart) && any(~isnan(gi))
            [X,B] = xxAddGrowth(X,B,gi);
        end
        
        % Filter the data and discard the lagrange multipliers.
        XX = B \ X;        
    end % doOneColumn( )


end


% Subfunctions...


%**************************************************************************


function [Y,B] = xxAddLevel(Y,B,LData)
LData = LData(:);
index = ~isnan(LData).';
if any(index)
    Y = [Y;LData(index)];
    for j = find(index)
        B(end+1,j) = 1; %#ok<*AGROW>
        B(j,end+1) = 1;
    end
end
end % xxAddLevel( )


%**************************************************************************


function [Y,B] = xxAddGrowth(Y,B,GData)
GData = GData(:);
inx = ~isnan(GData).';
if any(inx)
    Y = [Y;GData(inx)];
    for j = find(inx)
        B(end+1,[j-1,j]) = [-1,1];
        B([j-1,j],end+1) = [-1;1];
    end
end
end % xxAddGrowth( )


%**************************************************************************


function [Y,B] = xxAddLevelSoft(Y,B,LSoft,LW)
inx = ~isnan(LSoft);
inx = inx(:).';
Y(inx) = Y(inx) + LW(inx).*LSoft(inx);
for j = find(inx)
    B(j,j) = B(j,j) + LW(j);
end
end % xxAddLevelSoft( )


%**************************************************************************


function [Y,B] = xxAddGrowthSoft(Y,B,GSoft,GW)
inx = ~isnan(GSoft);
inx = inx(:).';
inx1 = [inx(2:end),false];
Y(inx) = Y(inx) + GW(inx).*GSoft(inx);
Y(inx1) = Y(inx1) - GW(inx).*GSoft(inx);
for j = find(inx)
    B(j-1:j,j-1:j) =  B(j-1:j,j-1:j) + GW(j)*[1,-1;-1,1];
end
end % xxAddLevelSoft( )


%*************************************************************************


function [Y,B] = xxPlainSystem(Y,Lambda,Gamma,Drift,P)
nPer = size(Y,1);
if nPer <= P
    % Trend is simply observations.
    B = zeros(nPer);
else
    row = xxPascalRow(P);
    if rem(P,2) == 0
        % Coefficient signs for even orders (e.g. HPF).
        sgn = (-1).^(0 : 2*P);
    else
        % Coefficient signs for odd orders (e.g. LLF).
        sgn = (-1).^(1 : 2*P+1);
    end
    row = row .* sgn(ones(1,P+1),:);
    if  nPer < 2*P
        B = zeros(nPer);
        rng = -P : P;
        repeat = ones(1,size(row,1));
        for t = 1 : nPer
            isAvail = t+rng >= 1 & t+rng <= nPer;
            keep = all(row == 0 | isAvail(repeat,:),2);
            sumRow = sum(row(keep,:),1);
            B(t,t+rng(isAvail)) = sumRow(isAvail);
        end
        B = B*Lambda;
    else
        BDiags = sum(row,1);
        BDiags = BDiags(ones(1,nPer),:);
        cumRow = cumsum(row,1);
        cumRow(cumRow == 0) = NaN;
        n = min(P,ceil(nPer/2));
        cumRow = cumRow(1:n,:);
        BDiags(1:n,1:2*P+1) = cumRow;
        BDiags(end-P+1:end,end-2*P:end) = cumRow(end:-1:1,end:-1:1);
        BDiags = BDiags*Lambda;
        B = spdiags(BDiags,-P:P,nPer,nPer);
    end
end
nanObs = isnan(Y);
Y(nanObs) = 0;
% Add drift (LLF).
Y(1) = Y(1) - Lambda*Drift;
Y(end) = Y(end) + Lambda*Drift;
% Add time-varying gamma weights or add ones along the main diagonal.
B = xxAddGamma(B,Gamma,nanObs);
end % xxPlainSystem( )


%**************************************************************************


function X2 = xxPascalRow(N)
% xxPascalRows  Get decomposition of one row of the Pascal triangle.
if N == 0
    X2 = 1;
    return
end
% Pascal triangle.
x = [1,1];
for i = 2 : N
    x = sum([x(1:end-1);x(2:end)],1);
    x = [1,x,1];
end
% Row x row.
X2 = x;
for i = 2 : N+1
    X2(i,i:end+1) = x(i)*x;
end
end % xxPascalRow( )


%**************************************************************************


function B = xxAddGamma(B,Gamma,NanObs)
% xxaddgamma  Add gamma weighted terms to the system (default weight is 1).
n = size(B,1);
e = spdiags(Gamma,0,n,n);
e(NanObs,NanObs) = 0;
B = B + e;
end % xxAddGamma( )
