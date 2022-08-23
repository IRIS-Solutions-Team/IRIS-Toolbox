function this = selectType(this, type)
% selectType  Return only equations of specified type.
%
% Backend IRIS function.
% No help provided.

% -IRIS Macroeconomic Modeling Toolbox.
% -Copyright (c) 2007-2022 IRIS Solutions Team.

ix = this.Type==type;
this.Input = this.Input(ix);
this.Type = this.Type(ix);
this.Label = this.Label(ix);
this.Alias = this.Alias(ix);
this.Dynamic = this.Dynamic(ix);
this.Steady = this.Steady(ix);
this.IxHash = this.IxHash(ix);

end
