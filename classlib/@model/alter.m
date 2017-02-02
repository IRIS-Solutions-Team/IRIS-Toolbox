function this = alter(this, n)
% alter  Expand or reduce number of model variants.
%
% Syntax
% =======
%
%     M = alter(M,N)
%
%
% Input arguments
% ================
%
% * `M` [ model ] - Model object in which the number of model variants
% will be changed.
%
% * `N` [ numeric ] - New number of model variants.
%
%
% Output arguments
% =================
%
% * `M` [ model ] - Model object with the new number of variants.
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

nAlt = length(this);
if n==nAlt
    % Do nothing.
    return
elseif nAlt==0 && n>0
    if this.IsLinear
        std = this.DEFAULT_STD_LINEAR;
    else
        std = this.DEFAULT_STD_NONLINEAR;
    end
    template = model.Variant(this.Quantity, this.Vector, std);
    this.Variant = repmat({template}, 1, nAlt);
elseif n>nAlt
    % Expand nAlt by copying the last parameterisation.
    this = subsalt(this, nAlt+1:n, this, nAlt*ones(1, n-nAlt));
else
    % Reduce nAlt by deleting the last parameterisations.
    this = subsalt(this, n+1:nAlt, [ ]);
end

end
