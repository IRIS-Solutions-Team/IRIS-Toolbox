% refresh  Refresh dynamic links
%
% -[IrisToolbox] for Macroeconomic Modeling
% -Copyright (c) 2007-2022 [IrisToolbox] Solutions Team

function x = refresh(this, x, select)

% x is expected to be (nQty+nsx)-by-nv
nx = size(x, 1);
nv = size(x, 2);
t = 1 : nv;

for i = this.Order
    ptr = this.LhsPtr(i);
    if ptr<0
        % Inactive (disabled) link, do not refresh
        continue
    end
    if ptr>nx
        continue
    end

    % RhsExpn now includes also the LHS variable and has this form:
    %     -[x(k,t)]+...
    % Zero the respective LHS variable first before running the refresh
    x(ptr, :) = 0;

    % Refresh by running the link expression with the LHS variables set to
    % zero; this simply results in evaluating the RHS expression
    x(ptr, :) = this.RhsExpn{i}(x, t);
end

end%

