function Flag = isanystri(X,List)
% isanystri  True if string is found in list, case insensitive.
%
% Syntax
% =======
%
%     Flag = isanystri(X,List)
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
% least one of the strings in the `List`, case insensitive.
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

Flag = ischar(X) && any(strcmpi(X,List));

end
