function [lsExgName, lsEndgName, lsCondName] = myinfo4plan(this)
% myinfo4plan  [Not a public function] Information for creating simulation plan.
%
% Backend IRIS function.
% No help provided.

% -IRIS Macroeconomic Modeling Toolbox.
% -Copyright (c) 2007-2017 IRIS Solutions Team.

TYPE = @int8;

%--------------------------------------------------------------------------

ixy = this.Quantity.Type==TYPE(1);
ixx = this.Quantity.Type==TYPE(2);
ixe = this.Quantity.Type==TYPE(31) | this.Quantity.Type==TYPE(32);

lsExgName = this.Quantity.Name(ixy | ixx);
lsEndgName = this.Quantity.Name(ixe);
lsCondName = this.Quantity.Name(ixy | ixx);

end
