function A = polyn2var(A)
% polyn2var  [Not a public function] Convert 3D polynomial to VAR style matrix.
%
% Backend IRIS function.
% No help provided.

% -IRIS Macroeconomic Modeling Toolbox.
% -Copyright (c) 2007-2022 IRIS Solutions Team.

%--------------------------------------------------------------------------

[~,ny,p,nAlt] = size(A);
p = p - 1;
for iAlt = 1 : nAlt
    if any(A(:,:,1,iAlt) ~= eye(ny))
        utils.error('poly:polyvar', ...
            'Polynomial must be monic.');
    end
end
A = reshape(-A(:,:,2:end,:),[ny,ny*p,nAlt]);

end
