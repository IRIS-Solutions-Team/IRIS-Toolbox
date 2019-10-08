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
% __`~shift`__ [ numeric | `'yoy'` ] -
% Time shift (lag or lead) over which the rate of
% change will be computed, i.e. between time t and t+k; if omitted,
% `shift=-1`; if `shift='yoy'` a year-on-year rate is calculated
% depending on the date frequency of the input series `x`.
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
% computes the annualized rate of change between month t and t-1:
%
%     roc(x, -1, 'OutputFreq=', 1)
%
% while the following line computes the annualized rate of change between
% month t and t-3:
%
%     roc(x, -3, 'OutputFreq=', 1)
%
%}

% -IRIS Macroeconomic Modeling Toolbox
% -Copyright (c) 2007-2019 IRIS Solutions Team

persistent pp
if isempty(pp)
    pp = extend.InputParser('NumericTimeSubscriptable.roc');
    addRequired(pp, 'inputSeries', @(x) isa(x, 'NumericTimeSubscriptable'));
    addOptional(pp, 'shift', -1, @(x) (validate.numericScalar(x) && x==round(x)) || strcmpi(x, 'yoy'));
    % Options
    addParameter(pp, 'OutputFreq', [ ], @(x) isempty(x) || isa(Frequency(x), 'Frequency'));
end
pp.parse(this, varargin{:});
sh = pp.Results.shift;
opt = pp.Options;

%--------------------------------------------------------------------------

if isempty(this.data)
    return
end

inputFreq = DateWrapper.getFrequencyAsNumeric(this.Start);
if strcmpi(sh, 'yoy')
    sh = -double(inputFreq);
    if sh==0
        sh = -1;
    end
end

power = 1;
if ~isempty(opt.OutputFreq)
    power = inputFreq / opt.OutputFreq / abs(sh);
end

this = unop(@numeric.roc, this, 0, sh, power);

end%

