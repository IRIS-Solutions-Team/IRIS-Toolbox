function [lsExgName, lsEndgName, lsCondName] = myinfo4plan(this)
% myinfo4plan  [Not a public function] Information for creating simulation plan.
%
% Backend IRIS function.
% No help provided.

% -IRIS Macroeconomic Modeling Toolbox.
% -Copyright (c) 2007-2022 IRIS Solutions Team.

ixy = this.Quantity.Type==1;
ixx = this.Quantity.Type==2;
ixe = this.Quantity.Type==31 | this.Quantity.Type==32;

lsExgName = this.Quantity.Name(ixy | ixx);
lsEndgName = this.Quantity.Name(ixe);
lsCondName = this.Quantity.Name(ixy | ixx);

end
