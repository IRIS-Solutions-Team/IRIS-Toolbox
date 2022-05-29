function This = demean(This)
% demean  Remove constant and the effect of exogenous inputs from VAR object.
%
% Syntax
% =======
%
%     V = demean(V)
%
% Input arguments
% ================
%
% * `V` [ VAR ] - VAR object.
%
% Output arguments
% =================
%
% * `V` [ VAR ] - VAR object with the constant vector, `K`, and the
% asymptotic assumptions for exogenous inputs, `X0`, reset to zero.
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

This.K(:,:,:) = 0;
This.X0(:,:,:) = 0;

end
