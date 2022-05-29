% xs2phase  Convert power spectrum or spectral density matrices to phase shift.
%
% Syntax
% =======
%
%     Rad = xsf2phase(S,...)
%     [Rad,Per] = xsf2phase(S, Freq,...)
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
% * `'Unwrap='` [ `true` | *`false`* ] - Correct phase angles to produce
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
% -Copyright (c) 2007-2022 IRIS Solutions Team.


% >=R2019b
%{
function [rad, per] = xsf2phase(S, freq, opt)

arguments
    S
    freq
    opt.Unwrap (1, 1) logical = false
end
%}
% >=R2019b


% <=R2019a
%(
function [rad, per] = xsf2phase(S, freq, varargin)

persistent ip
if isempty(ip)
    ip = inputParser();
    addParameter(ip, 'Unwrap', false);
end
parse(ip, varargin{:});
opt = ip.Results;
%)
% <=R2019a


rad = atan2(imag(S), real(S));

if opt.Unwrap
    rad = unwrap(rad, [ ], 3);
end

if nargout == 1
    if isa(S, 'namedmat')
        rad = namedmat(rad, S.RowNames, S.ColNames);
    end
    return
end

per = rad;
realsmall = getrealsmall( );
for i = 1 : size(per, 3)
    if abs(freq(i))<=realsmall
        per(:, :, i, :) = NaN;
    else
        per(:, :, i, :) = per(:, :, i, :) / freq(i);
    end
end

if isa(S, 'namedmat')
    per = namedmat(per, S.RowNames, S.ColNames);
end

end%

