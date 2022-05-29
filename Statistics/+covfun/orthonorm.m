function [B,U] = orthonorm(Omg,N,Std,E)
% orthonorm  [Not a public function] Convert reduced-form residuals to orthonormal residuals.
%
% Backend IRIS function.
% No help provided.

% -IRIS Macroeconomic Modeling Toolbox.
% -Copyright (c) 2007-2022 IRIS Solutions Team.

try
    N; %#ok<VUNUS>
catch
    N = Inf;
end

try
    Std; %#ok<VUNUS>
catch
    Std = 1;
end

try
    E; %#ok<VUNUS>
catch
    E = [ ];
end

%--------------------------------------------------------------------------

ny = size(Omg,1);
nAlt = size(Omg,3);
if N > ny
    N = ny;
end

B = zeros(ny,ny,nAlt);
V = zeros(ny,N,nAlt);
s = zeros(N,nAlt);
Q = zeros(ny,ny,nAlt);
for iLoop = 1 : nAlt
    [V1,S,V2] = svd(Omg(:,:,iLoop));
    V1 = V1(:,1:N);
    V2 = V2(:,1:N);
    V(:,:,iLoop) = (V1+V2)/2;
    s(:,iLoop) = sqrt(diag(S(1:N,1:N))) / Std;
    Z = diag(s(:,iLoop));
    B(:,1:N,iLoop) = V(:,:,iLoop)*Z;
    % Q is used to convert residuals.
    Q(1:N,:,iLoop) = diag(1./s(:,iLoop))*V(:,:,iLoop)';
end

U = [ ];
if nargout > 1 && ~isempty(E)
    nPer = size(E,2);
    nData = size(E,3);
    if nData < nAlt
        E(:,:,end+1:nAlt) = E(:,:,nData*ones(1,nAlt-nData));
    end
    nLoop = max(nAlt,nData);
    U = zeros(ny,nPer,nLoop);
    for iLoop = 1 : nLoop
        if iLoop <= nAlt
            Qi = Q(1:N,:,iLoop);
        end
        if iLoop <= nData
            ei = E(:,:,iLoop);
        end
        U(1:N,:,iLoop) = Qi*ei;
    end
end

end
