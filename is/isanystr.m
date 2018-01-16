function Flag = isanystr(X,List)
% isanystr  True if string is found in list, case sensitive.
%
% Syntax
% =======
%
%     Flag = isanystr(X,List)
%
% Input arguments
% ================
%
% * `X` [ char ] - Input string that will be matched against the `List`.
%
% * `List` [ cellstr ] - List of strings.
%
% Output arguments
% =================
%
% * `Flag` [ `true` | `false` ] - True if the input string `X` equals at
% least one of the strings in the `List`, case sensitive.
%
% Description
% ============
%
% Example
% ========
%

% -IRIS Macroeconomic Modeling Toolbox.
% -Copyright (c) 2007-2018 IRIS Solutions Team.

%--------------------------------------------------------------------------

Flag = ischar(X) && any(strcmp(X,List));

end
