function Flag = islogicalscalar(X)
% islogicalscalar  True if variable is logical scalar.
%
% Syntax 
% =======
%
%     Flag = islogicalscalar(X)
%
% Input arguments
% ================
%
% * `X` [ numeric ] - Variable that will be tested.
%
% Output arguments
%
% * `Flag` [ `true` | `false` ] - True if the input variable `X` is a
% logical scalar.
%
% Description
% ============
%
% Example
% ========
%

% -IRIS Macroeconomic Modeling Toolbox.
% -Copyright (c) 2007-2020 IRIS Solutions Team.

%--------------------------------------------------------------------------

Flag = islogical(X) && numel(X) == 1;

end
