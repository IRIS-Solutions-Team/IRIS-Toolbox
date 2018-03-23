function x = refresh(this, x, select)
% refresh  Refresh dynamic links.
%
% Backend IRIS function.
% No help provided.

% -IRIS Macroeconomic Modeling Toolbox.
% -Copyright (c) 2007-2018 IRIS Solutions Team.

PTR = @int16;

%--------------------------------------------------------------------------

% x is expected to be (nQty+nsx)-nAlt.
nx = size(x, 1);
nAlt = size(x, 2);

t = 1 : nAlt;
for iEqn = this.Order
    ptr = this.LhsPtr(iEqn);
    if ptr<PTR(0)
        % Inactive (disabled) link, do not refresh.
        continue
    end
    if ptr>nx
        continue
    end
    x(ptr, :) = this.RhsExpn{iEqn}(x, t);
end

end
