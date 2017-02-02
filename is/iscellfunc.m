function Flag = iscellfunc(X)
% iscellfunc  True if variable is cell array of function handles.
%
% Syntax 
% =======
%
%     Flag = iscellfunc(X)
%
% Input arguments
% ================
%
% * `X` [ numeric ] - Variable that will be tested.
%
% Output arguments
%
% * `Flag` [ `true` | `false` ] - True if the input variable `X` is a cell
% array of function handles.
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

Flag = iscell(X) && all(cellfun(@(x) isa(x,'function_handle'),X(:)));

end
