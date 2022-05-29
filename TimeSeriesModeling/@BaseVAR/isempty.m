function Flag = isempty(This)
% isempty  True if VAR based object is empty.
%
% Syntax
% =======
%
%     Flag = isempty(X)
%
% Input arguments
% ================
%
% * `X` [ VAR | SVAR | FAVAR ] - VAR based object.
%
% Output argument
% ================
%
% * `Flag` [ `true` | `false` ] - True if the VAR based object, `X`, is
% empty.
%
% Description
% ============
%
% Example
% ========

% -IRIS Macroeconomic Modeling Toolbox.
% -Copyright (c) 2007-2022 IRIS Solutions Team.

%--------------------------------------------------------------------------

Flag = isempty(This.A);

end
