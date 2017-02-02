function [X,Y] = fevd(T,R,K,Z,H,D,U,OMG,NPER)
% fevd  [Not a public function] Forecast error variance decomposition for general state space.
%
% Backend IRIS function.
% No help provided.

% -IRIS Macroeconomic Modeling Toolbox.
% -Copyright (c) 2007-2017 IRIS Solutions Team.

%**************************************************************************

ny = size(Z,1);
[nx,nb] = size(T);
nf = nx - nb;
ne = size(R,2);
n = ny + nf + nb;

Phi = timedom.srf(T,R,K,Z,H,D,U,OMG,NPER);
Phi(:,:,1) = [ ];

X = cumsum(Phi.^2,3); % FEVD in absolute contributions
Y = zeros(size(X)); % FEVD in relative contributions
status = warning( );
warning('off'); %#ok<WNOFF>
varmat = diag(OMG);
varmat = varmat(:)';
varmat = varmat(ones(1,n),:);
for t = 1 : NPER
   X(:,:,t) = X(:,:,t) .* varmat;
   Xsum = sum(X(:,:,t),2);
   Xsum = Xsum(:,ones(1,ne));
   Y(:,:,t) = X(:,:,t) ./ Xsum;
end
warning(status);

end
