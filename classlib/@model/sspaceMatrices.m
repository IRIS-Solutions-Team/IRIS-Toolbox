function [T, R, K, Z, H, D, U, Omg, Zb] = sspaceMatrices(this, iAlt, isExpand)
% sspaceMatrices  Return state space matrices for given parameter variant.
%
% Backend IRIS function.
% No help provided.

% -IRIS Macroeconomic Modeling Toolbox.
% -Copyright (c) 2007-2017 IRIS Solutions Team.

%--------------------------------------------------------------------------

T = this.solution{1}(:, :, iAlt);
R = this.solution{2}(:, :, iAlt); % Forward expansion.
K = this.solution{3}(:, :, iAlt);
Z = this.solution{4}(:, :, iAlt);
H = this.solution{5}(:, :, iAlt);
D = this.solution{6}(:, :, iAlt);
U = this.solution{7}(:, :, iAlt);
Y = this.solution{8}(:, :, iAlt); %#ok<NASGU>
Zb = this.solution{9}(:, :, iAlt);

[~, ~, nb, ~, ne] = sizeOfSolution(this.Vector);
nAlt = length(this.Variant);

if ~isExpand
    R = R(:, 1:ne);
end

if isempty(Z)    
    Z = zeros(0, nb, nAlt);
end

if isempty(Zb)
    Zb = zeros(0, nb, nAlt);
end

if isempty(H)
    H = zeros(0, ne, nAlt);
end

if isempty(D)
    D = zeros(0, 1, nAlt);
end

if nargout>7
    Omg = omega(this, @get, iAlt);
end

end
