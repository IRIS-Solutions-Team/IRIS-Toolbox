function Flag = isrpteq(X)
% isrpteq  True if variable is rpteq object.
%
% Syntax 
% =======
%
%     Flag = isrpteq(X)
%
% Input arguments
% ================
%
% * `X` [ numeric ] - Variable that will be tested.
%
% Output arguments
%
% * `Flag` [ `true` | `false` ] - True if the input variable `X` is a rpteq
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

Flag = isa(X,'rpteq');

end
