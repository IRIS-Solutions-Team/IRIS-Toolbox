function S = xsfvar(A, Omega, freq, filter, applyTo)
% xsfvar  Power spectrum function for VAR
%
% Backend IRIS function
% No help provided

% -IRIS Macroeconomic Modeling Toolbox
% -Copyright (c) 2007-2022 IRIS Solutions Team

%--------------------------------------------------------------------------

isFilter = ~isempty(filter) && any(applyTo);
if isempty(filter)
    filter = nan(size(freq));
end

[ny, p] = size(A);
p = p/ny;
A = reshape(A, [ny, ny, p]);
numFreq = numel(freq);

S = zeros(ny, ny, numFreq);
for i = 1 : numFreq
    ithFreq = freq(i);
    ithFilter = filter(i);
    if isFilter && ithFilter==0 && all(applyTo) && ithFreq~=0
        continue
    end
    F = eye(ny);
    for j = 1 : p
        F = F - exp(-1i*j*ithFreq)*A(:, :, j);
    end
    s = F \ Omega / ctranspose(F);
    if isFilter
        s(applyTo, :) = ithFilter*s(applyTo, :);
        s(:, applyTo) = s(:, applyTo)*conj(ithFilter);
    end
    S(:, :, i) = s;
end

% Skip dividing S by 2*pi.

if ~isFilter
    for i = 1 : size(S, 1)
        S(i, i, :) = real(S(i, i, :));
    end
end

end
