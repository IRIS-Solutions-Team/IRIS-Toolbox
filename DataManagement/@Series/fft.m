% >=R2019b
%{
function [y, range, freq, per] = fft(this, opt)

arguments
    this Series

    opt.Range {validate.mustBeRange} = Inf
    opt.Full (1, 1) logical = false
end
%}
% >=R2019b


% <=R2019a
%(
function [y, range, freq, per] = fft(this, varargin)

persistent ip
if isempty(ip)
    ip = inputParser();
    addParameter(ip, 'Range', Inf);
    addParameter(ip, 'Full', false);
end
parse(ip, varargin{:});
opt = ip.Results;
%)
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

