function [T, TT, TS, S] = mytrend(x, start, opt)
% mytrend  Determinstic trend in vectors of observations.
%
% Backend IRIS function
% No help provided.

% -IRIS Macroeconomic Modeling Toolbox.
% -Copyright (c) 2007-2017 IRIS Solutions Team.

%--------------------------------------------------------------------------

freq = DateWrapper.getFrequencyFromNumeric(start);
if islogical(opt.season)
    if opt.season
        if freq==52 || freq==365
            utils.error('tseries:mytrend', ...
                ['Cannot use option ''season''=true for tseries objects ', ...
                'with integer or daily date frequency.']);
        end
        S = freq;
    else
        S = [ ];
    end
else
    S = opt.season;
end
if isnumericscalar(S) && (~any(S == [2, 4, 6, 12]))
    S = [ ];
end

% Break points.
nPer = size(x, 1);
bp = round(opt.break - start + 1);
bp = bp(:).';
bp(bp < 1 | bp > nPer) = [ ];
bp = sort(bp);

% Logarithm requested by the user.
if opt.log
    x = log(x);
end

if opt.diff || opt.connect
    [TT, TS] = xxDiffTrend(x, bp, S, opt);
    T = TT + TS;
else
    [TT, TS] = levelTrend(x, bp, S);
    T = TT + TS;
end

% Delogarithmise afterwards.
if opt.log
    T = exp(T);
    if nargout > 1
        TT = exp(TT);
        TS = exp(TS);
    end
end

end




function [tt, ts] = levelTrend(x, bp, s)
[nPer, nx] = size(x);
tt = nan(nPer, nx);
ts = nan(nPer, nx);
% Time line with breaks.
M = getTimeLine(nPer, bp, false);
% Matrix of seaonal factors.
s = getSeason(nPer, s);
MS = [M, s];
nm = size(M, 2);
ns = size(s, 2);
for i = 1 : nx
    sample = getsample(x(:, i));
    b = MS(sample, :) \ x(sample, i);
    if any(isnan(b))
        continue
    end
    tt(sample, i) = M(sample, :) * b(1:nm);
    if ns>0
        ts(sample, i) = s(sample, :) * b(nm+1:end);
    else
        ts(sample, i) = 0;
    end
end
end




function [tt, ts] = xxDiffTrend(x, bp, s, opt)
dX = x(2:end, :) - x(1:end-1, :);
[nPer, nx] = size(x);
tt = nan(nPer, nx);
ts = nan(nPer, nx);
% Time line with breaks.
M = getTimeLine(nPer-1, bp, true);
% Matrix of seaonal factors.
s = getSeason(nPer-1, s);
Q = [M, s];
nm = size(M, 2);
ns = size(s, 2);
for i = 1 : nx
    sample = getsample(dX(:, i));
    first = find(sample, 1);
    last = find(sample, 1, 'last');
    b = Q(sample, :) \ dX(sample, i);
    if any(isnan(b))
        continue
    end
    dtt = M(sample, :) * b(1:nm);
    if ns>0
        dts = s(sample, :) * b(nm+1:end);
    else
        dts = zeros([nPer-1, 1]);
    end
    tt(first, i) = x(first, i);
    tt(first+1:last+1, i) = dtt;
    tt(first:last+1, i) = cumsum(tt(first:last+1, i));
    if ~opt.connect
        tt(first:last+1, i) = tt(first:last+1, i) + ...
            mean(x(first:last+1, i) - tt(first:last+1, i));
    end
    if ns>0
        ts(first, i) = 0;
        ts(first+1:last+1, i) = cumsum(dts);
        if ~opt.connect
            ts(first:last+1, i) = ts(first:last+1, i) ...
                - mean(ts(first:last+1, i));
        end
    else
        ts(first:last+1, i) = 0;
    end
end
end 




function S = getSeason(nPer, ns)
if ~isempty(ns)
    S = zeros(nPer, ns-1);
    for i = 1 : ns-1
        S(i:ns:end, i) = 1;
    end
    S(ns:ns:end, :) = -1;
else
    S = zeros(nPer, 0);
end
end




function M = getTimeLine(nPer, bp, isDiff)
% Time line with break points.
nbp = length(bp);
if isDiff
    x = ones([nPer, 1]);
    M = [x, zeros([nPer, nbp])];
    k = 1;
else
    x = (0 : nPer-1).';
    M = [ones([nPer, 1]), x, zeros([nPer, nbp])];
    k = 2;
end
for i = 1 : nbp
    M(bp(i):end, k+i) = x(1 : nPer-bp(i)+1);
end
end
