function s = filterxf(s)
% FILTERXF Filter mean and MSE matrices of fwl transition variables.

nper = size(s.y1,2);
[nx,nb] = size(s.T);
nf = nx - nb;
Tf = s.T(1:nf,:);
Ta = s.T(nf+1:end,:);
Tft = Tf';
Tat = Ta';
Rat = s.R(nf+1:end,:)';
Rft = s.R(1:nf,:)';
if isempty(s.k)
   kf = [ ];
else
   kf = s.k(1:nf,1);
end

% Pre-allocate state vectors.
s.f0 = nan([nf,nper]);
s.Pfa0 = nan([nf,nb,nper]);
s.Pf0 = nan([nf,nf,nper]);

if nf == 0
   return
end

for t = 2 : nper
   s.f0(:,t,1) = Tf*s.a1(:,t-1);
   if ~isempty(kf)
      s.f0(:,t,1) = s.f0(:,t,1) + kf;
   end
   TfPa1 = Tf*s.Pa1(:,:,t-1);
   s.Pfa0(:,:,t) = TfPa1*Tat + s.RfOmg(:,:,t)*Rat;
   s.Pf0(:,:,t) = TfPa1*Tft + s.RfOmg(:,:,t)*Rft;
   s.Pf0(:,:,t) = (s.Pf0(:,:,t) + s.Pf0(:,:,t)')/2;
end
   
end