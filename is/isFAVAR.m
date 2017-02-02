function Flag = isFAVAR(X)
% isFAVAR  True if variable is FAVAR object.
%
% Syntax 
% =======
%
%     Flag = isFAVAR(X)
%
% Input arguments
% ================
%
% * `X` [ numeric ] - Variable that will be tested.
%
% Output arguments
%
% * `Flag` [ `true` | `false` ] - True if the input variable `X` is a FAVAR
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

Flag = isa(X,'FAVAR');

end
