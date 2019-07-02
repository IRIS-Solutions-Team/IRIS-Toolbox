function [Rad,Per] = xsf2phase(S,varargin)
% xs2phase  Convert power spectrum or spectral density matrices to phase shift.
%
% Syntax
% =======
%
%     Rad = xsf2phase(S,...)
%     [Rad,Per] = xsf2phase(S,Freq,...)
%
% Input arguments
% ================
%
% * `S` [ numeric ] - Power spectrum or spectral density matrices computed
% by the `xsf` function.
%
% Output arguments
% =================
%
% * `Rad` [ numeric ] - Phase shift in radians.
%
% * `Per` [ numeric ] - Phase shift in periods.
%
% Options
% ========
%
% * `'unwrap='` [ `true` | *`false`* ] - Correct phase angles to produce
% smoother phase vector.
%
% Description
% ============
%
% Positive numbers of `RAD` and `PER` mean leads, negative numbers lags.
% Note that this is unlike e.g. the definition by Harvey (1993) where
% positive numbers of phase shifts mean lags.
%
% Example
% ========
%

% -IRIS Macroeconomic Modeling Toolbox.
% -Copyright (c) 2007-2019 IRIS Solutions Team.

if ~isempty(varargin) && isnumeric(varargin{1})
    freq = varargin{1};
    varargin(1) = [ ];
else
    freq = [ ];
end

opt = passvalopt('freqdom.xsf2phase',varargin{:});

%--------------------------------------------------------------------------

Rad = atan2(imag(S),real(S));

if opt.unwrap
    Rad = unwrap(Rad,[ ],3);
end

if nargout == 1
    return
end

if length(freq) ~= size(Rad,3)
    utils.error('utils', ...
        ['Cannot compute phase shift in periods when the vector of ', ...
        'frequencies is not specified.']);
end

nfreq = length(freq);
Per = Rad;
realsmall = getrealsmall( );
for i = 1 : nfreq
    if abs(freq(i)) <= realsmall
        Per(:,:,i,:) = NaN;
    else
        Per(:,:,i,:) = Per(:,:,i,:) / freq(i);
    end
end

end