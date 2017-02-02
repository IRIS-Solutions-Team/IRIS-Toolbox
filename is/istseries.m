function Flag = istseries(X)
% istseries  True if variable is tseries object.
%
% Syntax 
% =======
%
%     Flag = istseries(X)
%
% Input arguments
% ================
%
% * `X` [ numeric ] - Variable that will be tested.
%
% Output arguments
%
% * `Flag` [ `true` | `false` ] - True if the input variable `X` is a tseries
% object.
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

Flag = isa(X,'tseries');

end
