function this = remove(this, ixRemove)
% remove  Remove quantities.
%
% Backend IRIS function.
% No help provided.

% -IRIS Macroeconomic Modeling Toolbox.
% -Copyright (c) 2007-2022 IRIS Solutions Team.

%--------------------------------------------------------------------------

this.Name(ixRemove) = [ ];
this.Type(ixRemove) = [ ];
this.Label(ixRemove) = [ ];
this.Alias(ixRemove) = [ ];
this.IxLog(ixRemove) = [ ];
this.IxLagrange(ixRemove) = [ ];
this.Bounds(:, ixRemove) = [ ];

end
