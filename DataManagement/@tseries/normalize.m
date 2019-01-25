function this = normalize(this, varargin)
% normalize  Normalize (or rebase) data to particular date
%
%
% __Syntax__
%
% Input arguments marked with a `~` sign may be omitted.
%
%     X = normalize(X, ~NormDate, ...)
%
%
% __Input arguments__
%
% * `X` [ tseries ] -  Input time series that will be normalized.
%
% * `~NormDate='NaNStart'` [ DateWrapper | `'Start'` | `'End'` |
% `'NanStart'` | `'NanEnd'` ] - Date relative to which the input data will
% be normalize; see help on `tseries.get` to understand `'Start'`, `'End'`,
% `'NaNStart'`, `'NaNEnd'`.
%
%
% __Output arguments__
%
% * `X` [ tseries ] - Normalized time series.
%
%
% __Options__
%
% * `Mode='mult'` [ `'add'` | `'mult'` ]  - Additive or multiplicative
% normalization.
%
%
% __Description__
%
%
% __Example__
%

% -IRIS Macroeconomic Modeling Toolbox
% -Copyright (c) 2007-2019 IRIS Solutions Team

persistent inputParser
if isempty(inputParser)
    inputParser = extend.InputParser('tseries.normalize');
    inputParser.addRequired('InputSeries', @(x) isa(x, 'tseries'));
    inputParser.addOptional('NormDate', 'NaNStart', @(x) any(strcmpi(x, {'Start', 'End', 'NaNStart', 'NaNEnd'})) || DateWrapper.validateDateInput(x));
    inputParser.addParameter('Mode', 'Mult', @(x) any(strncmpi(x, {'Add', 'Mul'}, 3)));
end
inputParser.parse(this, varargin{:});
normDate = inputParser.Results.NormDate;
opt = inputParser.Options;

if ischar(normDate)
    if any(strcmpi(normDate, {'Start', 'End', 'NaNStart', 'NaNEnd'}))
        normDate = get(this, normDate);
    else
        normDate = textinp2dat(normDate);
    end
end

%--------------------------------------------------------------------------

if strncmpi(opt.Mode, 'Add', 3)
    func = @minus;
else
    func = @rdivide;
end

sizeOfData = size(this.Data);
ndimsOfData = ndims(this.Data);
this.Data = this.Data(:, :);

checkFrequencyOrInf(this, normDate);
y = getData(this, normDate);
for i = 1 : size(this.Data, 2)
    this.Data(:, i) = func(this.Data(:, i), y(i));
end

if ndimsOfData>2
    this.Data = reshape(this.Data, sizeOfData);
end
this = trim(this);

end%

