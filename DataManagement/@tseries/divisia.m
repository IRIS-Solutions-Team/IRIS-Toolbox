function x = divisia(x,w,range)

if nargin < 3
   range = Inf;
end

% For backward compatibility, accept divisia(x,range,w),
% and swap w and range.
if isnumeric(w) && (any(isinf(w)) || (size(w,1) == 1 && size(w,2) ~= size(x,2)))
   [w,range] = deal(range,w);
end

%**************************************************************************

x = windex(x,w,range,'method','divisia');

end
