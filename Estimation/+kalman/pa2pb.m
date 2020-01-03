function P = pa2pb(U, P)
% Pa2Pb  Convert MSE matrix of the alpha vector to MSE matrix of the vector of predetermined variables
%
% Backend IRIS function
% No help provided

% -[IrisToolbox] for Macroeconomic Modeling
% -Copyright (c) 2007-2020 IRIS Solutions Team

%--------------------------------------------------------------------------

Ut = transpose(U);
for i = 1 : size(P, 3)
    P(:, :, i) = U*P(:, :, i)*Ut;
    d = diag(P(:, :, i));
    inx = d<=0;
    P(inx, :, i) = 0;
    P(:, inx, i) = 0;
end

end%

