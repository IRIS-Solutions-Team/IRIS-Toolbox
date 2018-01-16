function Flag = iseven(X)
% iseven  True for even numbers.
%
%
% Syntax
% =======
%
%     Flag = iseven(X)
%
%
% Input arguments
% ================
%
% * `X` [ numeric ] - Number(s) that will be tested.
%
%
% Output arguments
% =================
%
% * `Flag` [ `true` | `false` ] - True for even numbers.
%
%
% Description
% ============
%
%
% Example
% ========
%
%     >> x = [1,2,3,4];
%     >> iseven(x)
%     ans =
%          0     1     0     1     
%

% -IRIS Macroeconomic Modeling Toolbox.
% -Copyright (c) 2007-2018 IRIS Solutions Team.

%--------------------------------------------------------------------------

Flag = X/2==round(X/2);

end
