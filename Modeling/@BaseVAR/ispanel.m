function Flag = ispanel(This)
% ispanel  True for panel VAR objects.
%
% Syntax
% =======
%
%     Flag = ispanel(X)
%
% Input arguments
% ================
%
% * `X` [ VAR | SVAR ]  - VAR object.
%
% Output arguments
% =================
%
% * `Flag` [ `true` | `false` ] - True if the VAR object, `X`, is based on
% a panel of data.
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
 
Flag = ~isempty(This.GroupNames);

end