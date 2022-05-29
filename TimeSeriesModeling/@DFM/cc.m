function [Q,PQ] = cc(C,X,PX)
% cc  Common components in observables.
%
% Backend IRIS function.
% No help provided.

% -IRIS Macroeconomic Modeling Toolbox.
% -Copyright (c) 2007-2022 IRIS Solutions Team & Troy Matheson.

%--------------------------------------------------------------------------

meanOnly = nargin < 3 || isempty(PX) || nargout < 2;
ny = size(C,1);
nAlt = size(C,3);
nPer = size(X,2);
nData = size(X,3);
nLoop = max([nAlt,nData]);
Q = nan([ny,nPer,nLoop]);
PQ = nan([ny,ny,nPer,nLoop]);
for iLoop = 1 : nLoop
   if iLoop <= nAlt
      Ci = C(:,:,iLoop);
      Cit = Ci';
   end
   if iLoop <= nData
      xi = X(:,:,iLoop);
      if ~meanOnly
         Pxi = PX(:,:,:,iLoop);
      end
   end
   Q(:,:,iLoop) = Ci*xi;
   if ~meanOnly
      for t = 1 : nPer
         PQ(:,:,t,iLoop) = Ci*Pxi(:,:,t)*Cit;
      end
   end
end

end
