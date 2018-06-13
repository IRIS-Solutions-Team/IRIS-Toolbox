function This = alter(This,N)
% alter  Expand or reduce the number of alternative parameterisations within a VAR object.
%
% Syntax
% =======
%
%     V = alter(V,N)
%
% Input arguments
% ================
%
% * `V` [ VAR ] - VAR object in which the number of paremeterisations will
% be changed.
%
% * `N` [ numeric ] - New number of parameterisations.
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

% -IRIS Macroeconomic Modeling Toolbox.
% -Copyright (c) 2007-2018 IRIS Solutions Team.

%--------------------------------------------------------------------------

nAlt = length(This);
if N == nAlt
    % Do nothing.
    return
elseif N > nAlt
    % Expand nAlt by copying the last parameterisation.
    This = subsalt(This,nAlt+1:N,This,nAlt*ones(1,N-nAlt));
else
    % Reduce nAlt by deleting the last parameterisations.
    This = subsalt(This,N+1:nAlt,[ ]);
end

end