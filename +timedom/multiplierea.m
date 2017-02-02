function [DyDe,DaDe,DfDe] = multiplierea(T,R,K,Z,H,D,U,last,active)
% multipliere0  Multipliers of anticipated shocks.

% Impact of anticipated active shocks:
% Impact of active unanticipated active shocks:
% DaDe = da(t) / de(t)
% DfDe = da(t) / de(t)
% DbDe = db(t) / de(t)
% DyDe = dy(t) / de(t)
% for t = 1 .. last
% t =1 .. last

[nx,nb] = size(T);
nf = nx - nb;
ny = size(Z,1);
ne = size(H,2);

Ta = T(nf+1:end,:);
Tf = T(1:nf,:);
% Cut off forward expansion beyond ne*last. This is because R gets expanded
% beyond ne*last when last structural condition is further ahead than last
% reduced-form condition.
Ra = R(nf+1:end,1:ne*last);
Rf = R(1:nf,1:ne*last);

DaDe = zeros([last*nb,last*ne]);
DyDe = zeros([last*ny,last*ne]);
if nargout > 2
   DfDe = zeros([last*nf,last*ne]);
end

% Initial time.
DaDe(1:nb,:) = Ra(:,1:last*ne);
DyDe(1:ny,:) = Z*DaDe(1:nb,:);
DyDe(1:ny,1:ne) = DyDe(1:ny,1:ne) + H;
if nargout > 2
   DfDe(1:nf,:) = Rf(:,1:last*ne);
end

for t = 2 : last
   % Impact on alpha vector.
   DaDe((t-1)*nb+(1:nb),:) = Ta*DaDe((t-2)*nb+(1:nb),:);
   DaDe((t-1)*nb+(1:nb),(t-1)*ne+1:end) = DaDe((t-1)*nb+(1:nb),(t-1)*ne+1:end) + Ra(:,1:end-(t-1)*ne);
   % Impact on measurement variables.
   DyDe((t-1)*ny+(1:ny),:) = Z*DaDe((t-1)*nb+(1:nb),:);
   DyDe((t-1)*ny+(1:ny),(t-1)*ne+(1:ne)) = DyDe((t-1)*ny+(1:ny),(t-1)*ne+(1:ne)) + H;
   % Impact on fwl variables.
   if nargout > 2
      DfDe((t-1)*nf+(1:nf),:) = Tf*DaDe((t-2)*nb+(1:nb),:);
      DfDe((t-1)*nf+(1:nf),(t-1)*ne+1:end) = DfDe((t-1)*nf+(1:nf),(t-1)*ne+1:end) + Rf(:,1:end-(t-1)*ne);
   end
end

DaDe = DaDe(:,active);
DyDe = DyDe(:,active);
if nargout > 2
   DfDe = DfDe(:,active);
end

end
