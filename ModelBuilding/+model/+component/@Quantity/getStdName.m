function lsStd = getStdName(this, request)
% getStdName  Get names of standard deviations of shocks.
%
% Backend IRIS function.
% No help provided.

% -IRIS Macroeconomic Modeling Toolbox.
% -Copyright (c) 2007-2018 IRIS Solutions Team.

%--------------------------------------------------------------------------

ixe = this.Type==int8(31) | this.Type==int8(32);
lsStd = this.Name(ixe);
lsStd = strcat('std_', lsStd);

if nargin>1
    lsStd = lsStd(request);
end

end
