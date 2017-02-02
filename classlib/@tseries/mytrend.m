function [T,TT,TS,S] = mytrend(X,Start,Opt)
% mytrend  [Not a public function] Determinstic trend in a series of observations.
%
% Backend IRIS function
% No help provided.

% -IRIS Macroeconomic Modeling Toolbox.
% -Copyright (c) 2007-2017 IRIS Solutions Team.

%--------------------------------------------------------------------------

freq = datfreq(Start);
if islogical(Opt.season)
    if Opt.season
        if freq == 52 || freq == 365
            utils.error('tseries:mytrend', ...
                ['Cannot use option ''season''=true for tseries objects ', ...
                'with unspecified or daily date frequency.']);
        end
        S = freq;
    else
        S = [ ];
    end
else
    S = Opt.season;
end
if isnumericscalar(S) && (~any(S == [2,4,6,12]))
    S = [ ];
end

% Break points.
nPer = size(X,1);
bp = round(Opt.break - Start + 1);
bp = bp(:).';
bp(bp < 1 | bp > nPer) = [ ];
bp = sort(bp);

% Logarithm requested by the user.
if Opt.log
    X = log(X);
end

if Opt.diff || Opt.connect
    [TT,TS] = xxDiffTrend(X,bp,S,Opt);
    T = TT + TS;
else
    [TT,TS] = xxLevelTrend(X,bp,S);
    T = TT + TS;
end

% Delogarithmise afterwards.
if Opt.log
    T = exp(T);
    if nargout > 1
        TT = exp(TT);
        TS = exp(TS);
    end
end

end


% Subfunctions...


%**************************************************************************


function [TT,TS] = xxLevelTrend(X,BP,S)
[nPer,nx] = size(X);
TT = nan(nPer,nx);
TS = nan(nPer,nx);
% Time line with breaks.
M = xxTimeLine(nPer,BP,false);
% Matrix of seaonal factors.
S = xxSeason(nPer,S);
MS = [M,S];
nm = size(M,2);
ns = size(S,2);
for i = 1 : nx
    sample = getsample(X(:,i));
    b = MS(sample,:) \ X(sample,i);
    if any(isnan(b))
        continue
    end
    TT(sample,i) = M(sample,:) * b(1:nm);
    if ns > 0
        TS(sample,i) = S(sample,:) * b(nm+1:end);
    else
        TS(sample,i) = 0;
    end
end
end % xxLevelTrend( )


%**************************************************************************


function [TT,TS] = xxDiffTrend(X,BP,S,Opt)
dX = X(2:end,:) - X(1:end-1,:);
[nPer,nx] = size(X);
TT = nan(nPer,nx);
TS = nan(nPer,nx);
% Time line with breaks.
M = xxTimeLine(nPer-1,BP,true);
% Matrix of seaonal factors.
S = xxSeason(nPer-1,S);
Q = [M,S];
nm = size(M,2);
ns = size(S,2);
for i = 1 : nx
    sample = getsample(dX(:,i));
    first = find(sample,1);
    last = find(sample,1,'last');
    b = Q(sample,:) \ dX(sample,i);
    if any(isnan(b))
        continue
    end
    dtt = M(sample,:) * b(1:nm);
    if ns > 0
        dts = S(sample,:) * b(nm+1:end);
    else
        dts = zeros([nPer-1,1]);
    end
    TT(first,i) = X(first,i);
    TT(first+1:last+1,i) = dtt;
    TT(first:last+1,i) = cumsum(TT(first:last+1,i));
    if ~Opt.connect
        TT(first:last+1,i) = TT(first:last+1,i) + ...
            mean(X(first:last+1,i) - TT(first:last+1,i));
    end
    if ns > 0
        TS(first,i) = 0;
        TS(first+1:last+1,i) = cumsum(dts);
        if ~Opt.connect
            TS(first:last+1,i) = TS(first:last+1,i) ...
                - mean(TS(first:last+1,i));
        end
    else
        TS(first:last+1,i) = 0;
    end
end
end % xxDiffTrend( )


%**************************************************************************


function S = xxSeason(NPer,NS)
if ~isempty(NS)
    S = zeros(NPer,NS-1);
    for i = 1 : NS-1
        S(i:NS:end,i) = 1;
    end
    S(NS:NS:end,:) = -1;
else
    S = zeros(NPer,0);
end
end % xxSeason( )


%**************************************************************************


function M = xxTimeLine(nper,bp,diff)
% Time line with break points.
nbp = length(bp);
if diff
    x = ones([nper,1]);
    M = [x,zeros([nper,nbp])];
    k = 1;
else
    x = (0 : nper-1).';
    M = [ones([nper,1]),x,zeros([nper,nbp])];
    k = 2;
end
for i = 1 : nbp
    M(bp(i):end,k+i) = x(1 : nper-bp(i)+1);
end
end % xxTimeLine( )
