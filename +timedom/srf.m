function [Phi,ShkSize] = srf(T,R,~,Z,H,~,U,~,NPer,ShkSize)
% srf  [Not a public function] Shock response function (or VMA) for general state space.
%
% Backend IRIS function.
% No help provided.

% -IRIS Macroeconomic Modeling Toolbox.
% -Copyright (c) 2007-2018 IRIS Solutions Team.

%#ok<*CTCH>
%#ok<*VUNUS>
 
try
    ShkSize;
catch 
    ShkSize = 1;
end

%--------------------------------------------------------------------------

ny = size(Z,1);
[nx,nb] = size(T);
nf = nx - nb;
ne = size(R,2);

% Shock size.
ShkSize = ShkSize(:).';
if length(ShkSize) == 1 && ne ~= 1
   ShkSize = ShkSize(1,ones(1,ne));
end

% Add a zero pre-sample period for transition variables.
Phi = nan(ny+nx,ne,NPer+1);
Phi(:,:,1) = 0;

% Simulate measurement shocks first, then transition shocks. First
% simulated period comes at position 2.
if ny > 0
    Phi(:,:,2) = [...
        H.*ShkSize(ones(1,ny),:);...
        R.*ShkSize(ones(1,nx),:);...
        ];
else
    Phi(:,:,2) = R.*ShkSize(ones(1,nx),:);
end

if ny > 0
   Phi(1:ny,:,2) = Phi(1:ny,:,2) + Z*Phi(ny+nf+1:end,:,2);
end

for t = 2 : NPer
   Phi(ny+1:end,:,t+1) = T*Phi(ny+nf+1:end,:,t);
   if ny > 0
      Phi(1:ny,:,t+1) = Z*Phi(ny+nf+1:end,:,t+1);
   end
end

if ~isempty(U)
   for t = 1 : size(Phi,3)
      Phi(ny+nf+1:end,:,t) = U*Phi(ny+nf+1:end,:,t);
   end
end

end