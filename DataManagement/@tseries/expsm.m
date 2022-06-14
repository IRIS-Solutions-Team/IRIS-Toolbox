% expsm  Exponential smoothing
%
% __Syntax__
%
% Input arguments marked with a `~` sign may be omitted.
%
%     X = expsm(X, Beta, ~Range, ...)
%
%
% __Input Arguments__
%
% * `X` [ tseries ] - Input time series.
%
% * `Beta` [ numeric ] - Exponential factor.
%
% __Output Arguments__
%
% * `X` [ tseries ] - Exponentially smoothed series.
%
%
% __Options__
%
% * `Initials=NaN` [ numeric ] - Use this value before the first observation to
% initialize the smoothing.
%
% * `Log=false` [ `true` | `false` ] - Logarithmize the data before
% filtering, de-logarithmize afterwards.
%
% * `Range=Inf` [ Dater ] - Range on which the exponential smoothing will
% be performed; if omitted, the entire time series range is used.
%
%
% __Description__
%
%
% __Examples__
%

% -[IrisToolbox] Macroeconomic Modeling Toolbox
% -Copyright (c) 2007-2022 [IrisToolbox] Solutions Team


% >=R2019b
%{
function this = expsm(this, beta, opt)

arguments
    this
    beta (1, 1) double

    opt.Initials (:, 1) double = double.empty(0, 1)
    opt.Log (1, 1) logical = false
    opt.Range (1, :) double = Inf
end
%}
% >=R2019b


% <=R2019a
%(
function this = expsm(this, beta, varargin)

persistent ip
if isempty(ip)
    ip = inputParser();
    addParameter(ip, 'Initials', []);
    addParameter(ip, 'Log', false);
    addParameter(ip, 'Range', Inf);
end
parse(ip, varargin{:});
opt = ip.Results;
%)
% <=R2019a


    range = double(opt.Range);
    checkFrequency(this, range);
    [data, range] = getData(this, range);
    range = double(range);

    if opt.Log
        data = 100*log(data);
        opt.Initials = 100*log(opt.Initials);
    end

    extendedData = series.expsm(data, beta, opt.Initials);

    if opt.Log
        extendedData = exp(extendedData/100);
    end

    numInitials = round(size(extendedData, 1) - size(data, 1));
    this.Data = extendedData;
    this.Start = range(1) - numInitials;
    this = trim(this);

end%

