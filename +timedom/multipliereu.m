function [DyDe,DaDe,DfDe] = multipliereu(T,R,K,Z,H,D,U,last,active)
% multipliereu  Multipliers of unanticipated shocks.

% Impact of active unanticipated active shocks:
% DaDe = da(t) / de(t)
% DfDe = da(t) / de(t)
% DbDe = db(t) / de(t)
% DyDe = dy(t) / de(t)
% for t = 1 .. lastcond.

[nx,nb] = size(T);
nf = nx - nb;
ny = size(Z,1);
ne = size(H,2);
Ta = T(nf+1:end,:);
Tf = T(1:nf,:);
% Cut off forward expansion.
Ra = R(nf+1:end,1:ne);
Rf = R(1:nf,1:ne);

DaDe = zeros([last*nb,last*ne]);
DyDe = zeros([last*ny,last*ne]);
if nargout > 2
   DfDe = zeros([last*nf,last*ne]);
end

% Initial time.
DaDe(1:nb,1:ne) = Ra;
DyDe(1:ny,:) = Z*DaDe(1:nb,:);
DyDe(1:ny,1:ne) = DyDe(1:ny,1:ne) + H;
if nargout > 2
   DfDe(1:nf,1:ne) = Rf;
end

for i = 2 : last
   % Impact on alpha.
   DaDe((i-1)*nb+(1:nb),1:(i-1)*ne) = Ta*DaDe((i-2)*nb+(1:nb),1:(i-1)*ne);
   DaDe((i-1)*nb+(1:nb),(i-1)*ne+(1:ne)) = DaDe((i-1)*nb+(1:nb),(i-1)*ne+(1:ne)) + Ra;
   % Impact on measurement variables.
   DyDe((i-1)*ny+(1:ny),1:i*ne) = Z*DaDe((i-1)*nb+(1:nb),1:i*ne);
   DyDe((i-1)*ny+(1:ny),(i-1)*ne+(1:ne)) = DyDe((i-1)*ny+(1:ny),(i-1)*ne+(1:ne)) + H;
   if nargout > 2
      % Impact on fwl variables.
      DfDe((i-1)*nf+(1:nf),1:(i-1)*ne) = Tf*DaDe((i-2)*nb+(1:nb),1:(i-1)*ne);
      DfDe((i-1)*nf+(1:nf),(i-1)*ne+(1:ne)) = DfDe((i-1)*nf+(1:nf),(i-1)*ne+(1:ne)) + Rf;
   end
end

% Select active shocks.
DaDe = DaDe(:,active);
DyDe = DyDe(:,active);
if nargout > 2
   DfDe = DfDe(:,active);
end

end
