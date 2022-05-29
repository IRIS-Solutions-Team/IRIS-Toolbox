function G = xsf2gain(S, varargin)
% xsf2gain  Compute gain of power spectrum matrices.
%
%
% Syntax
% =======
%
%     G = xsf2gain(S)
%
%
% Input arguments
% ================
%
% * `S` [ numeric ] Power spectrum matrices.
%
%
% Output arguments
% =================
%
% * `G` [ numeric ] - Gain of the power spectrum.
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
% -Copyright (c) 2007-2022 IRIS Solutions Team.

%--------------------------------------------------------------------------

s = size(S);
n = prod(s(3:end));
G = zeros(size(S));

for i = 1 : n
    Si = S(:,:,i);
    a = abs(Si);
    d = diag(Si);
    index = d ~= 0;
    d(index) = 1./d(index);
    d(~index) = 0;
    G(:,:,i) = a * diag(d);
end

for i = 1 : size(G,1)
    G(i,i,:) = 1;
end

if isa(S, 'namedmat')
    G = namedmat(G, S.RowNames, S.ColNames);
end

end%
