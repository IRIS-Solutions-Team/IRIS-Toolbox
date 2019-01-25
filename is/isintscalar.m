function Flag = isintscalar(X)
% isintscalar  True if variable is integer scalar (of any numeric type).
%
% Syntax 
% =======
%
%     Flag = isintscalar(X)
%
% Input arguments
% ================
%
% * `X` [ numeric ] - Variable that will be tested.
%
% Output arguments
%
% * `Flag` [ `true` | `false` ] - True if the input variable `X` is an
% integer scalar of any numeric type.
%
% Description
% ============
%
% Example
% ========
%
%     X = 12;
%     Y = pi;
%     Z = int8(1);
%     isintscalar(X)
%     ans =
%          1
%     isintscalar(Y)
%     ans =
%          0
%     isintscalar(Z)
%     ans =
%          1
%

% -IRIS Macroeconomic Modeling Toolbox.
% -Copyright (c) 2007-2019 IRIS Solutions Team.

%--------------------------------------------------------------------------

Flag = isnumeric(X) && numel(X) == 1 && round(X) == X;

end
