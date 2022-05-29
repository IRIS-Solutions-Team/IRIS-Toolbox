function X = w2xx(W,U)
% w2xx  Convert w=[xf;alp] to xx=[xf;xb].
%
% Backend IRIS function.
% No help provided.

% -IRIS Macroeconomic Modeling Toolbox.
% -Copyright (c) 2007-2022 IRIS Solutions Team.

%--------------------------------------------------------------------------

nxx = size(W, 1);
nb = size(U, 1);
nf = nxx - nb;

xb = W(nf+1:end,:,:);
for i = 1 : size(xb, 3)
    xb(:,:,i) = U * xb(:,:,i);
end

X = [W(1:nf,:,:); xb];

end
