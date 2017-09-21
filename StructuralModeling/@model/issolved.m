function flag = issolved(this)
% issolved  True if model solution exists.
%
% __Syntax__
%
%     flag = issolved(M)
%
%
% __Input Arguments__
%
% * `M` [ model ] - Model object.
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

% -IRIS Macroeconomic Modeling Toolbox.
% -Copyright (c) 2007-2017 IRIS Solutions Team.

%--------------------------------------------------------------------------

% Models with no equations return `false`.
if isempty(this.Variant.Solution{1});
    nv = length(this);
    flag = false(1, nv);
    return
end

[~, flag] = isnan(this, 'solution');
flag = ~flag;

end
