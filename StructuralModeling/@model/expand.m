function this = expand(this, k)
% expand  Compute forward expansion of model solution for anticipated shocks
%
% __Syntax__
%
%     M = expand(M, K)
%
%
% __Input Arguments__
%
% * `M` [ model ] - Model object whose solution will be expanded.
%
% * `K` [ numeric ] - Number of periods ahead, t+k, up to which the
% solution for anticipated shocks will be expanded.
%
%
% __Output Arguments__
%
% * `M` [ model ] - Model object with the solution expanded.
%
%
% __Description__
%
%
% __Example__
%

% -IRIS Macroeconomic Modeling Toolbox.
% -Copyright (c) 2007-2017 IRIS Solutions Team.

TYPE = @int8;

persistent INPUT_PARSER
if isempty(INPUT_PARSER)
    INPUT_PARSER = extend.InputParser('model/expand');
    INPUT_PARSER.addRequired('Model', @(x) isa(x, 'model'));
    INPUT_PARSER.addRequired('Forward', @(x) isnumeric(x) && numel(x)==1 && x>=0 && x==round(x));
end
INPUT_PARSER.parse(this, k);

%--------------------------------------------------------------------------

ixe = this.Quantity.Type==TYPE(31) | this.Quantity.Type==TYPE(32);
ne = nnz(ixe);
nn = nnz(this.Equation.IxHash);
nv = length(this);

if ne==0 && nn==0
    return
end

R = this.Variant.Solution{2}; % Impact matrix of structural shocks.
Y = this.Variant.Solution{8}; % Impact matrix of non-linear add-factors.
k0 = size(R, 2)/ne - 1; % Expansion up to t+k0 available.
if k0>=k
    % Requested expansion already available; return.
    return
end

% Expand the R and Y solution matrices, update Jk, and store the new
% matrices in the model object.

R(:, end+1:ne*(1+k), :) = NaN;
Y(:, end+1:nn*(1+k), :) = NaN;
Jk = this.Variant.Expansion{5};
for v = 1 : nv
    [R(:, :, v), Y(:, :, v), Jk(:, :, v)] = expandFirstOrder(this, v, k);
end
this.Variant.Solution{2} = R;
this.Variant.Solution{8} = Y;
this.Variant.Expansion{5} = Jk;

end
