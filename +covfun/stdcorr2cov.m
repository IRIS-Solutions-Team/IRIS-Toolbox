function Omg = stdcorr2cov(StdCorr,ne)
% stdcorr2cov  [Not a public function] Convert stdcorr vector to covariance matrix.
%
% Backend IRIS function.
% No help provided.

% -IRIS Macroeconomic Modeling Toolbox.
% -Copyright (c) 2007-2017 IRIS Solutions Team.

% Transpose `stdcorr` if it is a row vector, and its length matches the
% prescribed size.
if isvector(StdCorr) && size(StdCorr,1) == 1 ...
        && length(StdCorr) == ne + ne*(ne-1)/2
    StdCorr = StdCorr.';
end

%--------------------------------------------------------------------------

% Find positions where the stdcorr vector is equal to the previous
% position. We will simply copy the cov matrix in these position.
stdcorreq = [false,all(StdCorr(:,2:end) == StdCorr(:,1:end-1),1)];

isStdOnly = size(StdCorr,1) == ne;
nStdCorr = size(StdCorr,2);
pos = tril(ones(ne),-1) == 1;
StdCorr(1:ne,:) = abs(StdCorr(1:ne,:));
stdVec = StdCorr(1:ne,:);

varVec = stdVec.^2;
if ~isStdOnly
    corrVec = StdCorr(ne+1:end,:);
    corrVec(corrVec > 1 | corrVec < -1) = NaN;
end

Omg = zeros(ne,ne,nStdCorr);
for i = 1 : nStdCorr
    if stdcorreq(i) && i > 1
        Omg(:,:,i) = Omg(:,:,i-1);
    elseif isStdOnly || all(corrVec(:,i) == 0)
        Omg(:,:,i) = diag(varVec(:,i));
    else
        % Create the correlation matrix.
        R = zeros(ne);
        % Fill in the lower triangle.
        R(pos) = corrVec(:,i);
        % Copy the lower triangle into the upper triangle and add ones
        % on the main diagonal.
        R = R + R.' + eye(ne);
        % Creat a matrix where the i,j-th element is std(i)*std(j).
        D = stdVec(:,i*ones(1,ne));
        D = D .* D.';
        % Multiply the i,j-th entry in the correlation matrix by
        % std(i)*std(j).
        Omg(:,:,i) = R .* D;
    end
    ixInf = isinf(diag(Omg(:,:,i)));
    if any(ixInf)
        Omg(ixInf,:,i) = Inf;
        Omg(:,ixInf,i) = Inf;
    end
end

end
