function this = rebase(this, varargin)
% rebase  Rebase times seriss data to specified period
%
%
% __Syntax__
%
% Input arguments marked with a `~` sign may be omitted
%
%     X = rebase(X, ~BasePeriod, ~BaseValue, ...)
%
%
% __Input Arguments__
%
% * `X` [ Series | tseries ] -  Input time series that will be rebased.
%
% * `~BasePeriod='AllStart'` [ DateWrapper | `'AllStart'` | `'AllEnd'` ] -
% Date relative to which the input data will be rebased (baseValue period);
% `'AllStart'` means the first date for which all time series columns have
% a NaN observation; `'AllEnd'` means the last such date.
%
% * `~BaseValue=1` [ `0` | `1` | `100` ] - Rebasing mode: `B=0` means
% additive rebasing with `0` in the baseValue period; `B=1` means
% multiplicative rebasing with `1` in the baseValue period; `B=100` means
% multiplicative rebasing with `100` in the baseValue period.
%
%
% __Output Arguments__
%
% * `X` [ Series | tseries ] - Rebased time series.
%
%
% __Description__
%
%
% __Example__
%

% -IRIS Macroeconomic Modeling Toolbox
% -Copyright (c) 2007-2020 IRIS Solutions Team

persistent inputParser
if isempty(inputParser)
    inputParser = extend.InputParser('tseries.rebase');
    inputParser.addRequired('InputSeries', @(x) isa(x, 'tseries'));
    inputParser.addOptional('BasePeriod', 'AllStart', @(x) any(strcmpi(x, {'AllStart', 'AllEnd'})) || DateWrapper.validateDateInput(x));
    inputParser.addOptional('BaseValue', 1, @(x) isnumeric(x) && isscalar(x));
end
inputParser.parse(this, varargin{:});
basePeriod = inputParser.Results.BasePeriod;
baseValue = inputParser.Results.BaseValue;

%--------------------------------------------------------------------------

if baseValue==0
    func = @minus;
else
    func = @rdivide;
end

if ischar(basePeriod) || isa(basePeriod, 'string')
    if any(strcmpi(basePeriod, {'AllStart', 'AllEnd'}))
        basePeriod = get(this, basePeriod);
    else
        basePeriod = textinp2dat(basePeriod);
    end
end

% Frequency check
freqOfBasePeriod = dater.getFrequency(basePeriod);
freqOfInput = this.FrequencyAsNumeric;
if isnan(basePeriod) || freqOfBasePeriod~=freqOfInput
    this = this.empty(this);
    return
end

sizeOfData = size(this.Data);
ndimsOfData = ndims(this.Data);
this.Data = this.Data(:,:);

y = getDataFromTo(this, basePeriod, basePeriod);
for i = 1 : size(this.Data, 2)
    this.Data(:,i) = func(this.Data(:,i), y(i));
end

if ndimsOfData>2
    this.Data = reshape(this.Data, sizeOfData);
end

if baseValue~=0 && baseValue~=1
    this.Data = this.Data * baseValue;
end

this = trim(this);

end%
