% fft  Discrete Fourier transform of tseries object.
% 
% Syntax
% =======
%
%     [y, range, freq, per] = fft(x)
%     [y, range, freq, per] = fft(x, range, ...)
%
% Input arguments
% ================
%
% * `x` [ tseries ] - Input tseries object that will be transformed.
%
% * `range` [ numeric | Inf ] - Date range.
%
% Output arguments
% =================
%
% * `y` [ numeric ] - Fourier transform with data organised in columns.
%
% * `range` [ numeric ] - Actually used date range.
%
% * `freq` [ numeric ] - Frequencies corresponding to FFT vector elements.
%
% * `per` [ numeric ] - Periodicities corresponding to FFT vector elements.
%
% Options
% ========
%
% * `'full='` [ `true` | *`false`* ] - Return Fourier transform on the whole
% interval [0, 2*pi]; if false only the interval [0, pi] is returned.
%
% Description
% ============
%
% Example
% ========
%
%}


% -[IrisToolbox] for Macroeconomic Modeling
% -Copyright (c) 2007-2021 [IrisToolbox] Solutions Team

% >=R2019b
%(
function [y, range, freq, per] = fft(this, opt)

arguments
    this NumericTimeSubscriptable
    opt.Range {validate.mustBeRange} = Inf
    opt.Full (1, 1) logical = false
end
%)
% >=R2019b

% <=R2019a
%{
function [y, range, freq, per] = fft(this, varargin)

persistent pp
if isempty(pp)
    pp = inputParser();
    addParameter(pp, 'Range', Inf);
    addParameter(pp, 'Full', false);
end
parse(pp, varargin{:});
opt = pp.Results;
%}
% <=R2019a

sizeData = size(this.Data);

if isempty(opt.Range)
    y = zeros([0, sizeData(2:end)]);
    return
end

[data, ~, ~, range] = getDataFromTo(this, opt.Range);
numPeriods = numel(range);

% Run Fourier
y = fft(data(:, :));

% Back out frequencies
freq = 2*pi*(0:numPeriods-1) / numPeriods;

% Convert frequencies to periodicities
index = freq == 0;
per = nan(size(freq));
per(~index) = 2*pi./freq(~index);
per(index) = Inf;

if ~opt.Full
    % Return only data points within [0, pi]
    index = freq <= pi;
    freq = freq(index);
    y = y(index, :);
end
y = reshape(y, [size(y, 1), sizeData(2:end)]);

end%

