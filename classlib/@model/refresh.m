function this = refresh(this, vecAlt)
% refresh  Refresh dynamic links.
%
% Syntax
% =======
%
%     m = refresh(m)
%
%
% Input arguments
% ================
%
% * `m` [ model ] - Model object whose dynamic links will be refreshed.
%
%
% Output arguments
% =================
%
% * `m` [ model ] - Model object with dynamic links refreshed.
%
%
% Description
% ============
%
%
% Example
% ========
%
%     m = refresh(m)
%
% -IRIS Macroeconomic Modeling Toolbox.
% -Copyright (c) 2007-2017 IRIS Solutions Team.

PTR = @int16;

if ~any(this.Link)
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

nQty = length(this.Quantity);

% Get a 1-(nQty+nStdCorr)-nAlt matrix of quantities and stdcorrs.
x = [ ...
    model.Variant.getQuantity(this.Variant, ':', vecAlt), ...
    model.Variant.getStdCorr(this.Variant, ':', vecAlt), ...
    ];

% Permute from 1-nQty-nAlt to nQty-nAlt-1.
x = permute(x, [2, 3, 1]);

x = refresh(this.Link, x);

% Permute from (nQty+nStdCorr)-nAlt-1 to 1-(nQty+nStdCorr)-nAlt.
x = ipermute(x, [2, 3, 1]);

this.Variant = model.Variant.assignQuantity( ...
    this.Variant, ':', ':', x(1, 1:nQty, :) ...
    );
this.Variant = model.Variant.assignStdCorr( ...
    this.Variant, ':', ':', x(1, nQty+1:end, :) ...
    );
end
