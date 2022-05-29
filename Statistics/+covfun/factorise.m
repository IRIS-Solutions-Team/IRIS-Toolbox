function [F,Di] = factorise(C,SvdOnly)
% factorise  Use Cholesky or SVD to factorise covariance matrices.
%
% Backend IRIS function.
% No help provided.

% -IRIS Macroeconomic Modeling Toolbox.
% -Copyright (c) 2007-2022 IRIS Solutions Team.

try
    SvdOnly; %#ok<VUNUS>
catch %#ok<CTCH>
    SvdOnly = false;
end

%--------------------------------------------------------------------------

CSize = size(C);
C = C(:,:,:);
nLoop = size(C,3);
F = nan(size(C));
Di = nan(1,nLoop);

for i = 1 : nLoop
   if i > 1 && all(all(C(:,:,i) == C(:,:,i-1)))
      % Copy the previous factor matrix if the cov matrix is identical to
      % the previous cov matrix.
      F(:,:,i) = F(:,:,i-1);
      if nargout > 1
         Di(i) = Di(i-1);
      end
      continue
   end
   Ci = (C(:,:,i)+C(:,:,i)')/2;
   cholFailed = false;
   if ~SvdOnly
      % Unless declined by the user, attempt Cholesky first. Cholesky is
      % faster than SVD but may fail because of the matrix being
      % numerically non-positive-definite.
      try
         F(:,:,i) = chol(Ci).';
      catch %#ok<CTCH>
         cholFailed = true;
      end
   end
   if SvdOnly || cholFailed
      % If requested by the user or if Cholesky failes, use SVD which works
      % under any circumstances. Reset negative svd values to zero.
      [U,S] = svd(Ci);
      S = diag(S).';
      S(S < 0) = 0;
      % Impose sign convention that first element of each singular vector
      % is positive. This is to make results identical across different
      % processors.
      nx = size(C,1);
      inx = sign(U(1,:)) == -1;
      U(:,inx) = -U(:,inx);
      S = sqrt(S);
      F(:,:,i) = U .* S(ones(1,nx),:);
   end
   if nargout > 1
      Di(i) = maxabs(Ci - F(:,:,i)*F(:,:,i).');
   end
end

if length(CSize) > 3
   F = reshape(F,CSize);
end

end
