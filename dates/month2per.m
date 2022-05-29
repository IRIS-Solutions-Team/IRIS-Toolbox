function per = month2per(month, freq)
% month2per  Convert month to lower-freq period.
%
% Backend IRIS function.
% No help provided.

% -IRIS Macroeconomic Modeling Toolbox.
% -Copyright (c) 2007-2022 IRIS Solutions Team.

%--------------------------------------------------------------------------

if length(freq)==1 && length(month)>1
    freq = freq*ones(size(month));
end

ixValid = freq<=12;
per = nan(size(month));
per(ixValid) = ceil( month(ixValid).*freq(ixValid)./12 );

end
