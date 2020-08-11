% filter  Apply rational transfer function (ARMA filter) to time series
%{
% Syntax
%--------------------------------------------------------------------------
%
%     outputSeries = filter(inputSeries, model, range, ...)
%
%
% Input Arguments
%--------------------------------------------------------------------------
%
% __`inputSeries`__ [ Series ]
%
%>    Input time series whose observations will be filtered through a
%>    rational transfer function defined by the Armani `model`.
%
%
% __`model`__ [ Armani ]
%
%>    Rational transfer function, or linear ARMA filter, defined as an
%>    Armani object that will be used to filter the observations of the
%>    `inputSeries`.
%
%
% Output Arguments
%--------------------------------------------------------------------------
%
% __`outputSeries`__ [ Series ]
%
%>    Output time series created by applying a rational transfer function
%>    defined by the `model` to the observations of the `inputSeries` on
%>    the `range`.
%
%
% Options
%--------------------------------------------------------------------------
%
% __`FillMissing=0`__ [ empty | numeric | string | cell ]
%
%>    Method that will be used to fill missing observations; the method
%>    will be passed as an input argument into the standard `fillmissing()`
%>    function; a cell array will be unfolded as a comma separated list; a
%>    numeric scalar `x` is equivalent to `{"constant", x}`; an empty
%>    option means no filling.
%
%
% Description
%--------------------------------------------------------------------------
%
%
% Example
%--------------------------------------------------------------------------
%
%}

% -[IrisToolbox] for Macroeconomic Modeling
% -Copyright (c) 2007-2019 [IrisToolbox] Solutions Team

function this = filter(this, armani, range, varargin)

%( Input parser
persistent pp
if isempty(pp)
    pp = extend.InputParser("@Series/filter");
    addRequired(pp, "inputSeries", @(x) isa(x, "NumericTimeSubscriptable"));
    addRequired(pp, "model", @(x) isa(x, "Armani"));
    addRequired(pp, "range", @DateWrapper.validateRangeInput);
    
    addParameter(pp, "FillMissing", 0);
end
%)
[skipped, opt] = maybeSkip(pp, varargin{:});
if ~skipped
    opt = parse(pp, this, armani, range, varargin{:});
end

%--------------------------------------------------------------------------

[data, startDate] = getDataFromTo(this, range);

if ~isempty(opt.FillMissing)
    data = locallyFillMissing(data, opt.FillMissing);
end

data = filter(armani, data);
this = fill(this, data, startDate);;

end%

%
% Local Functions
%

function data = locallyFillMissing(data, option)
    %(
    if validate.numericScalar(option)
        data = fillmissing(data, "constant", option);
    elseif iscell(option)
        data = fillmissing(data, option{:});
    else
        data = fillmissing(data, option);
    end
    %)
end%

