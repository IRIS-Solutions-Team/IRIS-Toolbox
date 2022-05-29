function Phi = var2vma(A,B,NPer,Select)
% var2vma  [Not a public function] VMA representation of a VAR process.
%
% Backend IRIS function.
% No help provided.

% -IRIS Macroeconomic Modeling Toolbox.
% -Copyright (c) 2007-2022 IRIS Solutions Team.

[ny,p,nAlt] = size(A);
p = p/max(ny,1);

try
    Select; %#ok<VUNUS>
catch %#ok<CTCH>
    Select = true(1,ny);
end
ne = sum(Select); 

%--------------------------------------------------------------------------

A = reshape(A,ny,ny,p,nAlt);

Phi = zeros(ny,ne,NPer,nAlt);
for iAlt = 1 : nAlt
    if isempty(B)
        Phi0 = eye(ny);
    else
        Phi0 = B(:,:,min(iAlt,end));
    end
    Phi(:,:,1,iAlt) = Phi0(:,Select);
    for t = 2 : NPer
        for k = 1 : min(p,t-1)
            Phi(:,:,t,iAlt) = ...
                Phi(:,:,t,iAlt) + A(:,:,k,iAlt)*Phi(:,:,t-k,iAlt);
        end
    end
end

end
