function P = pa2pb(U,P)
% Pa2Pb  [Not a public function] Convert MSE matrix of the alpha vector to MSE matrix of the
% vector of predetermined variables
%
% Backend IRIS function.
% No help provided.

% -IRIS Macroeconomic Modeling Toolbox.
% -Copyright (c) 2007-2017 IRIS Solutions Team.

%--------------------------------------------------------------------------

Ut = U.';
for i = 1 : size(P,3)
    P(:,:,i) = U*P(:,:,i)*Ut;
    d = diag(P(:,:,i));
    inx = d <= 0;
    P(inx,:,i) = 0;
    P(:,inx,i) = 0;
end

end