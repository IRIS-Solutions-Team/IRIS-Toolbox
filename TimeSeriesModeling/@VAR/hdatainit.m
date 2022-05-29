function hdatainit(this, H)
% hdatainit  Initialise hdataobj for VAR
%
% Backend IRIS function.
% No help provided.

% -IRIS Macroeconomic Modeling Toolbox.
% -Copyright (c) 2007-2022 IRIS Solutions Team.

%--------------------------------------------------------------------------

ny = size(this.A, 1);
nx = this.NumExogenous;
ne = ny;
ni = this.NumConditioning;

H.Id = { 1:ny, ny+(1:nx), ny+nx+(1:ne), ny+nx+ne+(1:ni) };
H.Name = this.AllNames;
H.IxLog = false(size(H.Name));
H.Label = this.AllNames;

if isequal(H.Contributions, @shock)
    H.Contributions = [ this.ResidualNames, {'Init+Const'}, {'Exog'} ];
elseif isequal(H.Contributions, @measurement)
    H.Contributions = this.EndogenousNames;
end

end
