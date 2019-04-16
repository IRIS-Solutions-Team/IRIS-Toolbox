function flag = isSolved(this)
% issolved  True if model solution exists
%
% __Syntax__
%
%     flag = isSolved(model)
%
%
% __Input Arguments__
%
% * `model` [ model ] - Model object.
%
%
% __Output Arguments__
%
% * `flag` [ `true` | `false` ] - True for parameter variants for which
% a stable unique solution exists currently in the model object.
%
%
% __Description__
%
%
% __Example__
%

% -IRIS Macroeconomic Modeling Toolbox
% -Copyright (c) 2007-2019 IRIS Solutions Team

%--------------------------------------------------------------------------

% Models with no equations return false
if isempty(this.Variant.FirstOrderSolution{1}) && isempty(this.Variant.FirstOrderSolution{2})
    nv = length(this);
    flag = false(1, nv);
    return
end

[~, flag] = isnan(this, 'solution');
flag = ~flag;

end%

