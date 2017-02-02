function freq = datfreq(dat)
% datfreq  Frequency of IRIS serial date numbers.
%
% Backend IRIS function.
% No help provided.

% -IRIS Macroeconomic Modeling Toolbox.
% -Copyright (c) 2007-2017 IRIS Solutions Team.

%--------------------------------------------------------------------------

freq = round(100*(dat - floor(dat)));

ixDaily = freq==0 & dat>=365244;
freq(ixDaily) = 365;

end
