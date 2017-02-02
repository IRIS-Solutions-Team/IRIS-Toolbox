function Flag = isVAR(X)
% isVAR  True if variable is VAR object.
%
% Syntax 
% =======
%
%     Flag = isVAR(X)
%
% Input arguments
% ================
%
% * `X` [ numeric ] - Variable that will be tested.
%
% Output arguments
%
% * `Flag` [ `true` | `false` ] - True if the input variable `X` is a VAR
% object.
%
% Description
% ============
%
% Example
% ========
%

% -IRIS Macroeconomic Modeling Toolbox.
% -Copyright (c) 2007-2017 IRIS Solutions Team.

%--------------------------------------------------------------------------

if true % ##### MOSW
    Flag = isa(X,'VAR');
else
    Flag = isa(X,'VAR') || isa(X,'SVAR'); %#ok<UNRCH>
end

end
