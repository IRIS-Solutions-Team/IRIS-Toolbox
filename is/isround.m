function Flag = isround(X)
% isround  True if variable is round number.
%
% Syntax 
% =======
%
%     Flag = isround(X)
%
% Input arguments
% ================
%
% * `X` [ numeric ] - Variable that will be tested.
%
% Output arguments
%
% * `Flag` [ `true` | `false` ] - True if the input variable `X` is a round
% number.
%
% Description
% ============
%
% Example
% ========
%
%     X = rand(2)
%     X =
%         0.0462    0.8235
%         0.0971    0.6948
%     Y = round(100*X)
%     Y =
%          5    82
%         10    69
%     isround(X)
%     ans =
%          0     0
%          0     0
%     isround(Y)
%     ans =
%          1     1
%          1     1
%

% -IRIS Macroeconomic Modeling Toolbox.
% -Copyright (c) 2007-2018 IRIS Solutions Team.

%--------------------------------------------------------------------------

Flag = X == round(X);

end
