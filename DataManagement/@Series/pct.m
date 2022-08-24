% pct  Percent rate of change
%{
% ## Syntax ##
%
% Input arguments marked with a `~` sign may be omitted
%
%     x = pct(x, ~shift, ...)
%
%
% ## Input Arguments ##
%
% __`x`__ [ Series ] -
% Input time series.
%
% __`~shift`__ [ numeric | `'yoy'` ] -
% Time shift (lag or lead) over which the percent rate of change will be
% computed, i.e. between time t and t+k; if omitted, `shift=-1`; if
% `shift='yoy'` a year-on-year percent rate is calculated (with the actual
% `shift` depending on the date frequency of the input series `x`).
%
%
% ## Output Arguments ##
%
% __`x`__ [ Series ] -
% Percentage rate of change in the input data.
%
%
% ## Options ##
%
% __`'OutputFreq='`__ [ *empty* | Frequency ] -
% Convert the percent rate of change to the requested date
% frequency; empty means plain percent rate of change with no conversion.
%
%
% ## Description ##
%
%
% ## Example ##
%
% In this example, `x` is a monthly time series. The following command
% computes the annualized percent rate of change between month t and t-1:
%
%     pct(x, -1, 'OutputFreq=', 1)
%
% while the following line computes the annualized percent rate of change
% between month t and t-3:
%
%     pct(x, -3, 'OutputFreq=', 1)
%
%
% ## Example ##
%
% In this example, `xm` is a monthly time series and `xq` is a quarterly
% series. The following pairs of commands are equivalent for calculating
% the year-over-year percent rates of change:
% 
%     pct(xm, -12)
%     pct(xm, 'yoy')
%
% and
%
%     pct(xq, -4)
%     pct(xq, 'yoy')
%
%}

% -IRIS Macroeconomic Modeling Toolbox
% -Copyright (c) 2007-2022 IRIS Solutions Team

function this = pct(this, varargin)

if isempty(this.Data)
    return
end

this = roc(this, varargin{:});
this.Data = 100*(this.Data - 1);

end%

