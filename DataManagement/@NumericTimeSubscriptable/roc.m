function this = roc(this, varargin)
% roc  Gross rate of change
%{
% ## Syntax ##
%
% Input arguments marked with a `~` sign may be omitted
%
%     x = roc(x, ~shift, ...)
%
%
% ## Input Arguments ##
%
% __`x`__ [ NumericTimeSubscriptable ] -
% Input time series.
%
% __`~shift=-1`__ [ numeric | `'YoY'` | `'BoY'` | `'EoLY'` ] -
% Time shift (lag or lead) over which the rate of change will be computed,
% i.e. between time t and t+k; the `shift` specified as `'YoY'`, `'BoY'` or
% `'EoLY'` means year-on-year changes, changes relative to the beginning of
% current year, or changes relative to the end of previous year,
% respectively (these do not work with `INTEGER` date frequency).
%
%
% ## Output Arguments ##
%
% __`x`__ [ NumericTimeSubscriptable ] -
% Percentage rate of change in the input data.
%
%
% ## Options ##
%
% __`'OutputFreq='`__ [ *empty* | Frequency ] -
% Convert the rate of change to the requested date
% frequency; empty means plain rate of change with no conversion.
%
%
% ## Description ##
%
%
% ## Example ##
%
% In this example, `x` is a monthly time series. The following command
% computes the rate of change between month t and t-1:
%
%     roc(x, -1)
%
% The following line computes the rate of change between
% month t and t-3:
%
%     roc(x, -3)
%
%
% ## Example ##
%
% In this example, `xm` is a monthly time series and `xq` is a quarterly
% series. The following pairs of commands are equivalent for calculating
% the year-over-year rates of change:
% 
%     roc(xm, -12)
%     roc(xm, 'YoY')
%
% and
%
%     roc(xq, -4)
%     roc(xq, 'YoY')
%
%}

% -[IrisToolbox] Macroeconomic Modeling Toolbox
% -Copyright (c) 2007-2020 [IrisToolbox] Solutions Team

[shift, rows, power] = prepareChange(this, varargin{:});

%--------------------------------------------------------------------------

if isempty(this.data)
    return
end

%**************************************************************************
this = unop(@series.change, this, 0, @rdivide, shift, rows);
%**************************************************************************

if power~=1
    this.Data = this.Data .^ power;
end

end%

