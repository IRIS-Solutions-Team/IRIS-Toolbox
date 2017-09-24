function S = xsfvar(A,Omega,freq,filter,applyto)
% xsfvar  Power spectrum function for VAR.
%
% Backend IRIS function.
% No help provided.

% -IRIS Macroeconomic Modeling Toolbox.
% -Copyright (c) 2007-2017 IRIS Solutions Team.

%**************************************************************************

isfilter = ~isempty(filter) && any(applyto);

[ny,p] = size(A);
p = p/ny;
A = reshape(A,[ny,ny,p]);
nfreq = length(freq);

S = zeros(ny,ny,nfreq);
for i = 1 : nfreq
    lambda = freq(i);
    if isfilter && filter(i) == 0 && all(applyto) && lambda ~= 0
        continue
    end
    F = eye(ny);
    for j = 1 : p
        F = F - exp(-1i*j*lambda)*A(:,:,j);
    end
    s = F \ Omega / ctranspose(F);
    if isfilter
        s(applyto,:) = filter(i)*s(applyto,:);
        s(:,applyto) = s(:,applyto)*conj(filter(i));
    end
    S(:,:,i) = s;
end

% Skip dividing S by 2*pi.

if ~isfilter
    for i = 1 : size(S,1)
        S(i,i,:) = real(S(i,i,:));
    end
end

end