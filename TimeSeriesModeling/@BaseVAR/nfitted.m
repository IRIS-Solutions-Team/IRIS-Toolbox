function NFitted = nfitted(This)
% nfitted  Number of data points fitted in VAR estimation.
%
% Syntax
% =======
%
%     N = nfitted(V)
%
% Input arguments
% ================
%
% * `V` [ VAR ] - Estimated VAR object.
%
% Output arguments
% =================
% 
% * `N` [ numeric ] - Number of data points (periods) fitted when
% estimating the VAR object.
%
% Description
% ============
%
% Example
% ========
%

% -IRIS Macroeconomic Modeling Toolbox.
% -Copyright (c) 2007-2022 IRIS Solutions Team.

%--------------------------------------------------------------------------

nAlt = size(This.A,3);
NFitted = nan(1,nAlt);
for iAlt = 1 : nAlt
    iFitted = This.IxFitted(:,:,iAlt);
    NFitted(iAlt) = sum(double(iFitted(:)));
end

end
