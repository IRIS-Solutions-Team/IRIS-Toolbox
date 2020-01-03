function [y,range,freq,per] = fft(x,range,varargin)
% fft  Discrete Fourier transform of tseries object.
% 
% Syntax
% =======
%
%     [y,range,freq,per] = fft(x)
%     [y,range,freq,per] = fft(x,range,...)
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
% interval [0,2*pi]; if false only the interval [0,pi] is returned.
%
% Description
% ============
%
% Example
% ========
%
%}


% -IRIS Macroeconomic Modeling Toolbox.
% -Copyright (c) 2007-2020 IRIS Solutions Team.

options = passvalopt('tseries.fft',varargin{:});

if nargin < 2
   range = Inf;
end

%**************************************************************************

tmpsize = size(x.data);

if isempty(range)
   y = zeros([0,tmpsize(2:end)]);
   return
end

if isequal(range,Inf)
   data = x.data;
   range = x.start + (0 : tmpsize(1)-1);
else
   range = range(1) : range(end);
   data = rangedata(x,range);
end
nper = length(range);

% Run Fourier.
y = fft(data(:,:));

% Back out frequencies.
freq = 2*pi*(0:nper-1) / nper;

% Convert frequencies to periodicities.
index = freq == 0;
per = nan(size(freq));
per(~index) = 2*pi./freq(~index);
per(index) = Inf;

if ~options.full
   % Return only data points within [0,pi].
   index = freq <= pi;
   freq = freq(index);
   y = y(index,:);
end
y = reshape(y,[size(y,1),tmpsize(2:end)]);

end