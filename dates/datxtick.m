function datxtick(varargin)
% datxtick  Change ticks, labels and/or date frequency on x-axis in existing tseries graphs
%
% Syntax
% =======
%
%     datxtick(range, ...)
%     datxtick(ax, range, ...)
%
% Input arguments
% ================
%
% * `ax` [ numeric ] - Handle to the axes object where the changes will be
% made; if not specified, the current axes object, `gca( )`, is changed.
%
% * `range` [ numeric ] - New date range to which the x-axis will be
% changed.
%
% Options
% ========
%
% * `'DatePosition='center'` [ `'start'` | `'center'` | `'end'` ] -
% Position within each period the date tick will be placed (i.e. to denote
% the start of the period, in the center of the period, or the end of the
% period).
%
% * `DateTicks=@auto` [ numeric | `@auto` ] - Individual date ticks;
% `@auto` means the ticks will be determined automatically using the
% standard Matlab algorithm.
%
% See [`dat2str`](dates/dat2str) for date formatting options available.
%
%
% Description
% ============
%
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

% -IRIS Macroeconomic Modeling Toolbox
% -Copyright (c) 2007-2018 IRIS Solutions Team

if all(ishandle(varargin{1}))
    ax = varargin{1};
    varargin(1) = [ ] ;
else
    ax = gca( );
end
ax = ax(:).';

newRange = varargin{1};
varargin(1) = [ ];

persistent parser
if isempty(parser)
    parser = extend.InputParser('dates.datxtick');
    parser.KeepUnmatched = true;
    parser.addRequired('Axes', @(x) all(ishandle(x)));
    parser.addRequired('Range', @DateWrapper.validateRangeInput);
    parser.addDateOptions( );
end
parser.parse(ax, newRange);
opt = parser.Options;

%--------------------------------------------------------------------------

[~, ~, newFreq] = dat2ypf(newRange(1));
for h = ax
    valid = isequal(getappdata(h, 'IRIS_SERIES'), true);
    oldFreq = getappdata(h, 'IRIS_FREQ');
    if ~valid || ~isnumericscalar(oldFreq)
        utils.errorf('dates:datxtick', ...
            ['This axes object has not been created ', ...
            'as a valid tseries graph: %g.'], ...
            h);
    end
    oldRange = getappdata(h, 'IRIS_RANGE');
    oldDatePosition = getappdata(h, 'IRIS_DATE_POSITION');
    oldTime = dat2dec(oldRange, oldDatePosition);
    mydatxtick(h, oldRange, oldTime, newFreq, newRange, opt);
end

end%

