function this = refresh(this, vecAlt)
% refresh  Refresh dynamic links.
%
% Syntax
% =======
%
%     M = refresh(M)
%
%
% Input arguments
% ================
%
% * `M` [ model ] - Model object whose dynamic links will be refreshed.
%
%
% Output arguments
% =================
%
% * `M` [ model ] - Model object with dynamic links refreshed.
%
%
% Description
% ============
%
%
% Example
% ========
%
%     m = refresh(m);
%

% -IRIS Macroeconomic Modeling Toolbox.
% -Copyright (c) 2007-2017 IRIS Solutions Team.

PTR = @int16;

lhs = this.Pairing.Link.Lhs;
ixla = lhs>PTR(0); % Index of active links.
if ~any(ixla)
    return
end

nAlt = length(this);
try
    if isequal(vecAlt, Inf) || isequal(vecAlt, @all)
        vecAlt = 1 : nAlt;
    end
catch %#ok<CTCH>
    vecAlt = 1 : nAlt;
end
nVecAlt = length(vecAlt);

%--------------------------------------------------------------------------

nQuan = length(this.Quantity);

% Get a 1-(nQty+nStdCorr)-nAlt matrix of quantities and stdcorrs.
x = [ ...
    model.Variant.getQuantity(this.Variant, ':', vecAlt), ...
    model.Variant.getStdCorr(this.Variant, ':', vecAlt) ...
    ];

% Permute from 1-(nQty+nStdCorr)-nAlt to (nQty+nStdCorr)-nAlt-1.
x = permute(x, [2, 3, 1]);

% Evaluate links in user's order or reorder sequentially if available.
order = this.Pairing.Link.Order(ixla);
posl = find(ixla);
if all(order>PTR(0))
    [~, temp] = sort(order);
    posl = posl(temp);
end

t = 1 : nVecAlt;
for j = posl
    x(lhs(j), :) = this.Equation.Dynamic{j}(x, t);
end


% Permute from (nQty+nStdCorr)-nAlt-1 to 1-(nQty+nStdCorr)-nAlt.
x = ipermute(x, [2, 3, 1]);

this.Variant = model.Variant.assignQuantity( ...
    this.Variant, ':', ':', x(1, 1:nQuan, :) ...
    );
this.Variant = model.Variant.assignStdCorr( ...
    this.Variant, ':', ':', x(1, nQuan+1:end, :) ...
    );
end
