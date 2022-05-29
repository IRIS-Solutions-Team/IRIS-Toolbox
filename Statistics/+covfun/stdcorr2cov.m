function [Omg, inxEqual, inxInfDiag] = stdcorr2cov(stdCorr, ne)
% stdcorr2cov  Convert stdcorr vector to covariance matrix.
%
% Backend IRIS function.
% No help provided.

% -IRIS Macroeconomic Modeling Toolbox.
% -Copyright (c) 2007-2022 IRIS Solutions Team.

% Transpose `stdcorr` if it is a row vector, and its length matches the
% prescribed size.
if isvector(stdCorr) && size(stdCorr, 1)==1 ...
        && length(stdCorr)==ne + ne*(ne-1)/2
    stdCorr = stdCorr.';
end

%--------------------------------------------------------------------------

% Find positions where the stdcorr vector is equal to the previous
% position. We will simply copy the cov matrix in these position.
inxEqual = [false, all(stdCorr(:, 2:end)==stdCorr(:, 1:end-1), 1)];

isStdOnly = size(stdCorr, 1)==ne;
numPages = size(stdCorr, 2);
inxTril = tril(ones(ne), -1)==1;
stdCorr(1:ne, :) = abs(stdCorr(1:ne, :));
stdVec = abs( stdCorr(1:ne, :) );
varVec = stdVec.^2;

if ~isStdOnly
    corrVec = stdCorr(ne+1:end, :);
    corrVec(corrVec>1 | corrVec<(-1)) = NaN;
end

Omg = zeros(ne, ne, numPages);
inxInfDiag = false(ne, numPages);
for i = 1 : numPages
    if inxEqual(i)
        Omg(:, :, i) = Omg(:, :, i-1);
        inxInfDiag(:, i) = inxInfDiag(:, i-1);
        continue
    elseif isStdOnly || all(corrVec(:, i)==0)
        Omg(:, :, i) = diag(varVec(:, i));
    else
        % Create the correlation matrix
        R = zeros(ne);
        % Fill in the lower triangle
        R(inxTril) = corrVec(:, i);
        % Copy the lower triangle into the upper triangle and add ones
        % on the main diagonal
        R = R + R' + eye(ne);
        % Creat a matrix where the i, j-th element is std(i)*std(j)
        D = repmat(stdVec(:, i), 1, ne);
        % D = stdVec(:, i*ones(1, ne));
        D = D .* D';
        % Multiply the (i, j)-th entry in the correlation matrix by
        % std(i)*std(j)
        Omg(:, :, i) = R .* D;
    end
    temp = isinf(diag(Omg(:, :, i)));
    if any(temp)
        Omg(temp, :, i) = Inf;
        Omg(:, temp, i) = Inf;
    end
    inxInfDiag(:, i) = temp;
end

end%

