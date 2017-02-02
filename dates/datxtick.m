function datxtick(varargin)
% datxtick  Change ticks, labels and/or date frequency on x-axis in existing tseries graphs.
%
% Syntax
% =======
%
%     datxtick(Range, ...)
%     datxtick(Ax, Range, ...)
%
% Input arguments
% ================
%
% * `Ax` [ numeric ] - Handle to the axes object where the changes will be
% made; if not specified, the current axes object, `gca( )`, is changed.
%
% * `Range` [ numeric ] - New date range to which the x-axis will be
% changed.
%
% Options
% ========
%
% * `'datePosition='` [ `'start'` | `'centre'` | `'end'` ] - Where within
% each given period the date tick will be placed (at the beginning of the
% period, in the middle of the period, or at the end of the period).
%
% * `'dateTicks='` [ numeric | *`Inf`* ] - Individual date ticks; if `Inf`, 
% the ticks will be determined automatically using the standard Matlab
% algorithm.
%
% See [`dat2str`](dates/dat2str) for date formatting options available.
%
% -IRIS Macroeconomic Modeling Toolbox.
% -Copyright (c) 2007-2017 IRIS Solutions Team.
%
% Description
% ============
%
% Example
% ========
%
% Create a graph plotting a quarterly series, and then change the ticks and
% labels on the x-axis to monthly:
%
%     x = Series(qq(2010, 1):qq(2011, 4), @rand);
%     plot(x);
%     datxtick(mm(2010, 1):mm(2011, 12), 'dateFormat=', 'Mmm YYYY');
%

% -IRIS Macroeconomic Modeling Toolbox.
% -Copyright (c) 2007-2017 IRIS Solutions Team.

if all(ishandle(varargin{1}))
    H = varargin{1};
    varargin(1) = [ ] ;
else
    H = gca( );
end
H = H(:).';

NewRange = varargin{1};
varargin(1) = [ ];

pp = inputParser( );
pp.addRequired('H', @(x) all(ishandle(x)));
pp.addRequired('Range', @(x) isnumeric(x) && all(isfinite(x)) && ~isempty(x));
pp.parse(H, NewRange);

opt = passvalopt('dates.datxtick', varargin{:});

%--------------------------------------------------------------------------

[~, ~, newFreq] = dat2ypf(NewRange(1));
for iH = H
    valid = isequal(getappdata(iH, 'IRIS_SERIES'), true);
    oldFreq = getappdata(iH, 'IRIS_FREQ');
    if ~valid || ~isnumericscalar(oldFreq)
        utils.errors('dates:datxtick', ...
            ['This axes object has not been created ', ...
            'as a valid tseries graph: %g.'], ...
            iH);
    end
    oldRange = getappdata(iH, 'IRIS_RANGE');
    oldDatePosition = getappdata(iH, 'IRIS_DATE_POSITION');
    oldTime = dat2dec(oldRange, oldDatePosition);
    mydatxtick(iH, oldRange, oldTime, newFreq, NewRange, opt);
end

end
