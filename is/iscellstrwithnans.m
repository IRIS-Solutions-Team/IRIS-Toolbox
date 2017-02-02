function flag = iscellstrwithnans(x)
% iscellstrwithnans  True if variable is cell array of strings or NaNs.
%
% Syntax 
% =======
%
%     Flag = iscellstrwithnans(X)
%
%
% Input arguments
% ================
%
% * `X` [ numeric ] - Variable that will be tested.
%
%
% Output arguments
% =================
%
% * `Flag` [ `true` | `false` ] - True if the input variable `X` is a cell
% array of strings or `NaN`s.
%
%
% Description
% ============
%
%
% Example
% ========
%

% -IRIS Macroeconomic Modeling Toolbox.
% -Copyright (c) 2007-2017 IRIS Solutions Team.

%--------------------------------------------------------------------------

flag = all( cellfun(@(x) ischar(x) || isequaln(x, NaN), x(:)) );

end
