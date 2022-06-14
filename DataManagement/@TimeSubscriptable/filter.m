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


% >=R2019b
%(
function this = filter(this, armani, range, opt)

arguments
    this TimeSubscriptable
    armani (1, 1) Armani
    range {validate.range} = Inf

    opt.FillMissing = 0
end
%)
% >=R2019b


% <=R2019a
%{
function this = filter(this, armani, range, varargin)

persistent ip
if isempty(ip)
    ip = inputParser(); 
    addParameter(ip, "FillMissing", 0);
end
parse(ip, varargin{:});
opt = ip.Results;
%}
% <=R2019a


[data, startDate] = getDataFromTo(this, range);

if ~isempty(opt.FillMissing)
    data = local_fillMissing(data, opt.FillMissing);
end

data = filter(armani, data);
this = fill(this, data, startDate);

end%

%
% Local functions
%

function data = local_fillMissing(data, option)
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
