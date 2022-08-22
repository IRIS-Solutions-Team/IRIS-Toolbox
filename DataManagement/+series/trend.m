% trend  Deterministic trend in numeric array
%
% Backend IRIS function
% No help provided

% -IRIS Macroeconomic Modeling Toolbox
% -Copyright (c) 2007-2022 IRIS Solutions Team

function [T, TT, TS, season] = trend(x, varargin)

persistent parser
if isempty(parser)
    parser = extend.InputParser();
    parser.addRequired('InputData', @isnumeric);
    parser.addParameter('Break', [ ], @(x) isempty(x) || (isnumeric(x) && all(x==round(x)) && all(x>=1)) || validate.date(x));
    parser.addParameter('Season', [ ], @(x) isempty(x) || isequal(x, true) || isequal(x, false) || (isnumeric(x) && isscalar(x) && x>0));
    parser.addParameter('Connect', true, @(x) isequal(x, true) || isequal(x, false));
    parser.addParameter('Diff', false, @(x) isequal(x, true) || isequal(x, false));
    parser.addParameter('Log', false, @(x) isequal(x, true) || isequal(x, false));
    parser.addParameter('StartDate', [ ], @(x) isempty(x) || (validate.date(x) && isscalar(x)));
end
parser.parse(x, varargin{:});
opt = parser.Options;

numPeriods = size(x, 1);
[breakPoints, season] = preprocessOptions(opt, numPeriods);

if opt.Log
    x = log(x);
end

if opt.Diff || opt.Connect
    [TT, TS] = diffTrend(x, breakPoints, season, opt.Connect);
else
    [TT, TS] = levelTrend(x, breakPoints, season);
end
T = TT + TS;

if opt.Log
    T = exp(T);
    TT = exp(TT);
    TS = exp(TS);
end

end


function [breakPoints, season] =  preprocessOptions(opt, numPeriods)
    % Break points
    breakPoints = opt.Break;
    if ~isempty(breakPoints)
        if ~isempty(opt.StartDate)
            breakPoints = dater.rangeLength(opt.StartDate, breakPoints);
        end
        breakPoints = reshape(breakPoints, 1, []);
        breakPoints(breakPoints<1 | breakPoints>numPeriods) = [];
        breakPoints = sort(unique(breakPoints));
    end
    % Seasonals
    if ~isempty(opt.StartDate)
        if isequal(opt.Season, true)
            freq = dater.getFrequency(opt.StartDate);
            if any(freq==[2, 4, 12])
                season = freq;
            end
        elseif isequal(opt.Season, false)
            season = [ ];
        else
            season = opt.Season;
        end
    else
        if isnumeric(opt.Season)
            season = opt.Season;
        else
            season = [ ];
        end
    end
end


function [tt, ts] = levelTrend(x, breakPoints, season)
    [numPeriods, numColumns] = size(x);
    tt = nan(numPeriods, numColumns);
    ts = nan(numPeriods, numColumns);
    % Time line with breaks.
    M = getTimeLine(numPeriods, breakPoints, false);
    % Matrix of seaonal factors.
    s = getSeasonalDummies(numPeriods, season);
    MS = [M, s];
    nm = size(M, 2);
    ns = size(s, 2);
    for i = 1 : numColumns
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


function [tt, ts] = diffTrend(x, breakPoints, season, connect)
    diffX = diff(x, 1, 1);
    [numPeriods, numColumns] = size(x);
    tt = nan(numPeriods, numColumns);
    ts = nan(numPeriods, numColumns);
    % Time line with breaks.
    M = getTimeLine(numPeriods-1, breakPoints, true);
    % Matrix of seaonal factors.
    s = getSeasonalDummies(numPeriods-1, season);
    Q = [M, s];
    nm = size(M, 2);
    ns = size(s, 2);
    for i = 1 : numColumns
        ithDiffX = diffX(:, i);
        sample = getsample(ithDiffX);
        first = find(sample, 1);
        last = find(sample, 1, 'last');
        b = Q(sample, :) \ ithDiffX(sample);
        if any(isnan(b))
            continue
        end
        dtt = M(sample, :) * b(1:nm);
        if ns>0
            dts = s(sample, :) * b(nm+1:end);
        else
            dts = zeros(numPeriods-1, 1);
        end
        tt(first, i) = x(first, i);
        tt(first+1:last+1, i) = dtt;
        tt(first:last+1, i) = cumsum(tt(first:last+1, i));
        if ~connect
            tt(first:last+1, i) = tt(first:last+1, i) + ...
                mean(x(first:last+1, i) - tt(first:last+1, i));
        end
        if ns>0
            ts(first, i) = 0;
            ts(first+1:last+1, i) = cumsum(dts);
            if ~connect
                ts(first:last+1, i) = ts(first:last+1, i) ...
                    - mean(ts(first:last+1, i));
            end
        else
            ts(first:last+1, i) = 0;
        end
    end
end 


function S = getSeasonalDummies(numPeriods, season)
    if isempty(season) || isequal(season, false)
        S = zeros(numPeriods, 0);
    else
        S = zeros(numPeriods, season-1);
        for i = 1 : season-1
            S(i:season:end, i) = 1;
        end
        S(season:season:end, :) = -1;
    end
end


function M = getTimeLine(numPeriods, breakPoints, isDiff)
    % Time line with break points.
    numBreakPoints = length(breakPoints);
    if isDiff
        x = ones(numPeriods, 1);
        M = [x, zeros(numPeriods, numBreakPoints)];
        k = 1;
    else
        x = (0 : numPeriods-1).';
        M = [ones(numPeriods, 1), x, zeros(numPeriods, numBreakPoints)];
        k = 2;
    end
    for i = 1 : numBreakPoints
        M(breakPoints(i):end, k+i) = x(1 : numPeriods-breakPoints(i)+1);
    end
end
