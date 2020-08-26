function range = specrange(this, range, flag)
% specrange  Time series specific range.
%
%
% Syntax
% =======
%
%     rng = specrange(x, s)
%
%
% Input arguments
% ================
%
% * `x` [ tseries ] - Time series.
%
% * `s` [ numeric | `@all` ] - Range specification; the output range `rng`
% will be constructed from the first and the last element of `s` only.
%
%
% Output arguments
% =================
%
% * `rng` [ numeric ] - Date range constructed from `s` specific to time
% series `x`.
%
%
% Description
% ============
%
% The time series specific range is constructed as `startDate:endDate`
% where
%
% * the start date `startDate` is `s(1)` if `s(1)` is a serial date number, 
% or the start date of the input series `x` if `s(1)` is `Inf`, `-Inf`, or
% `@all`;
%
% * the end date `endDate` is `s(end)` if `s(end)` is a serial date number, 
% or the end date of the input series `x` if `s(end)` is `Inf`, or `@all`.
%
%
% Example
% ========
%
% Create a time series from `2000Q1` to `2001Q4` 
%
%     >> x = tseries( qq(2000, 1):qq(2001, 4), @rand );
%
% The function `specrange` returns the full range of the time series when
% `S` is `Inf`
%
%     >> dat2str( specrange(x, Inf) )
%     ans = 
%       Columns 1 through 6
%         '2000Q1'    '2000Q2'    '2000Q3'    '2000Q4'    '2001Q1'    '2001Q2'
%       Columns 7 through 8
%         '2001Q3'    '2001Q4'
%
% or when `S` is `[-Inf, Inf]`
%
%     >> dat2str( specrange(x, [-Inf, Inf]) )
%     ans = 
%       Columns 1 through 6
%         '2000Q1'    '2000Q2'    '2000Q3'    '2000Q4'    '2001Q1'    '2001Q2'
%       Columns 7 through 8
%         '2001Q3'    '2001Q4'
%
% or when `S` is `@all`
%
%     >> dat2str( specrange(x, @all) )
%     ans = 
%       Columns 1 through 6
%         '2000Q1'    '2000Q2'    '2000Q3'    '2000Q4'    '2001Q1'    '2001Q2'
%       Columns 7 through 8
%         '2001Q3'    '2001Q4'
%
% A range from the start of the time series to a specific date is returned
% when `S(1)` is `-Inf` and `S(end)` is that specific end date:
%
%     >> dat2str( specrange(x, [-Inf, qq(2000, 3)]) )
%     ans = 
%         '2000Q1'    '2000Q2'    '2000Q3'
%
% A range from a specific date to the end of the time series is returned
% when `S(1)` is that specific start date date, and `S(end)` is `Inf`:
%
%     >> dat2str( specrange(x, [qq(2000, 3), Inf]) )
%     ans = 
%         '2000Q3'    '2000Q4'    '2001Q1'    '2001Q2'    '2001Q3'    '2001Q4'
%

% -IRIS Macroeconomic Modeling Toolbox.
% -Copyright (c) 2007-2020 IRIS Solutions Team.

try
    flag; %#ok<VUNUS>
catch
    flag = 'max';
end

%--------------------------------------------------------------------------

len = size(this.Data, 1);

if isequal(range, Inf) || isequal(range, @all) || isequal(range, ':')
    range = this.Start + (0 : len-1);
    if strcmpi(flag, 'min')
        ixObs = all(~isnan(this.Data(:, :)), 2);
        if any(ixObs)
            first = find(ixObs, 1, 'first');
            last = find(ixObs, 1, 'last');
            range = range(first:last);
            if ~isa(range, 'DateWrapper')
                range = DateWrapper(range);
            end
        else
            range = DateWrapper.empty(1, 0);
        end
    end
    return
end

if isempty(range) || all(isnan(range))
    range = DateWrapper.empty(1, 0);
    return
end

if isinf(range(1))
    startDate = this.Start;
else
    startDate = range(1);
end

if isinf(range(end))
    endDate = this.Start + len - 1;
else
    endDate = range(end);
end

range = DateWrapper(startDate:endDate);

end%

