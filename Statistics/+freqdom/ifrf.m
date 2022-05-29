function W = ifrf(T,R,K,Z,H,D,Zp,Omega,freq)
% ifrf  Frequency response function to input signals for general state space.
%
% Backend IRIS function.
% No help provided.

% -IRIS Macroeconomic Modeling Toolbox.
% -Copyright (c) 2007-2022 IRIS Solutions Team.

%**************************************************************************

ny = size(Z,1);
[nx,nb] = size(T);
nf = nx - nb;
ne = size(R,2);
T = [zeros([nf+nb,nf]),T];

W = zeros([ny+nf+nb,ne,0]);
for lambda = freq(:)'
   W(ny+1:end,:,end+1) = (eye(nf+nb)-T*exp(-1i*lambda))\R;
   W(1:ny,:,end) = Z*W(ny+nf+1:end,:,end);
   W(1:ny,:,end) = W(1:ny,:,end) + H;
   W(ny+nf+1:end,:,end) = Zp*W(ny+nf+1:end,:,end);
end

end
