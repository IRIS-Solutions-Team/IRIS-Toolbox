function [X,NewRange] = resize(X,Range)
% resize  Clip tseries object down to a specified date range.
%
% Syntax
% =======
%
%     X = resize(X,Range)
%
% Input arguments
% ================
%
% * `X` [ tseries ] - Input tseries object whose date range will be clipped
% down.
%
% * `Range` [ numeric ] - New date range to which the input tseries object
% will be resized; the range can be specified as a `[startDate,endDate]`
% vector where `-Inf` and `Inf` can be used for the dates.
%
% Output arguments
% =================
%
% * `X` [ tseries ] - Output tseries object with its date range clipped
% down to `Range`.
%
% Description
% ============
%
% Example
% ========
%

% -IRIS Macroeconomic Modeling Toolbox.
% -Copyright (c) 2007-2017 IRIS Solutions Team.

% Parse input arguments.
pp = inputParser( );
pp.addRequired('x',@(x) isa(x,'tseries'));
pp.addRequired('range',@isnumeric);
pp.parse(X,Range);

%--------------------------------------------------------------------------

if isempty(Range) || isnan(X.start)
    NewRange = [ ];
    X = empty(X);
    return
elseif all(isinf(Range))
    NewRange = X.start + (0 : size(X.data,1)-1);
    return
end

% Frequency of input tseries must be the same as frequency of new date
% range.
if ~all(freqcmp(Range([1,end]),X.start))
    utils.error('tseries:resize', ...
        ['Frequency of the tseries object and ', ...
        'the date frequency of the new range must be the same.']);
end

% Return immediately if start of new range is before start of input tseries
% and end of new range is after end of input tseries.
if round(Range(1)) <= round(X.start) ...
        && round(Range(end)) >= round(X.start + size(X.data,1) - 1)
    NewRange = X.start + (0 : size(X.data,1)-1);
    return
end

if isinf(Range(1))
    startDate = X.start;
else
    startDate = Range(1);
end

if isinf(Range(end))
    endDate = X.start + size(X.data,1) - 1;
else
    endDate = Range(end);
end

NewRange = startDate : endDate;
tmpSize = size(X.data);
nPer = tmpSize(1);
inx = round(NewRange - X.start + 1);
deleteRows = inx < 1 | inx > nPer;
NewRange(deleteRows) = [ ];
inx(deleteRows) = [ ];

if ~isempty(inx)
    X.data = X.data(:,:);
    X.data = X.data(inx,:);
    X.data = reshape(X.data,[length(inx),tmpSize(2:end)]);
    X.start = NewRange(1);
else
    X.data = zeros([0,tmpSize(2:end)]);
    X.start = NaN;
end

end
