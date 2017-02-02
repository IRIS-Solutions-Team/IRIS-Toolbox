function Flag = issolved(m)
% issolved  True if model solution exists.
%
%
% Syntax
% =======
%
%     Flag = issolved(M)
%
%
% Input arguments
% ================
%
% * `M` [ model ] - Model object.
%
%
% Output arguments
% =================
%
% * `Flag` [ `true` | `false` ] - True for each parameterisation for which
% a stable unique solution exists currently in the model object.
%
%
% Description
% ============
%
%
% Example
% ========
%

% -IRIS Macroeconomic Modeling Toolbox.
% -Copyright (c) 2007-2017 IRIS Solutions Team.

%--------------------------------------------------------------------------

T = m.solution{1};
nAlt = size(T,3);

% Models with no equations return `false`.
if size(T,1) == 0
    Flag = false(1,nAlt);
    return
end

[~,Flag] = isnan(m,'solution');
Flag = ~Flag;

end
