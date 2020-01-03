function flag = beenSolved(this)
% beenSolved  True if first-order solution has been successfully calculated
%
% ## Syntax ##
%
%     flag = beenSolved(model)
%
%
% ## Input Arguments ##
%
% * `model` [ model ] - Model object.
%
%
% ## Output Arguments ##
%
% * `flag` [ `true` | `false` ] - True for parameter variants for which
% a stable unique solution has been successfully calculated.
%
%
% ## Description ##
%
%
% ## Example ##
%

% -IRIS Macroeconomic Modeling Toolbox
% -Copyright (c) 2007-2020 IRIS Solutions Team

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

