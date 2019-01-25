function [x,index] = sort(x,crit)
% sort  Sort tseries columns by specified criterion.
%
% Syntax
% =======
%
%     [Y,INDEX] = sort(X,CRIT)
%
% Input arguments
% ================
%
% * `X` [ tseries ] - Input tseries object whose columns will be sorted
% in order determined by the criterion `crit`.
%
% * `CRIT` [ 'sumsq' | 'sumabs' | 'max' | 'maxabs' | 'min' | 'minabs' ] -
% Criterion used to sort the input tseries object columns.
%
% Output arguments
% =================
%
% * `Y` [ tseries ] - Output tseries object with columns sorted in order
% determined by the input criterion, `CRIT`.
%
% * `INDEX` [ numeric ] - Vector of indices, `y = x{:,index}`.
%
% Description
% ============
%
% Example
% ========
%

% -IRIS Macroeconomic Modeling Toolbox.
% -Copyright (c) 2007-2019 IRIS Solutions Team.

%**************************************************************************

s = size(x.data);
x.data = x.data(:,:);
x.Comment = x.Comment(1,:);

switch crit
   case 'sumsq'
      [ans,index] = sort(sum(x.data.^2,1),'descend'); %#ok<*NOANS,*ASGLU>
   case 'sumabs'
      [ans,index] = sort(sum(abs(x.data),1),'descend');
   case 'max'
      [ans,index] = sort(max(x.data,[ ],1),'descend');
   case 'maxabs'
      [ans,index] = sort(max(abs(x.data),[ ],1),'descend');
   case 'min'
      [ans,index] = sort(min(x.data,[ ],1),'ascend');
   case 'minabs'
      [ans,index] = sort(min(abs(x.data),[ ],1),'ascend');
end

x.data = x.data(:,index);
x.Comment = x.Comment(index);
if length(s) > 2
    x.data = reshape(x.data,s);
    x.Comment = reshape(x.Comment,[1,s(2:end)]);
end

end