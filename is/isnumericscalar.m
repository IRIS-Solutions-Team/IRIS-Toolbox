function Flag = isnumericscalar(X,Lb,Ub)
% isnumericscalar  True if variable is numeric scalar (of any numeric type).
%
% Syntax 
% =======
%
%     Flag = isnumericscalar(X,Lb,Ub)
%
% Input arguments
% ================
%
% * `X` [ numeric ] - Variable that will be tested.
%
% * `Lb` [ numeric ] - Lower bound test.
% 
% * `Ub` [ numeric ] - Upper bound test. 
%
% Output arguments
%
% * `Flag` [ `true` | `false` ] - True if the input variable `X` is a
% logical scalar.
%
% Description
% ============
%
% Example
% ========
%

% -IRIS Macroeconomic Modeling Toolbox.
% -Copyright (c) 2007-2021 IRIS Solutions Team.

%--------------------------------------------------------------------------

Flag = isnumeric(X) && numel(X) == 1;

if nargin>1
    Flag = Flag.*(X>Lb) ;
    if nargin>2
        Flag = Flag.*(X<Ub) ;
    end
end

end
