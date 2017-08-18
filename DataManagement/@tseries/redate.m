function this = redate(this, oldDate, newDate)
% redate  Change time dimension of time series.
%
% Syntax
% =======
%
%     X = redate(X, oldDate, newDate)
%
% Input arguments
% ================
%
% * `X` [ tseries ] - Input time series.
%
% * `OldDate` [ numeric ] - Base date that will be converted to a new date;
% `OldDate` does not need to be the stard date of `X` and does not even
% need to be within the current date range of `X`.
%
% * `NewDate` [ numeric ] - A new date to which the base date `oldDate`
% will be changed; `NewDate` need not be the same frequency as
% `OldDate`.
%
% Output arguments
% =================
%
% * `X` [ tseries ] - Output tseries object with identical data as the
% input tseries object, but with its time dimension changed.
%
% Description
% ============
%
% Example
% ========
%
% Create a time series on a date range from `2000Q1` to `2000Q4`. Change
% the time dimension of the time series so that `1999Q4` (which is a date
% outside the original time series range) changes into `2009Q4` (which will
% again be a date outside the new time series range).
%
%     >> x = tseries(qq(2000,1):qq(2000,4),1:4)
%     x =
%         tseries object: 4-by-1
%         2000Q1:  1
%         2000Q2:  2
%         2000Q3:  3
%         2000Q4:  4
%         ''
%         user data: empty
%         export files: [0]
%     >> redate(x,qq(1999,4),qq(2009,4))
%     ans =
%         tseries object: 4-by-1
%         2010Q1:  1
%         2010Q2:  2
%         2010Q3:  3
%         2010Q4:  4
%         ''
%         user data: empty
%         export files: [0]
%


% -IRIS Macroeconomic Modeling Toolbox.
% -Copyright (c) 2007-2017 IRIS Solutions Team.

pp = inputParser( );
pp.addRequired('x',@(x) isa(x,'tseries'));
pp.addRequired('oldDate',@isnumericscalar);
pp.addRequired('newDate',@isnumericscalar);
pp.parse(this,oldDate,newDate);

%--------------------------------------------------------------------------

xFreq = get(this,'freq');
oldFreq = DateWrapper.getFrequencyFromNumeric(oldDate);

if oldFreq ~= xFreq
   utils.error('tseries:redate', ...
      'Time series frequency and base date frequency must match.');
end

sh = round(this.start - oldDate);
this.start = newDate + sh;

end
