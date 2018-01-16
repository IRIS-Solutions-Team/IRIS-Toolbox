function [y,Py] = destandardise(ymean,ystd,y,Py)
% destandardise  Destandardise output data.
%
% Backend IRIS function.
% No help provided.

% -IRIS Macroeconomic Modeling Toolbox.
% -Copyright (c) 2007-2018 IRIS Solutions Team.

%**************************************************************************

nper = size(y,2);
repeat = ones([1,nper]);
if any(any(ymean ~= 0))
   y = y .* ystd(:,repeat,:) + ymean(:,repeat,:);
else
   y = y .* ystd(:,repeat,:);
end

if nargin > 3 && nargout > 1 && ~isempty(Py)
   ny = size(Py,1);
   ystd = ystd(:,ones([1,ny]));
   for t = 1 : nper
      Py(:,:,t) = ystd .* Py(:,:,t);
      Py(:,:,t) = Py(:,:,t) .* ystd';
   end
else
   Py = [ ];
end

end
