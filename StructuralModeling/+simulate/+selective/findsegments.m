function Sgm = findsegments(S)
% findsegments  [Not a public function] Detect segmentation by unanticipated shocks.
%
% Backend IRIS function.
% No help provided.

% -IRIS Macroeconomic Modeling Toolbox.
% -Copyright (c) 2007-2022 IRIS Solutions Team.

%--------------------------------------------------------------------------

ny = size(S.Z,1);
nx = size(S.T,1);
ne = size(S.Eu,1);
nPer = size(S.Eu,2);

if isempty(S.Anch)
    euAnch = false(0,nPer);
else
    euAnch = S.Anch(ny+nx+ne+(1:ne),:);
end

% Positions of unanticipated shocks (segments) or unanticipated endogenised
% shocks.
temp = S.Eu ~= 0;
if ~isempty(euAnch)
    temp = [temp;euAnch];
end

Sgm = find(any(temp,1));
if isempty(Sgm) || Sgm(1) ~= 1
    Sgm = [1,Sgm];
end

end
