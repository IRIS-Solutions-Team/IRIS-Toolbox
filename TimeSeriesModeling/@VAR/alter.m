function this = alter(this, n)
% alter  Expand or reduce the number of alternative parameterisations within a VAR object
%
% Syntax
% =======
%
%     V = alter(V, n)
%
% Input arguments
% ================
%
% * `V` [ VAR ] - VAR object in which the number of paremeterisations will
% be changed.
%
% * `n` [ numeric ] - New number of parameterisations.
%
% Output arguments
% =================
%
% * `V` [ VAR ] - VAR object with the new number of parameterisations.
%
% Description
% ============
%
% Example
% ========
%

% -IRIS Macroeconomic Modeling Toolbox
% -Copyright (c) 2007-2022 IRIS Solutions Team

%--------------------------------------------------------------------------

nv = length(this);
if n==nv
    % Do nothing
    return
elseif n>nv
    % Expand nv by copying the last parameterisation
    this = subsalt(this, nv+1:n, this, nv*ones(1, n-nv));
else
    % Reduce nv by deleting the last parameterisations
    this = subsalt(this, n+1:nv, [ ]);
end

end%

