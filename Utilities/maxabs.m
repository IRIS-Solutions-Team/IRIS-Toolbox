function D = maxabs(X,Y)
% maxabs  Maximum absolute difference between two varibles.
%
% Syntax
% =======
%
%     D = maxabs(A)
%     D = maxabs(A,B)
%
% Input arguments
% ================
%
% * `A` [ numeric | struct ] - First input argument.
%
% * `B` [ numeric | struct ] - Second input argument; must be the same type
% as the first input argument, `A`.
%
% Output arguments
% =================
%
% * `D` [ numeric | struct ] - The maximum absolute number in `A` (if only
% one input argument is passed in) or the maximum absolute difference
% between `A` and `B` (if two input arguments are passed in); `D` is the
% same type as `A`.
%
% Description
% ============
%
% Example
% ========
%
%     d1 = struct( );
%     d1.a = [1,2,3];
%     d1.b = [10,20,30];
%     d2 = struct( );
%     d2.a = [1.01,2.05,3.66];
%     d2.b = [10.15,20.22,30.98];
%
%     maxabs(d1)
%
%     ans = 
% 
%         a: 3
%         b: 30
%
%     maxabs(d1,d2)
%
%     ans = 
% 
%         a: 0.6600
%         b: 0.9800
% 

% -IRIS Macroeconomic Modeling Toolbox.
% -Copyright (c) 2007-2022 IRIS Solutions Team.

%--------------------------------------------------------------------------

if nargin > 1
   X = X - Y;
end
D = max(abs(X(:)));

end
