% PbFromPa  Convert MSE matrix of the alpha vector to MSE matrix of the vector of predetermined variables
%
% -[IrisToolbox] for Macroeconomic Modeling
% -Copyright (c) 2007-2022 IRIS Solutions Team

function P = PbFromPa(U, P)

if isempty(U)
    return
end

Ut = transpose(U);
for i = 1 : size(P, 3)
    P(:, :, i) = U*P(:, :, i)*Ut;
    d = diag(P(:, :, i));
    inx = d<=0;
    P(inx, :, i) = 0;
    P(:, inx, i) = 0;
end

end%

