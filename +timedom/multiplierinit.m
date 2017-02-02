function [DyDa0,DaDa0,DfDa0] = multiplierinit(T,R,K,Z,H,D,U,last,active)
% multiplierinit  [Not a public function] Multipliers of initial condition.

% Impact of active initial conditions:
% DaDa0 = da(t) / da(0)
% DfDa0 = da(t) / da(0)
% DbDa0 = db(t) / da(0)
% DyDa0 = dy(t) / da(0)
% for t = 1 .. last.

[nx,nb] = size(T);
nf = nx - nb;
ny = size(Z,1);
Ta = T(nf+1:end,:);
Tf = T(1:nf,:);

% Initial time.
DyDa0 = zeros([last*ny,nb]);
DaDa0 = zeros([last*nb,nb]);
DaDa0(1:nb,:) = Ta;
DyDa0(1:ny,:) = Z*DaDa0(1:nb,:);
if nargout > 2
   DfDa0 = zeros([last*nf,nb]);
   DfDa0(1:nf,:) = Tf;
end

for t = 2 : last
   DaDa0((t-1)*nb+(1:nb),:) = Ta*DaDa0((t-2)*nb+(1:nb),:);
   DyDa0((t-1)*ny+(1:ny),:) = Z*DaDa0((t-1)*nb+(1:nb),:);
   if nargout > 2
      DfDa0((t-1)*nf+(1:nf),:) = Tf*DaDa0((t-2)*nb+(1:nb),:);
   end
end

% Select active initial conditions.
DaDa0 = DaDa0(:,active);
DyDa0 = DyDa0(:,active);
if nargout > 2
   DfDa0 = DfDa0(:,active);
end

end
