function C = removeltel(C)
% removeltel  Remove leading and trailing empty lines.
%
% Syntax
% =======
%
%     C = textfun.removeltel(C)
%
% Input arguments
% ================
%
% * `C` [ char ] - Text string from which all leading and trailing empty
% lines will be removed.
%
% Output arguments
% =================
%
% * `C` [ char ] - Text string wit no leading and trailing empty
% lines.
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

C = regexprep(C,'^\s*\n','');
C = regexprep(C,'\n\s*$','');

end
