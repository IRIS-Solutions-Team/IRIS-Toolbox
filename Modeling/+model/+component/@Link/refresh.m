function x = refresh(this, x, select)
% refresh  Refresh dynamic links
%
% Backend IRIS function
% No help provided

% -IRIS Macroeconomic Modeling Toolbox
% -Copyright (c) 2007-2018 IRIS Solutions Team

PTR = @int16;

%--------------------------------------------------------------------------

% x is expected to be (nQty+nsx)-by-nv
nx = size(x, 1);
nv = size(x, 2);

t = 1 : nv;
for iEqn = this.Order
    ptr = this.LhsPtr(iEqn);
    if ptr<PTR(0)
        % Inactive (disabled) link, do not refresh
        continue
    end
    if ptr>nx
        continue
    end
    x(ptr, :) = this.RhsExpn{iEqn}(x, t);
end

end%
