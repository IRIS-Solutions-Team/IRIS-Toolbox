function this = expand(this, k)
% expand  Compute forward expansion of model solution for anticipated shocks.
%
% Syntax
% =======
%
%     M = expand(M, K)
%
% Input arguments
% ================
%
% * `M` [ model ] - Model object whose solution will be expanded.
%
% * `K` [ numeric ] - Number of periods ahead, t+k, up to which the
% solution for anticipated shocks will be expanded.
%
% Output arguments
% =================
%
% * `M` [ model ] - Model object with the solution expanded.
%
% Description
% ============
%
% Example
% ========
%

% -IRIS Macroeconomic Modeling Toolbox.
% -Copyright (c) 2007-2017 IRIS Solutions Team.

TYPE = @int8;

%--------------------------------------------------------------------------

ixe = this.Quantity.Type==TYPE(31) | this.Quantity.Type==TYPE(32);
ne = sum(ixe);
nn = sum(this.Equation.IxHash);
nAlt = length(this);

if ne==0 && nn==0
    return
end

% Impact matrix of structural shocks.
R = this.solution{2};

% Impact matrix of non-linear add-factors.
Y = this.solution{8};

% Expansion up to t+k0 available.
k0 = size(R,2)/ne - 1;

% Expansion up to t+k0 already available.
if k0>=k
    return
end

% Expand the R and Y solution matrices.
this.solution{2}(:, end+(1:ne*(k-k0)), 1:nAlt) = NaN;
this.solution{8}(:, end+(1:nn*(k-k0)), 1:nAlt) = NaN;
for iAlt = 1 : nAlt
    % m.Expand{5} Jk stores J^(k-1) and needs to be updated after each
    % expansion.
    [ this.solution{2}(:,:,iAlt), ...
        this.solution{8}(:,:,iAlt), ...
        this.Expand{5}(:,:,iAlt) ] = ...
        model.myexpand( ...
        R(:,:,iAlt), Y(:,:,iAlt), k, ...
        this.Expand{1}(:,:,iAlt), this.Expand{2}(:,:,iAlt), this.Expand{3}(:,:,iAlt), ...
        this.Expand{4}(:,:,iAlt), this.Expand{5}(:,:,iAlt), this.Expand{6}(:,:,iAlt) ...
        );
end

end
