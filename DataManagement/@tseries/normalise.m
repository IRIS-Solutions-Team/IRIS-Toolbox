function this = normalise(this, normDate, varargin)
% normalise  Normalise (or rebase) data to particular date.
%
%
% __Syntax__
%
%     X = normalise(X, NormDate, ...)
%
%
% __Input arguments__
%
% * `X` [ tseries ] -  Input time series that will be normalised.
%
% * `NormDate` [ numeric | `'start'` | `'end'` | `'nanStart'` | `'nanEnd'`
% ] - Date relative to which the input data will be normalised; if not
% specified, `'nanStart'` (the first date for which all columns have an
% observation) will be used.
%
%
% __Output arguments__
%
% * `X` [ tseries ] - Normalised time series.
%
%
% __Options__
%
% * `'Mode='` [ `'add'` | *`'mult'`* ]  - Additive or multiplicative
% normalisation.
%
%
% __Description__
%
%
% __Example__
%

% -IRIS Macroeconomic Modeling Toolbox.
% -Copyright (c) 2007-2018 IRIS Solutions Team.

opt = passvalopt('tseries.normalise', varargin{:});

if ischar(normDate)
    if DateWrapper.validateDateInput(normDate)
        normDate = textinp2dat(normDate);
    else
        normDate = get(this, normDate);
    end
end

%--------------------------------------------------------------------------

if strncmpi(opt.mode, 'add', 3)
    func = @minus;
else
    func = @rdivide;
end

sizeOfData = size(this.Data);
this.Data = this.Data(:, :);

y = mygetdata(this, normDate);
for i = 1 : size(this.Data, 2)
    this.Data(:, i) = func(this.Data(:, i), y(i));
end

if length(sizeOfData) > 2
    this.Data = reshape(this.Data, sizeOfData);
end

this = trim(this);

end
